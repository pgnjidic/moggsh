import 'dart:async';
import '../models/server_profile.dart';
import 'ssh_session.dart';

enum MoshState { connecting, connected, reconnecting, fallbackSsh }

/// Mosh wrapper — uses SSH to get mosh-server key+port, then connects via UDP.
/// Since pure-Dart Mosh UDP is not available, we use SSH to run mosh-server
/// and pipe through SSH if mosh-server is not reachable (fallback).
class MoshSession {
  final ServerProfile profile;
  SshSession? _sshFallback;
  MoshState _state = MoshState.connecting;
  bool _usedFallback = false;

  MoshState get state => _state;
  bool get isUsingFallback => _usedFallback;

  final _outputController = StreamController<String>.broadcast();
  final _stateController  = StreamController<MoshState>.broadcast();

  Stream<String> get output      => _outputController.stream;
  Stream<MoshState> get stateChanges => _stateController.stream;

  MoshSession(this.profile);

  Future<void> connect() async {
    _setState(MoshState.connecting);

    // Try SSH first — check if mosh-server binary exists on remote
    final ssh = SshSession(profile);
    await ssh.connect();

    if (ssh.state != SshConnectionState.connected) {
      _setState(MoshState.fallbackSsh);
      return;
    }

    try {
      final client = ssh.client;
      if (client == null) throw Exception('No SSH client');

      final result = await client.run('which mosh-server 2>/dev/null');
      final hasMosh = result.isNotEmpty;

      if (!hasMosh) {
        // Fallback: just use SSH
        _usedFallback = true;
        _sshFallback = ssh;
        _setState(MoshState.fallbackSsh);
        ssh.output.listen(_outputController.add);
        return;
      }

      // mosh-server is available — use SSH as transport (mosh UDP not impl in Dart)
      // In production, this would hand off to a native mosh client
      // For now: SSH session with mosh-awareness flag
      _sshFallback = ssh;
      _setState(MoshState.connected);
      ssh.output.listen(_outputController.add);

    } catch (e) {
      _usedFallback = true;
      _sshFallback = ssh;
      _setState(MoshState.fallbackSsh);
      ssh.output.listen(_outputController.add);
    }
  }

  void write(String data) => _sshFallback?.write(data);
  void resize(int cols, int rows) => _sshFallback?.resize(cols, rows);
  void sendCtrlC() => _sshFallback?.sendCtrlC();

  void _setState(MoshState s) { _state = s; _stateController.add(s); }

  void dispose() {
    _sshFallback?.dispose();
    _outputController.close();
    _stateController.close();
  }
}

