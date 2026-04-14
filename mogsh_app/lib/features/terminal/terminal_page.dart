import 'dart:async';
import 'package:flutter/material.dart';
import 'services/pterm_service.dart';
import 'setup_screen.dart';
import 'terminal_widget.dart';

class TerminalPage extends StatefulWidget {
  const TerminalPage({super.key});

  @override
  State<TerminalPage> createState() => _TerminalPageState();
}

class _TerminalPageState extends State<TerminalPage> with WidgetsBindingObserver {
  final _service = PtermService();
  final _terminalKey = GlobalKey<TerminalWidgetState>();
  bool _needsSetup = false;
  bool _checking = true;
  bool _crashed = false;
  StreamSubscription<void>? _crashSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
  }

  Future<void> _check() async {
    final needs = await _service.needsSetup();
    if (mounted) setState(() { _needsSetup = needs; _checking = false; });
  }

  void _onSetupComplete() => setState(() => _needsSetup = false);

  void _onTerminalReady() {
    _service.start().then((_) {
      _crashSub = _service.onCrash.listen((_) {
        if (mounted) setState(() => _crashed = true);
      });
      _service.output.listen((data) {
        _terminalKey.currentState?.write(data);
      });
    });
  }

  void _reconnect() {
    setState(() => _crashed = false);
    _terminalKey.currentState?.clear();
    _service.restart().then((_) {
      _service.output.listen((data) {
        _terminalKey.currentState?.write(data);
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Foreground service keeps PTY alive — nothing extra needed here
  }

  @override
  void dispose() {
    _crashSub?.cancel();
    _service.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(backgroundColor: Color(0xFF0A0A0F), body: SizedBox.shrink());
    }
    if (_needsSetup) {
      return SetupScreen(service: _service, onComplete: _onSetupComplete);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Stack(
          children: [
            // Terminal
            TerminalWidget(
              key: _terminalKey,
              onReady: _onTerminalReady,
              onInput: _service.write,
              onResize: _service.resize,
            ),

            // Ctrl+C button
            Positioned(
              bottom: 8,
              right: 8,
              child: _CtrlCButton(onTap: _service.sendCtrlC),
            ),

            // Crash recovery overlay
            if (_crashed) _CrashOverlay(onReconnect: _reconnect),
          ],
        ),
      ),
    );
  }
}

class _CtrlCButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CtrlCButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFF333355)),
        ),
        child: const Text(
          'Ctrl+C',
          style: TextStyle(
            color: Color(0xFFFF5555),
            fontSize: 11,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}

class _CrashOverlay extends StatelessWidget {
  final VoidCallback onReconnect;
  const _CrashOverlay({required this.onReconnect});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xCC0A0A0F),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Terminal session ended',
              style: TextStyle(color: Color(0xFF888899), fontSize: 14, fontFamily: 'monospace'),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onReconnect,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF00FF88)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Reconnect',
                  style: TextStyle(
                    color: Color(0xFF00FF88),
                    fontSize: 13,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
