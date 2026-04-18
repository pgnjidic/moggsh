import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../tabs/terminal_tab.dart';

class MogshTabBar extends StatelessWidget {
  final List<TerminalTab> tabs;
  final int activeIndex;
  final ValueChanged<int> onSwitch;
  final ValueChanged<String> onClose;
  final ValueChanged<String> onRename;
  final VoidCallback? onAddTab;
  final bool compact;
  final Widget? trailing;

  const MogshTabBar({
    super.key,
    required this.tabs,
    required this.activeIndex,
    required this.onSwitch,
    required this.onClose,
    required this.onRename,
    this.onAddTab,
    this.compact = false,
    this.trailing,
  });

  Color _dotColor(SessionState state) => switch (state) {
    SessionState.connecting => AppColors.amber,
    SessionState.active     => AppColors.green,
    SessionState.idle       => AppColors.amber,
    SessionState.offline    => AppColors.red,
  };

  @override
  Widget build(BuildContext context) {
    final h = compact ? 34.0 : 46.0;
    final vPad = compact ? 4.0 : 7.0;
    return Container(
      height: h,
      decoration: const BoxDecoration(
        color: AppColors.bgDark,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(children: [
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: vPad),
            itemCount: tabs.length,
            itemBuilder: (_, i) => _TabPill(
              tab: tabs[i],
              isActive: i == activeIndex,
              dotColor: _dotColor(tabs[i].sessionState),
              compact: compact,
              onTap: () { HapticFeedback.selectionClick(); onSwitch(i); },
              onLongPress: () => _showRenameDialog(context, tabs[i]),
              onClose: () => onClose(tabs[i].id),
            ),
          ),
        ),
        ?trailing,
      ]),
    );
  }

  void _showRenameDialog(BuildContext context, TerminalTab tab) {
    HapticFeedback.mediumImpact();
    final ctrl = TextEditingController(text: tab.title);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Rename tab',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontFamily: 'monospace')),
        content: TextField(
          controller: ctrl, autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'monospace'),
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.green)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted))),
          TextButton(
            onPressed: () {
              onRename(ctrl.text.trim().isEmpty ? tab.title : ctrl.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Rename', style: TextStyle(color: AppColors.green)),
          ),
        ],
      ),
    );
  }
}

class _TabPill extends StatefulWidget {
  final TerminalTab tab;
  final bool isActive;
  final Color dotColor;
  final bool compact;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onClose;

  const _TabPill({
    required this.tab, required this.isActive, required this.dotColor,
    required this.compact,
    required this.onTap, required this.onLongPress, required this.onClose,
  });

  @override
  State<_TabPill> createState() => _TabPillState();
}

class _TabPillState extends State<_TabPill> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connecting = widget.tab.sessionState == SessionState.connecting;
    final hPad = widget.compact ? 10.0 : 12.0;
    final vPad = widget.compact ? 3.0 : 5.0;
    final fontSize = widget.compact ? 11.0 : 12.0;
    final dotSize = widget.compact ? 7.0 : 6.0;

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Container(
        constraints: BoxConstraints(minWidth: widget.compact ? 80 : 90, maxWidth: 180),
        margin: const EdgeInsets.only(right: 6),
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
        decoration: BoxDecoration(
          color: widget.isActive
              ? AppColors.green.withValues(alpha: 0.14)
              : AppColors.surface2.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.isActive
                ? AppColors.green.withValues(alpha: 0.45)
                : AppColors.border.withValues(alpha: 0.4),
          ),
          boxShadow: widget.isActive ? [
            BoxShadow(color: AppColors.green.withValues(alpha: 0.12), blurRadius: 10),
          ] : null,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, _) {
              final pulseOpacity = connecting ? (0.4 + _pulseCtrl.value * 0.6) : 1.0;
              final blurAmount = connecting
                  ? (6.0 + _pulseCtrl.value * 6.0)
                  : (widget.isActive ? 6.0 : 0.0);
              return Container(
                width: dotSize, height: dotSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.dotColor.withValues(alpha: pulseOpacity),
                  boxShadow: (widget.isActive || connecting)
                      ? [BoxShadow(color: widget.dotColor.withValues(alpha: 0.8), blurRadius: blurAmount)]
                      : null,
                ),
              );
            },
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(widget.tab.title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: widget.isActive ? AppColors.teal : AppColors.textMuted,
                fontSize: fontSize,
                fontFamily: 'monospace',
                fontWeight: widget.isActive ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: (widget.isActive ? AppColors.green : AppColors.textMuted).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text('CC', style: TextStyle(
              color: widget.isActive ? AppColors.green : AppColors.textMuted,
              fontSize: 8, fontFamily: 'monospace', fontWeight: FontWeight.w600, letterSpacing: 0.3,
            )),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: widget.onClose,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(Icons.close, size: 12,
                  color: widget.isActive ? AppColors.teal.withValues(alpha: 0.7) : AppColors.textMuted.withValues(alpha: 0.5)),
            ),
          ),
        ]),
      ),
    );
  }
}
