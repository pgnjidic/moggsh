import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  static const _bg      = Color(0xFF0A0A0F);
  static const _green   = Color(0xFF00FF88);
  static const _muted   = Color(0xFF444466);

  Color _dotColor(SessionState state) {
    return switch (state) {
      SessionState.connecting => const Color(0xFFFFD700),
      SessionState.active     => _green,
      SessionState.idle       => const Color(0xFFFFD700),
      SessionState.offline    => const Color(0xFFFF5555),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      color: _bg,
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              itemBuilder: (_, i) => _TabChip(
                tab: tabs[i],
                isActive: i == activeIndex,
                dotColor: _dotColor(tabs[i].sessionState),
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSwitch(i);
                },
                onLongPress: () => _showRenameDialog(context, tabs[i]),
                onClose: tabs.length > 1 ? () => onClose(tabs[i].id) : null,
              ),
            ),
          ),
          if (onAddTab != null)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onAddTab!();
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.add, color: _muted, size: 18),
              ),
            ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, TerminalTab tab) {
    HapticFeedback.mediumImpact();
    final ctrl = TextEditingController(text: tab.title);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF12121A),
        title: const Text('Rename tab',
            style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'monospace')),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF00FF88))),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF00FF88))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF666688))),
          ),
          TextButton(
            onPressed: () {
              onRename(ctrl.text.trim().isEmpty ? tab.title : ctrl.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Rename', style: TextStyle(color: Color(0xFF00FF88))),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final TerminalTab tab;
  final bool isActive;
  final Color dotColor;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback? onClose;

  const _TabChip({
    required this.tab,
    required this.isActive,
    required this.dotColor,
    required this.onTap,
    required this.onLongPress,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        constraints: const BoxConstraints(minWidth: 80, maxWidth: 140),
        margin: const EdgeInsets.only(top: 4, bottom: 0, left: 2, right: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF12121A) : Colors.transparent,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          border: isActive
              ? Border.all(color: const Color(0xFF1E1E2E))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6, height: 6,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                tab.title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isActive ? Colors.white : const Color(0xFF666688),
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            if (onClose != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onClose,
                child: const Icon(Icons.close, size: 12, color: Color(0xFF444466)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
