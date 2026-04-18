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
        margin: const EdgeInsets.fromLTRB(10, 6, 10, 0),
        padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
        decoration: BoxDecoration(
          color: AppColors.amber.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.amber.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(color: AppColors.amber.withValues(alpha: 0.08), blurRadius: 16),
          ],
        ),
        child: Column(children: [
          Row(children: [
            Icon(Icons.bolt_rounded, color: AppColors.amber,
                size: 18, shadows: [Shadow(color: AppColors.amber.withValues(alpha: 0.6), blurRadius: 8)]),
            const SizedBox(width: 8),
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Agent needs approval',
                  style: TextStyle(color: AppColors.amber,
                      fontFamily: 'monospace', fontSize: 11.5, fontWeight: FontWeight.w600,
                      shadows: [Shadow(color: Color(0x80FFAA00), blurRadius: 4)])),
                SizedBox(height: 2),
                Text('Respond to the prompt below',
                  style: TextStyle(color: Color(0xFFAA8840),
                      fontFamily: 'monospace', fontSize: 10)),
              ]),
            ),
            GestureDetector(
              onTap: _dismiss,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close, color: AppColors.textMuted, size: 14),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _btn('Y', AppColors.green, () => _respond('y'), filled: true)),
            const SizedBox(width: 8),
            Expanded(child: _btn('N', AppColors.red, () => _respond('n'))),
          ]),
        ]),
      ),
    );
  }

  Widget _btn(String label, Color color, VoidCallback onTap, {bool filled = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? color.withValues(alpha: 0.2) : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: filled ? 0.6 : 0.3)),
          boxShadow: filled ? [
            BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 12),
          ] : null,
        ),
        child: Text(label,
            style: TextStyle(
              color: color,
              fontFamily: 'monospace', fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 2,
              shadows: filled ? [Shadow(color: color.withValues(alpha: 0.6), blurRadius: 6)] : null,
            )),
      ),
    );
  }
}
