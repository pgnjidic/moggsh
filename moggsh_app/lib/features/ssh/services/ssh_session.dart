import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dartssh2/dartssh2.dart';
import '../models/server_profile.dart';
import 'ssh_key_manager.dart';

enum SshConnectionState { connecting, connected, reconnecting, disconnected, error }

class SshSession {
  final ServerProfile profile;

  SSHClient? _client;
  SSHSession? _shell;
  SshConnectionState _state = SshConnectionState.disconnected;
  String? _lastError;
  String? _knownFingerprint;

  SshConnectionState get state => _state;
  String? get lastError => _lastError;
  SSHClient? get client => _client;

  final _outputController = StreamController<String>.broadcast();
  final _stateController  = StreamController<SshConnectionState>.broadcast();
  final _fingerprintController = StreamController<String>.broadcast();

  Stream<String> get output           => _outputController.stream;
  Stream<SshConnectionState> get stateChanges => _stateController.stream;
  Stream<String> get fingerprintWarning => _fingerprintController.stream;

  // Pre-buffer: captures all shell output from connection until the first
  // TerminalTab subscriber attaches. SshSession uses a broadcast stream so
  // data emitted before subscription is lost. startListening() drains this
  // buffer into the tab's scrollbackBuffer so no output is missed.
  final _preBuffer = <String>[];
  bool _preBuffering = true;
  static const _maxPreBuffer = 5000;
  List<String> get preBuffer => List.unmodifiable(_preBuffer);
  void consumePreBuffer() {
    _preBuffer.clear();
    _preBuffering = false;
  }

  bool _autoReconnect = true;
  int _reconnectAttempts = 0;
  static const _maxReconnects = 5;

  SshSession(this.profile);

  Future<void> connect() async {
    _setState(SshConnectionState.connecting);
    try {
      final socket = await SSHSocket.connect(profile.host, profile.port,
          timeout: const Duration(seconds: 10));

      _client = SSHClient(
        socket,
        username: profile.username,
        onVerifyHostKey: (type, fingerprint) {
          final fpHex = fingerprint.map((b) => b.toRadixString(16).padLeft(2, '0')).join(':');
          if (_knownFingerprint == null) {
            _knownFingerprint = fpHex;
          } else if (_knownFingerprint != fpHex) {
            _fingerprintController.add(fpHex);
          }
          return true; // Accept — user warned via stream
        },
        onPasswordRequest: () => profile.password ?? '',
        identities: await _getIdentities(),
      );

      await _client!.authenticated;
      _shell = await _client!.shell(
        pty: const SSHPtyConfig(
          type: 'xterm-256color',
          width: 80,
          height: 24,
        ),
      );

      _reconnectAttempts = 0;
      _setState(SshConnectionState.connected);

      // Run startup script if set
      if (profile.startupScript != null && profile.startupScript!.isNotEmpty) {
        write('${profile.startupScript}\n');
      }

      // Stream output — also feed pre-buffer until first subscriber attaches.
      void emit(String data) {
        if (_preBuffering) {
          _preBuffer.add(data);
          if (_preBuffer.length > _maxPreBuffer) _preBuffer.removeAt(0);
        }
        _outputController.add(data);
      }
      _shell!.stdout
          .cast<List<int>>()
          .transform(const Utf8Decoder(allowMalformed: true) as StreamTransformer<List<int>, String>)
          .listen(emit, onDone: _onCleanExit, onError: (_) => _onDropped(), cancelOnError: true);
      _shell!.stderr
          .cast<List<int>>()
          .transform(const Utf8Decoder(allowMalformed: true) as StreamTransformer<List<int>, String>)
          .listen(emit);

    } catch (e) {
      _lastError = e.toString();
      _setState(SshConnectionState.error);
      if (_autoReconnect && _reconnectAttempts < _maxReconnects) {
        _scheduleReconnect();
      }
    }
  }

  void write(String data) {
    _shell?.stdin.add(Uint8List.fromList(data.codeUnits));
  }

  void resize(int cols, int rows) {
    _shell?.resizeTerminal(cols, rows);
  }

  void sendCtrlC() => write('\x03');

  Future<List<String>> listTmuxSessions() async {
    if (_state != SshConnectionState.connected) return [];
    try {
      final result = await _client!.run('tmux list-sessions -F "#{session_name}" 2>/dev/null');
      return const Utf8Decoder()
          .convert(result)
          .split('\n')
          .where((s) => s.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  void attachTmux(String session) => write('tmux attach -t $session\r');

  void disableReconnect() => _autoReconnect = false;

  void disconnect() {
    _autoReconnect = false;
    _client?.close();
    _setState(SshConnectionState.disconnected);
  }

  // Shell exited cleanly (user typed exit/logout/Ctrl+D) — never reconnect.
  void _onCleanExit() {
    _autoReconnect = false;
    _setState(SshConnectionState.disconnected);
  }

  // Connection dropped unexpectedly (network error, server crash, etc.) — reconnect.
  void _onDropped() {
    _setState(SshConnectionState.disconnected);
    if (_autoReconnect && _reconnectAttempts < _maxReconnects) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnectAttempts++;
    _setState(SshConnectionState.reconnecting);
    final delay = Duration(seconds: 2 * _reconnectAttempts);
    Future.delayed(delay, connect);
  }

  void _setState(SshConnectionState s) {
    _state = s;
    _stateController.add(s);
  }

  Future<List<SSHKeyPair>> _getIdentities() async {
    if (profile.keyId == null) return [];
    final key = await SshKeyManager.getPrivateKey(profile.keyId!);
    return key != null ? [key] : [];
  }

  void dispose() {
    _autoReconnect = false;
    _client?.close();
    _outputController.close();
    _stateController.close();
    _fingerprintController.close();
  }
}
