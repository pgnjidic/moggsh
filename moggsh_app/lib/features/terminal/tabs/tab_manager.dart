import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../ssh/services/ssh_session.dart';
import 'terminal_tab.dart';

class TabManager extends ChangeNotifier {
  final _tabs = <TerminalTab>[];
  final _closeSubs = <String, StreamSubscription<void>>{};
  int _activeIndex = 0;

  List<TerminalTab> get tabs => List.unmodifiable(_tabs);
  int get activeIndex => _activeIndex;
  TerminalTab? get activeTab => _tabs.isEmpty ? null : _tabs[_activeIndex];

  static const int maxTabs = 8;

  TerminalTab addSshTab(SshSession session, String title) {
    if (_tabs.length >= maxTabs) {
      switchTo(_tabs.length - 1);
      return _tabs.last;
    }

    final tab = TerminalTab(
      id: const Uuid().v4(),
      title: title,
      session: session,
    );

    _tabs.add(tab);
    _activeIndex = _tabs.length - 1;
    tab.startListening();

    // Auto-close tab when session disconnects
    _closeSubs[tab.id] = tab.onClose.listen((_) => closeTab(tab.id));

    notifyListeners();
    return tab;
  }

  void switchTo(int index) {
    if (index < 0 || index >= _tabs.length) return;
    _activeIndex = index;
    notifyListeners();
  }

  void switchNext() => switchTo((_activeIndex + 1) % _tabs.length);
  void switchPrev() => switchTo((_activeIndex - 1 + _tabs.length) % _tabs.length);

  void renameTab(String id, String newTitle) {
    final tab = _tabs.firstWhere((t) => t.id == id);
    tab.title = newTitle;
    notifyListeners();
  }

  void closeTab(String id) {
    final idx = _tabs.indexWhere((t) => t.id == id);
    if (idx < 0) return;
    _closeSubs.remove(id)?.cancel();
    _tabs[idx].disconnect();
    _tabs[idx].dispose();
    _tabs.removeAt(idx);
    if (_activeIndex >= _tabs.length) _activeIndex = (_tabs.length - 1).clamp(0, double.maxFinite.toInt());
    notifyListeners();
  }

  @override
  void dispose() {
    for (final sub in _closeSubs.values) { sub.cancel(); }
    for (final tab in _tabs) { tab.dispose(); }
    super.dispose();
  }
}
