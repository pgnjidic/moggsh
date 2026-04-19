import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../services/prompt_detector.dart';

/// Collapsible row that surfaces big context-aware buttons driven by
/// [PromptContext]. When [ctx.type] is [PromptType.none] the row animates to
/// height 0 so the joystick below moves up.
class ContextRow extends StatelessWidget {
  final PromptContext ctx;
  final ValueChanged<String> onSend;
  final bool compact;

  const ContextRow({
    super.key,
    required this.ctx,
    required this.onSend,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: ctx.type == PromptType.none
          ? const SizedBox(width: double.infinity, height: 0)
          : Padding(
              padding: EdgeInsets.only(bottom: compact ? 4 : 6),
              child: _buildForType(context),
            ),
    );
  }

  Widget _buildForType(BuildContext context) {
    switch (ctx.type) {
      case PromptType.yesNo:
        return _yesNoRow();
      case PromptType.numbered:
        return _numberedRow();
      case PromptType.claudeCode:
        return _claudeCodeRow();
      case PromptType.none:
        return const SizedBox.shrink();
    }
  }

  void _handle(PromptOption opt) {
    HapticFeedback.mediumImpact();
    onSend(opt.key);
  }

  Widget _yesNoRow() {
    final h = compact ? 40.0 : 54.0;
    return SizedBox(
      height: h,
      child: Row(children: [
        for (final opt in ctx.options) ...[
          Expanded(
            child: _BigPillButton(
              label: opt.label,
              hint: opt.hint,
              color: opt.color,
              icon: opt.label == 'Yes' ? Icons.check_rounded : Icons.close_rounded,
              onTap: () => _handle(opt),
              compact: compact,
            ),
          ),
          if (opt != ctx.options.last) const SizedBox(width: 8),
        ],
      ]),
    );
  }

  Widget _numberedRow() {
    final h = compact ? 44.0 : 58.0;
    return SizedBox(
      height: h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ctx.options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final opt = ctx.options[i];
          return _NumberedButton(
            label: opt.label,
            hint: opt.hint,
            color: opt.color,
            onTap: () => _handle(opt),
            compact: compact,
          );
        },
      ),
    );
  }

  Widget _claudeCodeRow() {
    final h = compact ? 36.0 : 44.0;
    return SizedBox(
      height: h,
      child: Row(children: [
        for (final opt in ctx.options) ...[
          _ClaudePill(
            label: opt.label,
            hint: opt.hint,
            color: opt.color,
            onTap: () => _handle(opt),
            compact: compact,
          ),
          if (opt != ctx.options.last) const SizedBox(width: 6),
        ],
        const Spacer(),
      ]),
    );
  }
}

class _BigPillButton extends StatefulWidget {
  final String label;
  final String? hint;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  final bool compact;

  const _BigPillButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
    this.hint,
    this.compact = false,
  });

  @override
  State<_BigPillButton> createState() => _BigPillButtonState();
}

class _BigPillButtonState extends State<_BigPillButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.color;
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 80),
        scale: _pressed ? 0.96 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.22),
                color.withValues(alpha: 0.08),
              ],
            ),
            border: Border.all(color: color.withValues(alpha: 0.55), width: 1.5),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 12),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: color, size: widget.compact ? 18 : 22),
              const SizedBox(width: 8),
              Text(widget.label,
                  style: TextStyle(
                    color: color,
                    fontSize: widget.compact ? 14 : 16,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                  )),
              if (widget.hint != null) ...[
                const SizedBox(width: 6),
                Text('(${widget.hint})',
                    style: TextStyle(
                      color: color.withValues(alpha: 0.6),
                      fontSize: widget.compact ? 10 : 11,
                      fontFamily: 'monospace',
                    )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberedButton extends StatefulWidget {
  final String label;
  final String? hint;
  final Color color;
  final VoidCallback onTap;
  final bool compact;

  const _NumberedButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.hint,
    this.compact = false,
  });

  @override
  State<_NumberedButton> createState() => _NumberedButtonState();
}

class _NumberedButtonState extends State<_NumberedButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.color;
    final circleSize = widget.compact ? 30.0 : 36.0;
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 80),
        scale: _pressed ? 0.94 : 1.0,
        child: Container(
          constraints: BoxConstraints(minWidth: widget.compact ? 64 : 78),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: color.withValues(alpha: 0.1),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.25),
                  border: Border.all(color: color.withValues(alpha: 0.8), width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(widget.label,
                    style: TextStyle(
                      color: color,
                      fontSize: widget.compact ? 13 : 15,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w700,
                    )),
              ),
              if (widget.hint != null && widget.hint!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(widget.hint!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary.withValues(alpha: 0.8),
                      fontSize: widget.compact ? 9 : 10,
                      fontFamily: 'monospace',
                    )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ClaudePill extends StatefulWidget {
  final String label;
  final String? hint;
  final Color color;
  final VoidCallback onTap;
  final bool compact;

  const _ClaudePill({
    required this.label,
    required this.color,
    required this.onTap,
    this.hint,
    this.compact = false,
  });

  @override
  State<_ClaudePill> createState() => _ClaudePillState();
}

class _ClaudePillState extends State<_ClaudePill> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.color;
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 80),
        scale: _pressed ? 0.95 : 1.0,
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: widget.compact ? 10 : 14,
              vertical: widget.compact ? 6 : 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: color.withValues(alpha: 0.15),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (widget.hint != null) ...[
              Text(widget.hint!,
                  style: TextStyle(
                    color: color,
                    fontSize: widget.compact ? 12 : 14,
                    fontFamily: 'monospace',
                  )),
              const SizedBox(width: 6),
            ],
            Text(widget.label,
                style: TextStyle(
                  color: color,
                  fontSize: widget.compact ? 11 : 12,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600,
                )),
          ]),
        ),
      ),
    );
  }
}
