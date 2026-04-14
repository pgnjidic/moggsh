import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// FAB that appears when user scrolls up — tapping scrolls to last prompt
class ScrollToPromptFab extends StatelessWidget {
  final VoidCallback onTap;
  const ScrollToPromptFab({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.4)),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 12)],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: const [
          Icon(Icons.keyboard_double_arrow_down, color: AppColors.primary, size: 14),
          SizedBox(width: 6),
          Text('Scroll to prompt',
              style: TextStyle(color: AppColors.primary, fontSize: 11, fontFamily: 'monospace')),
        ]),
      ),
    );
  }
}

/// Wraps terminal content so keyboard resize doesn't push terminal up.
/// Uses [MediaQuery.viewInsets] to detect keyboard and adjusts bottom padding only.
class KeyboardResistantTerminal extends StatelessWidget {
  final Widget terminal;
  final Widget shortcutBar;
  final Widget? fab;
  final bool showFab;

  const KeyboardResistantTerminal({
    super.key,
    required this.terminal,
    required this.shortcutBar,
    this.fab,
    this.showFab = false,
  });

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return Stack(
      children: [
        Column(
          children: [
            // Terminal takes all space — keyboard doesn't push it
            Expanded(child: terminal),
            // Shortcut bar stays above keyboard
            AnimatedPadding(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.only(bottom: keyboardHeight),
              child: shortcutBar,
            ),
          ],
        ),
        if (showFab && fab != null)
          Positioned(
            bottom: keyboardHeight + 48,
            left: 0, right: 0,
            child: Center(child: fab),
          ),
      ],
    );
  }
}
