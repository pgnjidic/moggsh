import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../settings/settings_service.dart';
import '../ssh/services/ssh_session.dart';
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

  String? _seedFor(TerminalTab? tab) {
    if (tab == null || tab.scrollbackBuffer.isEmpty) return null;
    final joined = tab.scrollbackBuffer.join();
    const max = 4000;
    return joined.length <= max ? joined : joined.substring(joined.length - max);
  }

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
    final landscape = MediaQuery.of(context).orientation == Orientation.landscape;
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
                  compact: landscape,
                  // Reserve space on the right side for the floating nav FAB
                  trailing: landscape ? const SizedBox(width: 48) : null,
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
                  activeTabOutput: mgr.activeTab?.output,
                  scrollbackSeed: _seedFor(mgr.activeTab),
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
  StreamSubscription<SshConnectionState>? _stateSub;
  SettingsService? _settings;
  TabManager? _tabMgr;
  bool _wasActive = false;
  bool _sawConnected = false;
  bool _sawFirstData = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = Provider.of<SettingsService>(context, listen: false);
    if (_settings != settings) {
      _settings?.removeListener(_onSettingsChanged);
      _settings = settings;
      _settings!.addListener(_onSettingsChanged);
    }
    final mgr = Provider.of<TabManager>(context, listen: false);
    if (_tabMgr != mgr) {
      _tabMgr?.removeListener(_onTabManagerChanged);
      _tabMgr = mgr;
      _tabMgr!.addListener(_onTabManagerChanged);
      _wasActive = _tabMgr!.activeTab?.id == widget.tab.id;
    }
  }

  void _onSettingsChanged() {
    widget.terminalKey.currentState?.setFontSize(
      (_settings?.fontSize ?? 14.0).round(),
    );
  }

  void _onTabManagerChanged() {
    final isActive = _tabMgr?.activeTab?.id == widget.tab.id;
    if (isActive && !_wasActive) {
      // Tab transitioned from inactive → active. WebView may have been
      // laid out at 0×0 while hidden; force fit+refresh so xterm repaints.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.terminalKey.currentState?.fit();
        Future.delayed(const Duration(milliseconds: 200),
            () => widget.terminalKey.currentState?.fit());
      });
    }
    _wasActive = isActive;
  }

  @override
  void dispose() {
    _settings?.removeListener(_onSettingsChanged);
    _tabMgr?.removeListener(_onTabManagerChanged);
    _outputSub?.cancel();
    _stateSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return TerminalWidget(
      key: widget.terminalKey,
      onReady: () {
        _outputSub?.cancel();
        for (final chunk in widget.tab.scrollbackBuffer) {
          widget.terminalKey.currentState?.write(chunk);
        }
        // Always apply font size when terminal first becomes ready (also calls fitAddon.fit())
        widget.terminalKey.currentState?.setFontSize(
          (_settings?.fontSize ?? 14.0).round(),
        );
        _outputSub = widget.tab.output.listen((data) {
          widget.terminalKey.currentState?.write(data);
          if (!_sawFirstData) {
            _sawFirstData = true;
            // Belt-and-suspenders: fire fit() at multiple points after first
            // data so at least one lands after canvas is drawn AND term.rows>0.
            for (final ms in [80, 250, 600]) {
              Future.delayed(Duration(milliseconds: ms), () {
                if (mounted) widget.terminalKey.currentState?.fit();
              });
            }
          }
        });
        // Force synchronous repaint after the 16ms write-buffer flushes.
        // Android WebView throttles requestAnimationFrame when unfocused, so
        // xterm.js never paints the initial content without this nudge.
        Future.delayed(const Duration(milliseconds: 50), () {
          widget.terminalKey.currentState?.refresh();
        });
        // Extra fit after layout settles — catches WebViews pre-built offscreen.
        Future.delayed(const Duration(milliseconds: 300), () {
          widget.terminalKey.currentState?.fit();
        });

        // Fit right when session transitions to connected — MOTD starts streaming.
        _stateSub?.cancel();
        _stateSub = widget.tab.session.stateChanges.listen((s) {
          if (s == SshConnectionState.connected && !_sawConnected) {
            _sawConnected = true;
            Future.delayed(const Duration(milliseconds: 100), () {
              widget.terminalKey.currentState?.fit();
            });
          }
        });
      },
      onInput: widget.tab.sendInput,
      onResize: widget.tab.resize,
    );
  }
}
