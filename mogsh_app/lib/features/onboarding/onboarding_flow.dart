import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../terminal/services/pterm_service.dart';
import '../terminal/setup_screen.dart';
import 'tool_installer_page.dart';
import 'tool_installer_service.dart';

enum OnboardingPath { local, ssh }

class OnboardingFlow extends StatefulWidget {
  final VoidCallback onComplete;
  const OnboardingFlow({super.key, required this.onComplete});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  int _step = 0;
  OnboardingPath? _path;
  final _ptermService = PtermService();
  final _toolService = ToolInstallerService();

  @override
  void initState() { super.initState(); _toolService.init(); }

  @override
  void dispose() { _ptermService.dispose(); _toolService.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(child: _buildStep()),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0: return _PathChooser(onChoose: (p) => setState(() { _path = p; _step = 1; }));
      case 1:
        if (_path == OnboardingPath.local) {
          return FutureBuilder<bool>(
            future: _ptermService.needsSetup(),
            builder: (_, snap) {
              if (snap.data == true) {
                return SetupScreen(
                  service: _ptermService,
                  onComplete: () => setState(() => _step = 2),
                );
              }
              return _buildStep2();
            },
          );
        }
        return _SshOnboardingStep(onDone: widget.onComplete);
      case 2: return _buildStep2();
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildStep2() => ToolInstallerPage(
    service: _toolService,
    onDone: widget.onComplete,
  );
}

class _PathChooser extends StatelessWidget {
  final ValueChanged<OnboardingPath> onChoose;
  const _PathChooser({required this.onChoose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('mogsh', style: TextStyle(
              color: AppColors.primary, fontSize: 32, fontFamily: 'monospace', letterSpacing: 4)),
          const SizedBox(height: 8),
          const Text('Where do you want to code?',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 48),
          _PathCard(
            icon: Icons.phone_android,
            title: 'On this device',
            subtitle: 'Local Linux environment\nNode.js · Python · Git · Claude Code',
            color: AppColors.primary,
            onTap: () => onChoose(OnboardingPath.local),
          ),
          const SizedBox(height: 16),
          _PathCard(
            icon: Icons.dns_outlined,
            title: 'Remote server',
            subtitle: 'SSH into your VPS or homelab\nConnect in under 2 minutes',
            color: AppColors.secondary,
            onTap: () => onChoose(OnboardingPath.ssh),
          ),
        ],
      ),
    );
  }
}

class _PathCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _PathCard({required this.icon, required this.title,
      required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 15)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, height: 1.5)),
          ])),
          Icon(Icons.arrow_forward_ios, color: color.withOpacity(0.5), size: 14),
        ]),
      ),
    );
  }
}

class _SshOnboardingStep extends StatelessWidget {
  final VoidCallback onDone;
  const _SshOnboardingStep({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.dns_outlined, color: AppColors.secondary, size: 48),
        const SizedBox(height: 24),
        const Text('Add your first server', style: TextStyle(
            color: Colors.white, fontFamily: 'monospace', fontSize: 18)),
        const SizedBox(height: 8),
        const Text('You can add servers later from the server list.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12), textAlign: TextAlign.center),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: onDone,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.secondary),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text('Go to server list',
                style: TextStyle(color: AppColors.secondary, fontFamily: 'monospace')),
          ),
        ),
      ]),
    );
  }
}
