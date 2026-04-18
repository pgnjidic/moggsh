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
          // Auto-close tab after brief delay so user sees the message
          Future.delayed(const Duration(milliseconds: 1200), () {
            if (!_closedController.isClosed) _closedController.add(null);
          });
      }
    });
  }

  void sendInput(String data) {
    // Detect exit — disable auto-reconnect before sending
    final trimmed = data.trim();
    if (trimmed == 'exit' || trimmed == 'logout') {
      session.disableReconnect();
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
