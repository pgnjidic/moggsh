import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../ssh/services/ssh_session.dart';
import 'terminal_tab.dart';

class TabManager extends ChangeNotifier {
  final _tabs = <TerminalTab>[];
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
    if (_tabs.length <= 1) {
      final idx = _tabs.indexWhere((t) => t.id == id);
      if (idx >= 0) {
        _tabs[idx].dispose();
        _tabs.removeAt(idx);
        _activeIndex = 0;
        notifyListeners();
      }
      return;
    }
    final idx = _tabs.indexWhere((t) => t.id == id);
    if (idx < 0) return;
    _tabs[idx].dispose();
    _tabs.removeAt(idx);
    if (_activeIndex >= _tabs.length) _activeIndex = _tabs.length - 1;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final tab in _tabs) { tab.dispose(); }
    super.dispose();
  }
}
