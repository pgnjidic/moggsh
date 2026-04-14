import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'tabs/tab_manager.dart';
import 'tabs/terminal_tab.dart';
import 'terminal_widget.dart';
import 'widgets/shortcut_bar.dart';
import 'widgets/tab_bar_widget.dart';

class MultiTabScreen extends StatefulWidget {
  const MultiTabScreen({super.key});

  @override
  State<MultiTabScreen> createState() => _MultiTabScreenState();
}

class _MultiTabScreenState extends State<MultiTabScreen> {
  late final TabManager _tabManager;
  late final PageController _pageController;
  final _terminalKeys = <String, GlobalKey<TerminalWidgetState>>{};

  @override
  void initState() {
    super.initState();
    _tabManager = TabManager();
    _pageController = PageController();
    // Open first tab
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _tabManager.addLocalTab(title: 'local 1');
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabManager.dispose();
    _pageController.dispose();
    super.dispose();
  }

  GlobalKey<TerminalWidgetState> _keyFor(String tabId) {
    return _terminalKeys.putIfAbsent(tabId, () => GlobalKey<TerminalWidgetState>());
  }

  void _onSwitch(int index) {
    _tabManager.switchTo(index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _tabManager,
      child: Consumer<TabManager>(
        builder: (context, mgr, _) {
          final tabs = mgr.tabs;
          if (tabs.isEmpty) {
            return const Scaffold(
              backgroundColor: Color(0xFF0A0A0F),
              body: Center(child: CircularProgressIndicator(color: Color(0xFF00FF88))),
            );
          }

          return Scaffold(
            backgroundColor: const Color(0xFF0A0A0F),
            body: SafeArea(
              child: Column(
                children: [
                  // Tab bar
                  MogshTabBar(
                    tabs: tabs,
                    activeIndex: mgr.activeIndex,
                    onSwitch: _onSwitch,
                    onClose: (id) {
                      final idx = tabs.indexWhere((t) => t.id == id);
                      _terminalKeys.remove(id);
                      mgr.closeTab(id);
                      if (idx > 0) {
                        _pageController.jumpToPage(mgr.activeIndex);
                      }
                      setState(() {});
                    },
                    onRename: (newTitle) {
                      final tab = tabs[mgr.activeIndex];
                      mgr.renameTab(tab.id, newTitle);
                      setState(() {});
                    },
                    onAddTab: () async {
                      await mgr.addLocalTab(title: 'local ${tabs.length + 1}');
                      _pageController.jumpToPage(mgr.activeIndex);
                      setState(() {});
                    },
                  ),

                  // Terminal pages — swipeable
                  Expanded(
                    child: GestureDetector(
                      // Swipe up → send ↑ (history)
                      onVerticalDragEnd: (details) {
                        if (details.primaryVelocity != null &&
                            details.primaryVelocity! < -300) {
                          final tab = mgr.activeTab;
                          if (tab != null) {
                            _keyFor(tab.id).currentState?.write('\x1b[A');
                          }
                        }
                      },
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: tabs.length,
                        onPageChanged: (i) {
                          _tabManager.switchTo(i);
                          setState(() {});
                        },
                        itemBuilder: (_, i) {
                          final tab = tabs[i];
                          return _TabPage(
                            tab: tab,
                            terminalKey: _keyFor(tab.id),
                          );
                        },
                      ),
                    ),
                  ),

                  // Shortcut bar
                  ShortcutBar(
                    onSend: (data) {
                      final tab = mgr.activeTab;
                      if (tab != null) {
                        tab.sendInput(data);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TabPage extends StatefulWidget {
  final TerminalTab tab;
  final GlobalKey<TerminalWidgetState> terminalKey;

  const _TabPage({required this.tab, required this.terminalKey});

  @override
  State<_TabPage> createState() => _TabPageState();
}

class _TabPageState extends State<_TabPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Keep terminal alive when swiping between tabs

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return TerminalWidget(
      key: widget.terminalKey,
      onReady: () {
        // Replay scrollback buffer for this tab
        for (final chunk in widget.tab.scrollbackBuffer) {
          widget.terminalKey.currentState?.write(chunk);
        }
        // Listen to future output
        widget.tab.output.listen((data) {
          widget.terminalKey.currentState?.write(data);
        });
      },
      onInput: widget.tab.sendInput,
      onResize: widget.tab.resize,
    );
  }
}
