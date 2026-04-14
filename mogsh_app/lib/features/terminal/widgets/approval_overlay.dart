import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';

/// Detects y/n prompts in terminal output and shows approval banner.
class ApprovalDetector {
  // Patterns that trigger the overlay
  static final _patterns = [
    RegExp(r'\(y[/|\\]n\)', caseSensitive: false),
    RegExp(r'\[y[/|\\]n\]', caseSensitive: false),
    RegExp(r'\(yes[/|\\]no\)', caseSensitive: false),
    RegExp(r'continue\?', caseSensitive: false),
    RegExp(r'are you sure', caseSensitive: false),
    RegExp(r'proceed\?', caseSensitive: false),
  ];

  static bool shouldTrigger(String text) =>
      _patterns.any((p) => p.hasMatch(text));
}

class ApprovalOverlay extends StatefulWidget {
  final Stream<String> terminalOutput;
  final void Function(String) onSend; // sends y\n or n\n
  final bool enabled;

  const ApprovalOverlay({
    super.key,
    required this.terminalOutput,
    required this.onSend,
    this.enabled = true,
  });

  @override
  State<ApprovalOverlay> createState() => _ApprovalOverlayState();
}

class _ApprovalOverlayState extends State<ApprovalOverlay>
    with SingleTickerProviderStateMixin {
  bool _visible = false;
  StreamSubscription<String>? _sub;
  late final AnimationController _anim;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _slide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));

    _sub = widget.terminalOutput.listen((data) {
      if (widget.enabled && ApprovalDetector.shouldTrigger(data) && !_visible) {
        setState(() => _visible = true);
        _anim.forward();
      }
    });
  }

  @override
  void dispose() { _sub?.cancel(); _anim.dispose(); super.dispose(); }

  void _respond(String response) {
    HapticFeedback.mediumImpact();
    widget.onSend('$response\n');
    _dismiss();
  }

  void _dismiss() {
    _anim.reverse().then((_) {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    return SlideTransition(
      position: _slide,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: AppColors.surface2,
        child: Row(children: [
          const Icon(Icons.help_outline, color: AppColors.warning, size: 16),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('Approval required',
                style: TextStyle(color: AppColors.textSecondary,
                    fontFamily: 'monospace', fontSize: 12)),
          ),
          _btn('  Y  ', AppColors.primary, () => _respond('y')),
          const SizedBox(width: 8),
          _btn('  N  ', AppColors.danger, () => _respond('n')),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _dismiss,
            child: const Icon(Icons.close, color: AppColors.textMuted, size: 16),
          ),
        ]),
      ),
    );
  }

  Widget _btn(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.7)),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(label,
            style: TextStyle(color: color, fontFamily: 'monospace',
                fontSize: 13, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
