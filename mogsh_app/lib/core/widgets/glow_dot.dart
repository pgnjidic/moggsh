import 'package:flutter/material.dart';

/// Animated pulsing status dot — 2s loop
class GlowDot extends StatefulWidget {
  final Color color;
  final double size;
  final bool animate;

  const GlowDot({super.key, required this.color, this.size = 8, this.animate = true});

  @override
  State<GlowDot> createState() => _GlowDotState();
}

class _GlowDotState extends State<GlowDot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _glow = Tween<double>(begin: 2, end: 8).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return _dot(4);
    }
    return AnimatedBuilder(
      animation: _glow,
      builder: (_, __) => _dot(_glow.value),
    );
  }

  Widget _dot(double blur) => Container(
    width: widget.size,
    height: widget.size,
    decoration: BoxDecoration(
      color: widget.color,
      shape: BoxShape.circle,
      boxShadow: [BoxShadow(color: widget.color.withOpacity(0.7), blurRadius: blur, spreadRadius: 1)],
    ),
  );
}

/// Neon-bordered button
class NeonButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool filled;

  const NeonButton({super.key, required this.label, required this.color,
      required this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: filled ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withOpacity(0.8)),
          boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 8, spreadRadius: 0)],
        ),
        child: Text(label, style: TextStyle(
          color: filled ? const Color(0xFF0A0A0F) : color,
          fontFamily: 'monospace', fontSize: 13, letterSpacing: 0.5,
        )),
      ),
    );
  }
}

/// Cyberpunk card container
class CyberCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? borderColor;

  const CyberCard({super.key, required this.child, this.padding, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF12121A),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor ?? const Color(0xFF1E1E2E)),
      ),
      child: child,
    );
  }
}
