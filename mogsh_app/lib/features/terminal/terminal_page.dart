import 'package:flutter/material.dart';
import 'terminal_widget.dart';

class TerminalPage extends StatefulWidget {
  const TerminalPage({super.key});

  @override
  State<TerminalPage> createState() => _TerminalPageState();
}

class _TerminalPageState extends State<TerminalPage> {
  final _terminalKey = GlobalKey<TerminalWidgetState>();

  @override
  void initState() {
    super.initState();
    // Demo output after terminal is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 800), _writeDemo);
    });
  }

  void _writeDemo() {
    final t = _terminalKey.currentState;
    if (t == null) return;
    t.writeln('\x1b[1;32mmogsh\x1b[0m — terminal emulator');
    t.writeln('\x1b[90m─────────────────────────────\x1b[0m');
    t.writeln('\x1b[36mANSI colors:\x1b[0m \x1b[31mred\x1b[0m \x1b[32mgreen\x1b[0m \x1b[33myellow\x1b[0m \x1b[34mblue\x1b[0m \x1b[35mmagenta\x1b[0m \x1b[36mcyan\x1b[0m');
    t.writeln('\x1b[1mbold\x1b[0m \x1b[2mdim\x1b[0m \x1b[4munderline\x1b[0m \x1b[7mreverse\x1b[0m');
    t.writeln('');
    t.write('\x1b[1;32m\$\x1b[0m ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: TerminalWidget(
          key: _terminalKey,
          onReady: _writeDemo,
          onInput: (data) {
            // In real use this goes to SSH/pty — for now echo back
            _terminalKey.currentState?.write(data);
          },
          onResize: (cols, rows) {
            debugPrint('Terminal resized: ${cols}x$rows');
          },
        ),
      ),
    );
  }
}
