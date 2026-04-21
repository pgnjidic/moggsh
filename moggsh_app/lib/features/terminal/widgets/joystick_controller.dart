import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';

/// Gamepad-style controller: D-pad left, voice center, action cluster right,
/// and an always-on essentials strip (Ctrl+C/D/L + snippet gear).
///
/// In landscape collapses to a single 44 px row.
Future<void> _pasteClipboard(ValueChanged<String> onSend) async {
  final data = await Clipboard.getData(Clipboard.kTextPlain);
  final text = data?.text;
  if (text != null && text.isNotEmpty) onSend(text);
}

class JoystickController extends StatelessWidget {
  final ValueChanged<String> onSend;
  final Widget voiceBtn;
  final VoidCallback onOpenSnippets;
  final VoidCallback? onCopy;
  final bool copyModeActive;
  final bool landscape;

  const JoystickController({
    super.key,
    required this.onSend,
    required this.voiceBtn,
    required this.onOpenSnippets,
    this.onCopy,
    this.copyModeActive = false,
    this.landscape = false,
  });

  @override
  Widget build(BuildContext context) {
    return landscape ? _landscape() : _portrait();
  }

  // ── Portrait: two rows (joystick + essentials) ─────────────────────────────
  Widget _portrait() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(
        height: 100,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _DPad(onSend: onSend),
            const Spacer(),
            Center(child: voiceBtn),
            const Spacer(),
            _ActionCluster(onSend: onSend),
          ],
        ),
      ),
      const SizedBox(height: 8),
      _EssentialsStrip(onSend: onSend, onOpenSnippets: onOpenSnippets, onCopy: onCopy, copyModeActive: copyModeActive),
    ]);
  }

  // ── Landscape: single compact row ──────────────────────────────────────────
  Widget _landscape() {
    return SizedBox(
      height: 44,
      child: Row(children: [
        _JoystickBtn(
          label: 'Ctrl+C',
          color: AppColors.red,
          haptic: HapticFeedback.heavyImpact,
          onTap: () => onSend('\x03'),
          width: 60,
        ),
        const SizedBox(width: 6),
        _JoystickBtn(
          icon: Icons.arrow_upward_rounded,
          color: AppColors.teal,
          haptic: HapticFeedback.selectionClick,
          onTap: () => onSend('\x1b[A'),
        ),
        _JoystickBtn(
          icon: Icons.arrow_downward_rounded,
          color: AppColors.teal,
          haptic: HapticFeedback.selectionClick,
          onTap: () => onSend('\x1b[B'),
        ),
        _JoystickBtn(
          icon: Icons.arrow_back_rounded,
          color: AppColors.teal,
          haptic: HapticFeedback.selectionClick,
          onTap: () => onSend('\x1b[D'),
        ),
        _JoystickBtn(
          icon: Icons.arrow_forward_rounded,
          color: AppColors.teal,
          haptic: HapticFeedback.selectionClick,
          onTap: () => onSend('\x1b[C'),
        ),
        const SizedBox(width: 6),
        SizedBox(width: 38, height: 38, child: voiceBtn),
        const SizedBox(width: 6),
        _JoystickBtn(
          icon: Icons.keyboard_return_rounded,
          color: AppColors.green,
          haptic: HapticFeedback.mediumImpact,
          onTap: () => onSend('\r'),
        ),
        _JoystickBtn(
          label: 'Esc',
          color: AppColors.amber,
          haptic: HapticFeedback.mediumImpact,
          onTap: () => onSend('\x1b'),
        ),
        _JoystickBtn(
          label: 'Tab',
          color: AppColors.teal,
          haptic: HapticFeedback.mediumImpact,
          onTap: () => onSend('\t'),
        ),
        const SizedBox(width: 6),
        _JoystickBtn(
          label: 'Copy',
          color: copyModeActive ? AppColors.green : AppColors.textMuted,
          haptic: HapticFeedback.mediumImpact,
          onTap: () { if (onCopy != null) onCopy!(); },
          width: 50,
        ),
        _JoystickBtn(
          label: 'Paste',
          color: AppColors.textMuted,
          haptic: HapticFeedback.mediumImpact,
          onTap: () { _pasteClipboard(onSend); },
          width: 50,
        ),
        const SizedBox(width: 6),
        _JoystickBtn(
          label: '1',
          color: AppColors.amber,
          haptic: HapticFeedback.selectionClick,
          onTap: () => onSend('1\r'),
          width: 38,
        ),
        const SizedBox(width: 4),
        _JoystickBtn(
          label: '2',
          color: AppColors.amber,
          haptic: HapticFeedback.selectionClick,
          onTap: () => onSend('2\r'),
          width: 38,
        ),
        const SizedBox(width: 4),
        _JoystickBtn(
          label: '3',
          color: AppColors.amber,
          haptic: HapticFeedback.selectionClick,
          onTap: () => onSend('3\r'),
          width: 38,
        ),
        const Spacer(),
        _JoystickBtn(
          icon: Icons.tune_rounded,
          color: AppColors.textMuted,
          haptic: HapticFeedback.selectionClick,
          onTap: onOpenSnippets,
        ),
      ]),
    );
  }
}

// ── D-pad cross ─────────────────────────────────────────────────────────────

class _DPad extends StatelessWidget {
  final ValueChanged<String> onSend;
  const _DPad({required this.onSend});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      height: 100,
      child: Stack(alignment: Alignment.center, children: [
        Positioned(
          top: 0,
          child: _JoystickBtn(
            icon: Icons.arrow_upward_rounded,
            color: AppColors.teal,
            haptic: HapticFeedback.selectionClick,
            onTap: () => onSend('\x1b[A'),
          ),
        ),
        Positioned(
          bottom: 0,
          child: _JoystickBtn(
            icon: Icons.arrow_downward_rounded,
            color: AppColors.teal,
            haptic: HapticFeedback.selectionClick,
            onTap: () => onSend('\x1b[B'),
          ),
        ),
        Positioned(
          left: 0,
          child: _JoystickBtn(
            icon: Icons.arrow_back_rounded,
            color: AppColors.teal,
            haptic: HapticFeedback.selectionClick,
            onTap: () => onSend('\x1b[D'),
          ),
        ),
        Positioned(
          right: 0,
          child: _JoystickBtn(
            icon: Icons.arrow_forward_rounded,
            color: AppColors.teal,
            haptic: HapticFeedback.selectionClick,
            onTap: () => onSend('\x1b[C'),
          ),
        ),
      ]),
    );
  }
}

// ── Right-hand action cluster: Enter / Esc / Tab stacked ────────────────────

class _ActionCluster extends StatelessWidget {
  final ValueChanged<String> onSend;
  const _ActionCluster({required this.onSend});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      height: 100,
      child: Stack(alignment: Alignment.center, children: [
        Positioned(
          top: 0,
          child: _JoystickBtn(
            icon: Icons.keyboard_return_rounded,
            color: AppColors.green,
            haptic: HapticFeedback.mediumImpact,
            onTap: () => onSend('\r'),
          ),
        ),
        Positioned(
          left: 0,
          child: _JoystickBtn(
            label: 'Esc',
            color: AppColors.amber,
            haptic: HapticFeedback.mediumImpact,
            onTap: () => onSend('\x1b'),
          ),
        ),
        Positioned(
          right: 0,
          child: _JoystickBtn(
            label: 'Tab',
            color: AppColors.teal,
            haptic: HapticFeedback.mediumImpact,
            onTap: () => onSend('\t'),
          ),
        ),
      ]),
    );
  }
}

// ── Bottom essentials strip ────────────────────────────────────────────────

class _EssentialsStrip extends StatelessWidget {
  final ValueChanged<String> onSend;
  final VoidCallback onOpenSnippets;
  final VoidCallback? onCopy;
  final bool copyModeActive;
  const _EssentialsStrip({required this.onSend, required this.onOpenSnippets, this.onCopy, this.copyModeActive = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(children: [
        Expanded(
          child: _JoystickBtn(
            label: 'Ctrl+C',
            color: AppColors.red,
            haptic: HapticFeedback.heavyImpact,
            onTap: () => onSend('\x03'),
            expand: true,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _JoystickBtn(
            label: 'Copy',
            color: copyModeActive ? AppColors.green : AppColors.textMuted,
            haptic: HapticFeedback.mediumImpact,
            onTap: () { if (onCopy != null) onCopy!(); },
            expand: true,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _JoystickBtn(
            label: 'Paste',
            color: AppColors.textMuted,
            haptic: HapticFeedback.mediumImpact,
            onTap: () { _pasteClipboard(onSend); },
            expand: true,
          ),
        ),
        const SizedBox(width: 6),
        _JoystickBtn(
          label: '1',
          color: AppColors.amber,
          haptic: HapticFeedback.selectionClick,
          onTap: () => onSend('1\r'),
        ),
        const SizedBox(width: 4),
        _JoystickBtn(
          label: '2',
          color: AppColors.amber,
          haptic: HapticFeedback.selectionClick,
          onTap: () => onSend('2\r'),
        ),
        const SizedBox(width: 4),
        _JoystickBtn(
          label: '3',
          color: AppColors.amber,
          haptic: HapticFeedback.selectionClick,
          onTap: () => onSend('3\r'),
        ),
        const SizedBox(width: 6),
        _JoystickBtn(
          icon: Icons.tune_rounded,
          color: AppColors.textMuted,
          haptic: HapticFeedback.selectionClick,
          onTap: onOpenSnippets,
        ),
      ]),
    );
  }
}

// ── Button primitive ───────────────────────────────────────────────────────

class _JoystickBtn extends StatefulWidget {
  final String? label;
  final IconData? icon;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback haptic;
  final double? width;
  final bool expand;

  const _JoystickBtn({
    this.label,
    this.icon,
    required this.color,
    required this.onTap,
    required this.haptic,
    this.width,
    this.expand = false,
  }) : assert(label != null || icon != null);

  @override
  State<_JoystickBtn> createState() => _JoystickBtnState();
}

class _JoystickBtnState extends State<_JoystickBtn> {
  bool _pressed = false;

  void _handleTap() {
    widget.haptic();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color;
    final glow = _pressed ? 14.0 : 4.0;
    return GestureDetector(
      onTap: _handleTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 80),
        scale: _pressed ? 0.92 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          width: widget.expand ? null : (widget.width ?? 38),
          height: 38,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: _pressed ? 0.28 : 0.14),
                color.withValues(alpha: 0.04),
              ],
            ),
            border: Border.all(color: color.withValues(alpha: 0.45), width: 1.2),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.28), blurRadius: glow),
            ],
          ),
          alignment: Alignment.center,
          child: widget.icon != null
              ? Icon(widget.icon, size: 20, color: color)
              : Text(
                  widget.label!,
                  style: TextStyle(
                    color: color,
                    fontSize: widget.label!.length > 3 ? 10 : 12,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
