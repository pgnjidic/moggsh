import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../settings/settings_service.dart';
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
  late final PageController _pageController;
  final _terminalKeys = <String, GlobalKey<TerminalWidgetState>>{};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  GlobalKey<TerminalWidgetState> _keyFor(String tabId) =>
      _terminalKeys.putIfAbsent(tabId, () => GlobalKey<TerminalWidgetState>());

  void _onSwitch(TabManager mgr, int index) {
    mgr.switchTo(index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TabManager>(
      builder: (context, mgr, _) {
        final tabs = mgr.tabs;

        if (tabs.isEmpty) {
          return const _EmptyState();
        }

        return Scaffold(
          backgroundColor: const Color(0xFF0A0A0F),
          body: SafeArea(
            child: Column(
              children: [
                MogshTabBar(
                  tabs: tabs,
                  activeIndex: mgr.activeIndex,
                  onSwitch: (i) => _onSwitch(mgr, i),
                  onClose: (id) {
                    _terminalKeys.remove(id);
                    mgr.closeTab(id);
                    if (mgr.tabs.isNotEmpty) {
                      _pageController.jumpToPage(mgr.activeIndex);
                    }
                  },
                  onRename: (newTitle) {
                    final tab = tabs[mgr.activeIndex];
                    mgr.renameTab(tab.id, newTitle);
                  },
                  onAddTab: null,
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: tabs.length,
                    onPageChanged: (i) => mgr.switchTo(i),
                    itemBuilder: (_, i) => _TabPage(
                      tab: tabs[i],
                      terminalKey: _keyFor(tabs[i].id),
                    ),
                  ),
                ),
                ShortcutBar(
                  onSend: (data) => mgr.activeTab?.sendInput(data),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0A0A0F),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.terminal, color: Color(0xFF444466), size: 48),
            SizedBox(height: 16),
            Text('no active sessions',
                style: TextStyle(color: Color(0xFF444466), fontFamily: 'monospace', fontSize: 14)),
            SizedBox(height: 8),
            Text('connect to a server from the Hosts tab',
                style: TextStyle(color: Color(0xFF333355), fontFamily: 'monospace', fontSize: 12)),
          ],
        ),
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
  StreamSubscription<String>? _outputSub;
  double _lastAppliedFontSize = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _outputSub?.cancel();
    super.dispose();
  }

  void _applyFontSize(double fontSize) {
    if (fontSize == _lastAppliedFontSize) return;
    _lastAppliedFontSize = fontSize;
    widget.terminalKey.currentState?.setFontSize(fontSize.round());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final fontSize = context.watch<SettingsService>().fontSize;
    // Apply font size change (post-frame so we're not in build phase)
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyFontSize(fontSize));

    return TerminalWidget(
      key: widget.terminalKey,
      onReady: () {
        _outputSub?.cancel();
        for (final chunk in widget.tab.scrollbackBuffer) {
          widget.terminalKey.currentState?.write(chunk);
        }
        // Force fit + apply current font size so terminal isn't blank
        _applyFontSize(fontSize);
        _outputSub = widget.tab.output.listen((data) {
          widget.terminalKey.currentState?.write(data);
        });
      },
      onInput: widget.tab.sendInput,
      onResize: widget.tab.resize,
    );
  }
}
