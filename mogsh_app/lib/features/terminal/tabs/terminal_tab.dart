import 'dart:async';
import '../services/pterm_service.dart';

enum TabType { local, ssh }
enum SessionState { active, idle, offline }

class TerminalTab {
  final String id;
  String title;
  final TabType type;
  SessionState sessionState;
  final PtermService? localService; // null for SSH tabs (MOG-10)

  // Each tab has its own output buffer for independent scrollback
  final List<String> scrollbackBuffer = [];
  static const int maxScrollback = 5000;

  final _outputController = StreamController<String>.broadcast();
  Stream<String> get output => _outputController.stream;

  StreamSubscription<void>? _crashSub;
  bool _crashed = false;
  bool get hasCrashed => _crashed;

  TerminalTab({
    required this.id,
    required this.title,
    required this.type,
    this.localService,
    this.sessionState = SessionState.idle,
  });

  void startListening() {
    if (localService == null) return;
    localService!.output.listen((data) {
      scrollbackBuffer.add(data);
      if (scrollbackBuffer.length > maxScrollback) {
        scrollbackBuffer.removeAt(0);
      }
      _outputController.add(data);
      sessionState = SessionState.active;
    });
    _crashSub = localService!.onCrash.listen((_) {
      _crashed = true;
      sessionState = SessionState.offline;
      _outputController.add('\r\n\x1b[31m[session ended]\x1b[0m\r\n');
    });
  }

  void sendInput(String data) {
    localService?.write(data);
    if (data.isNotEmpty) sessionState = SessionState.active;
  }

  void resize(int cols, int rows) => localService?.resize(cols, rows);

  void dispose() {
    _crashSub?.cancel();
    _outputController.close();
    localService?.dispose();
  }
}
