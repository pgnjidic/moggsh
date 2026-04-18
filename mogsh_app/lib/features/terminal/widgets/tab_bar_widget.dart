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

  const MogshTabBar({
    super.key,
    required this.tabs,
    required this.activeIndex,
    required this.onSwitch,
    required this.onClose,
    required this.onRename,
    this.onAddTab,
  });

  Color _dotColor(SessionState state) => switch (state) {
    SessionState.connecting => AppColors.amber,
    SessionState.active     => AppColors.green,
    SessionState.idle       => AppColors.amber,
    SessionState.offline    => AppColors.red,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      color: AppColors.bgDark,
      child: Row(children: [
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            itemCount: tabs.length,
            itemBuilder: (_, i) => _TabPill(
              tab: tabs[i],
              isActive: i == activeIndex,
              dotColor: _dotColor(tabs[i].sessionState),
              onTap: () { HapticFeedback.selectionClick(); onSwitch(i); },
              onLongPress: () => _showRenameDialog(context, tabs[i]),
              onClose: () => onClose(tabs[i].id),
            ),
          ),
        ),
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

class _TabPill extends StatelessWidget {
  final TerminalTab tab;
  final bool isActive;
  final Color dotColor;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onClose;

  const _TabPill({
    required this.tab, required this.isActive, required this.dotColor,
    required this.onTap, required this.onLongPress, required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        constraints: const BoxConstraints(minWidth: 80, maxWidth: 160),
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.green.withValues(alpha: 0.12)
              : AppColors.surface2.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive
                ? AppColors.green.withValues(alpha: 0.35)
                : AppColors.border.withValues(alpha: 0.4),
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          // Status dot with glow when active
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor,
              boxShadow: isActive
                  ? [BoxShadow(color: dotColor.withValues(alpha: 0.8), blurRadius: 5)]
                  : null,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(tab.title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isActive ? AppColors.teal : AppColors.textMuted,
                fontSize: 11,
                fontFamily: 'monospace',
                fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onClose,
            child: Icon(Icons.close, size: 11,
                color: isActive ? AppColors.teal.withValues(alpha: 0.6) : AppColors.textMuted.withValues(alpha: 0.4)),
          ),
        ]),
      ),
    );
  }
}
