import 'package:flutter/material.dart';
import 'services/pterm_service.dart';

class SetupScreen extends StatefulWidget {
  final PtermService service;
  final VoidCallback onComplete;

  const SetupScreen({
    super.key,
    required this.service,
    required this.onComplete,
  });

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  String _label = 'Preparing...';
  double _progress = 0.0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _runSetup();
  }

  Future<void> _runSetup() async {
    try {
      await widget.service.setup(
        onProgress: (label, progress) {
          if (mounted) setState(() { _label = label; _progress = progress; });
        },
      );
      if (mounted) widget.onComplete();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF00FF88);
    const bg = Color(0xFF0A0A0F);

    return Scaffold(
      backgroundColor: bg,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'mogsh',
              style: TextStyle(
                color: green,
                fontSize: 28,
                fontFamily: 'monospace',
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Setting up local Linux environment...',
              style: TextStyle(color: Color(0xFF888899), fontSize: 13),
            ),
            const SizedBox(height: 32),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: const Color(0xFF1A1A2E),
                valueColor: const AlwaysStoppedAnimation<Color>(green),
                minHeight: 3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _error != null ? '✗ $_error' : _label,
              style: TextStyle(
                color: _error != null ? const Color(0xFFFF5555) : const Color(0xFF666688),
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => setState(() { _error = null; _runSetup(); }),
                child: const Text(
                  'Retry',
                  style: TextStyle(color: green, fontSize: 13, fontFamily: 'monospace'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
