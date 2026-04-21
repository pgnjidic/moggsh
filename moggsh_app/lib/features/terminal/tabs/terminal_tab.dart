import 'dart:async';
import '../../ssh/services/ssh_session.dart';

enum SessionState { connecting, active, idle, offline }

class TerminalTab {
  final String id;
  String title;
  final SshSession session;
  SessionState sessionState;

  final List<String> scrollbackBuffer = [];
  static const int maxScrollback = 5000;

  final _inputLineBuffer = StringBuffer();

  final _outputController = StreamController<String>.broadcast();
  final _closedController = StreamController<void>.broadcast();

  Stream<String> get output  => _outputController.stream;
  Stream<void>   get onClose => _closedController.stream;

  StreamSubscription<String>? _outputSub;
  StreamSubscription<SshConnectionState>? _stateSub;

  TerminalTab({
    required this.id,
    required this.title,
    required this.session,
    this.sessionState = SessionState.connecting,
  });

  void startListening() {
    // Drain data that arrived before this subscription (MOTD, initial prompt).
    // SshSession buffers output from shell start; consuming it here ensures
    // onReady() can replay it even if the UI wasn't ready during connection.
    for (final chunk in session.preBuffer) {
      scrollbackBuffer.add(chunk);
      if (scrollbackBuffer.length > maxScrollback) scrollbackBuffer.removeAt(0);
    }
    session.consumePreBuffer();

    _outputSub = session.output.listen((data) {
      scrollbackBuffer.add(data);
      if (scrollbackBuffer.length > maxScrollback) scrollbackBuffer.removeAt(0);
      _outputController.add(data);
    });

    _stateSub = session.stateChanges.listen((state) {
      switch (state) {
        case SshConnectionState.connected:
          sessionState = SessionState.active;
        case SshConnectionState.connecting:
        case SshConnectionState.reconnecting:
          sessionState = SessionState.connecting;
        case SshConnectionState.disconnected:
        case SshConnectionState.error:
          sessionState = SessionState.offline;
          _outputController.add('\r\n\x1b[31m[disconnected]\x1b[0m\r\n');
      }
    });
  }

  void sendInput(String data) {
    for (final ch in data.split('')) {
      if (ch == '\r' || ch == '\n') {
        final cmd = _inputLineBuffer.toString().trim();
        if (cmd == 'exit' || cmd == 'logout') session.disableReconnect();
        _inputLineBuffer.clear();
      } else if (ch == '\x7f' || ch == '\x08') {
        final s = _inputLineBuffer.toString();
        if (s.isNotEmpty) {
          _inputLineBuffer.clear();
          _inputLineBuffer.write(s.substring(0, s.length - 1));
        }
      } else if (ch.codeUnitAt(0) >= 0x20) {
        _inputLineBuffer.write(ch);
      } else {
        // control character (arrow keys etc.) resets line buffer
        _inputLineBuffer.clear();
      }
    }
    session.write(data);
  }

  void resize(int cols, int rows) => session.resize(cols, rows);

  void disconnect() {
    session.disconnect();
  }

  void dispose() {
    _outputSub?.cancel();
    _stateSub?.cancel();
    _outputController.close();
    _closedController.close();
    session.dispose();
  }
}
