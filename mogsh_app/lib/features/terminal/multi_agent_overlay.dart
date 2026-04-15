import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glow_dot.dart';
import 'tabs/terminal_tab.dart';

enum AgentStatus { idle, running, waiting, done }

class AgentState {
  final String tabId;
  final String tabTitle;
  AgentStatus status;
  bool pinned;

  AgentState({
    required this.tabId,
    required this.tabTitle,
    this.status = AgentStatus.idle,
    this.pinned = false,
  });

  Color get statusColor => switch (status) {
    AgentStatus.running => AppColors.primary,
    AgentStatus.waiting => AppColors.warning,
    AgentStatus.done    => AppColors.secondary,
    AgentStatus.idle    => AppColors.textMuted,
  };
}

class MultiAgentManager extends ChangeNotifier {
  final List<AgentState> agents = [];
  int _focusedIndex = 0;
  bool autoSwitch = true;

  int get focusedIndex => _focusedIndex;

  void addAgent(TerminalTab tab) {
    agents.add(AgentState(tabId: tab.id, tabTitle: tab.title));

    // Watch output for (y/n) prompts → auto-switch
    tab.output.listen((data) {
      final agent = agents.firstWhere((a) => a.tabId == tab.id, orElse: () => agents.first);
      if (data.contains('(y/n)') || data.contains('[y/n]')) {
        agent.status = AgentStatus.waiting;
        if (autoSwitch && !agent.pinned) {
          _focusedIndex = agents.indexOf(agent);
        }
      } else if (data.contains('\$ ')) {
        agent.status = AgentStatus.idle;
      } else if (data.length > 5) {
        agent.status = AgentStatus.running;
      }
      notifyListeners();
    });

    notifyListeners();
  }

  void switchTo(int index) {
    _focusedIndex = index;
    notifyListeners();
  }

  void togglePin(String tabId) {
    final a = agents.firstWhere((a) => a.tabId == tabId);
    a.pinned = !a.pinned;
    notifyListeners();
  }
}

/// 24px status overlay bar showing all agent statuses
class AgentStatusBar extends StatelessWidget {
  final MultiAgentManager manager;
  final ValueChanged<int> onSwitch;

  const AgentStatusBar({super.key, required this.manager, required this.onSwitch});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: manager,
      builder: (_, __) => Container(
        height: 24,
        color: AppColors.bg,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(children: [
          ...manager.agents.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => onSwitch(e.key),
              onLongPress: () => manager.togglePin(e.value.tabId),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                GlowDot(
                  color: e.value.statusColor,
                  size: 6,
                  animate: e.value.status == AgentStatus.running,
                ),
                const SizedBox(width: 4),
                Text(
                  e.value.tabTitle,
                  style: TextStyle(
                    color: e.key == manager.focusedIndex
                        ? Colors.white : AppColors.textMuted,
                    fontFamily: 'monospace', fontSize: 9,
                  ),
                ),
                if (e.value.pinned) const Padding(
                  padding: EdgeInsets.only(left: 2),
                  child: Icon(Icons.push_pin, size: 8, color: AppColors.warning),
                ),
              ]),
            ),
          )),
        ]),
      ),
    );
  }
}
