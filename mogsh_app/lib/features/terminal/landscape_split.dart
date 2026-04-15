import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'tabs/terminal_tab.dart';
import 'terminal_widget.dart';

/// Landscape split-pane: two independent terminals side-by-side with draggable divider
class LandscapeSplitView extends StatefulWidget {
  final TerminalTab leftTab;
  final TerminalTab rightTab;

  const LandscapeSplitView({super.key, required this.leftTab, required this.rightTab});

  @override
  State<LandscapeSplitView> createState() => _LandscapeSplitViewState();
}

class _LandscapeSplitViewState extends State<LandscapeSplitView> {
  double _splitRatio = 0.5; // 30%–70%
  final _leftKey  = GlobalKey<TerminalWidgetState>();
  final _rightKey = GlobalKey<TerminalWidgetState>();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      final totalWidth = constraints.maxWidth;
      final leftWidth  = (totalWidth * _splitRatio).clamp(
          totalWidth * 0.3, totalWidth * 0.7);

      return Row(children: [
        // Left terminal
        SizedBox(
          width: leftWidth,
          child: TerminalWidget(
            key: _leftKey,
            onReady: () => widget.leftTab.output.listen(
                (d) => _leftKey.currentState?.write(d)),
            onInput: widget.leftTab.sendInput,
            onResize: widget.leftTab.resize,
          ),
        ),

        // Draggable divider
        GestureDetector(
          onHorizontalDragUpdate: (d) {
            final newRatio = (_splitRatio + d.delta.dx / totalWidth)
                .clamp(0.3, 0.7);
            setState(() => _splitRatio = newRatio);
          },
          child: Container(
            width: 4,
            color: AppColors.border2,
            child: Center(
              child: Container(
                width: 2, height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),
        ),

        // Right terminal
        Expanded(
          child: TerminalWidget(
            key: _rightKey,
            onReady: () => widget.rightTab.output.listen(
                (d) => _rightKey.currentState?.write(d)),
            onInput: widget.rightTab.sendInput,
            onResize: widget.rightTab.resize,
          ),
        ),
      ]);
    });
  }
}
