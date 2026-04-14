import 'package:flutter/material.dart';
import 'services/pterm_service.dart';
import 'setup_screen.dart';
import 'terminal_widget.dart';

class TerminalPage extends StatefulWidget {
  const TerminalPage({super.key});

  @override
  State<TerminalPage> createState() => _TerminalPageState();
}

class _TerminalPageState extends State<TerminalPage> {
  final _service = PtermService();
  final _terminalKey = GlobalKey<TerminalWidgetState>();
  bool _needsSetup = false;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final needs = await _service.needsSetup();
    if (mounted) setState(() { _needsSetup = needs; _checking = false; });
  }

  void _onSetupComplete() {
    setState(() => _needsSetup = false);
  }

  void _onTerminalReady() {
    _service.start().then((_) {
      // Pipe proot output → terminal
      _service.output.listen((data) {
        _terminalKey.currentState?.write(data);
      });
    });
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A0F),
        body: SizedBox.shrink(),
      );
    }

    if (_needsSetup) {
      return SetupScreen(
        service: _service,
        onComplete: _onSetupComplete,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: TerminalWidget(
          key: _terminalKey,
          onReady: _onTerminalReady,
          onInput: _service.write,
          onResize: _service.resize,
        ),
      ),
    );
  }
}
