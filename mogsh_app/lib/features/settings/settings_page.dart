import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'settings_service.dart';

class SettingsPage extends StatefulWidget {
  final SettingsService service;
  const SettingsPage({super.key, required this.service});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  SettingsService get s => widget.service;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(children: [
          _header(),
          Expanded(child: ListView(children: [
            _section('Terminal'),
            _slider('Font size', s.fontSize, 11, 18, (v) => s.set('fontSize', v)),
            _section('Features'),
            _toggle('Quick approval (y/n)', s.approvalMode, (v) => s.set('approvalMode', v)),
            _toggle('Auto-switch to waiting agent', s.autoSwitch, (v) => s.set('autoSwitch', v)),
            _toggle('Landscape split pane', s.landscapeSplit, (v) => s.set('landscapeSplit', v)),
            _section('Privacy'),
            _toggle('Analytics & crash reporting', s.analyticsEnabled, (v) => s.set('analyticsEnabled', v)),
            _section('Account'),
            _action('Clear credentials', AppColors.danger, _confirmClear),
            _action('Re-provision dev tools', AppColors.secondary, _reprovision),
          ])),
        ]),
      ),
    );
  }

  Widget _header() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
    child: Row(children: [
      const Text('settings', style: TextStyle(
          color: AppColors.primary, fontSize: 18, fontFamily: 'monospace', letterSpacing: 2)),
    ]),
  );

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
    child: Text(title.toUpperCase(), style: const TextStyle(
        color: AppColors.textMuted, fontSize: 10, fontFamily: 'monospace', letterSpacing: 2)),
  );

  Widget _toggle(String label, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      dense: true,
      title: Text(label, style: const TextStyle(
          color: AppColors.textPrimary, fontFamily: 'monospace', fontSize: 13)),
      trailing: Switch(
        value: value,
        onChanged: (v) { onChanged(v); setState(() {}); },
        activeThumbColor: AppColors.primary,
        inactiveTrackColor: AppColors.surface2,
      ),
    );
  }

  Widget _slider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(
              color: AppColors.textPrimary, fontFamily: 'monospace', fontSize: 13)),
          Text('${value.round()}px', style: const TextStyle(
              color: AppColors.primary, fontFamily: 'monospace', fontSize: 12)),
        ]),
      ),
      Slider(
        value: value, min: min, max: max, divisions: (max - min).round(),
        activeColor: AppColors.primary,
        inactiveColor: AppColors.surface2,
        onChanged: (v) { onChanged(v.roundToDouble()); setState(() {}); },
      ),
      // Live preview
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
        child: Text('The quick brown fox', style: TextStyle(
            color: AppColors.textSecondary, fontFamily: 'monospace', fontSize: value)),
      ),
    ]);
  }

  Widget _action(String label, Color color, VoidCallback onTap) => ListTile(
    dense: true,
    title: Text(label, style: TextStyle(color: color, fontFamily: 'monospace', fontSize: 13)),
    trailing: Icon(Icons.chevron_right, color: color.withValues(alpha: 0.5), size: 16),
    onTap: onTap,
  );

  void _confirmClear() => showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Clear credentials?', style: TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 14)),
      content: const Text('OAuth tokens will be deleted. You will need to re-authenticate.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted))),
        TextButton(onPressed: () { s.clearCredentials(); Navigator.pop(context); },
            child: const Text('Clear', style: TextStyle(color: AppColors.danger))),
      ],
    ),
  );

  void _reprovision() {
    // Triggers provisioning flow — clears done marker
    s.set('reprovision_requested', true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Re-provisioning on next terminal open',
          style: TextStyle(fontFamily: 'monospace')),
      backgroundColor: AppColors.surface2,
    ));
  }
}
