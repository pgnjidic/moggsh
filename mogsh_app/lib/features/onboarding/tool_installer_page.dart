import 'package:flutter/material.dart';
import 'tool_installer_service.dart';

class ToolInstallerPage extends StatefulWidget {
  final ToolInstallerService service;
  final VoidCallback onDone;

  const ToolInstallerPage({super.key, required this.service, required this.onDone});

  @override
  State<ToolInstallerPage> createState() => _ToolInstallerPageState();
}

class _ToolInstallerPageState extends State<ToolInstallerPage> {
  static const _bg      = Color(0xFF0A0A0F);
  static const _surface = Color(0xFF12121A);
  static const _green   = Color(0xFF00FF88);
  static const _cyan    = Color(0xFF00D4FF);
  static const _red     = Color(0xFFFF5555);
  static const _muted   = Color(0xFF666688);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: StreamBuilder<List<CliTool>>(
          stream: widget.service.toolsStream,
          initialData: widget.service.tools,
          builder: (context, snapshot) {
            final tools = snapshot.data ?? [];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: tools.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _ToolCard(
                      tool: tools[i],
                      onInstall: () => widget.service.install(tools[i]),
                      onAuth: () => widget.service.authenticate(tools[i]),
                    ),
                  ),
                ),
                _footer(tools),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Install tools',
              style: TextStyle(color: _green, fontSize: 22, fontFamily: 'monospace', letterSpacing: 1)),
          SizedBox(height: 4),
          Text('One tap to get your dev environment ready.',
              style: TextStyle(color: _muted, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _footer(List<CliTool> tools) {
    final anyInstalled = tools.any((t) => t.state == InstallState.installed);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: widget.onDone,
            child: const Text('Skip', style: TextStyle(color: _muted, fontFamily: 'monospace')),
          ),
          if (anyInstalled)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: _bg,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: widget.onDone,
              child: const Text('Open terminal', style: TextStyle(fontFamily: 'monospace')),
            ),
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final CliTool tool;
  final VoidCallback onInstall;
  final Future<String?> Function() onAuth;

  const _ToolCard({required this.tool, required this.onInstall, required this.onAuth});

  static const _bg      = Color(0xFF0A0A0F);
  static const _surface = Color(0xFF12121A);
  static const _green   = Color(0xFF00FF88);
  static const _cyan    = Color(0xFF00D4FF);
  static const _red     = Color(0xFFFF5555);
  static const _muted   = Color(0xFF666688);
  static const _border  = Color(0xFF1E1E2E);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(tool.label,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'monospace')),
                  if (tool.state == InstallState.installed) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: _green.withOpacity(0.4)),
                      ),
                      child: Text(tool.version ?? '✓',
                          style: const TextStyle(color: _green, fontSize: 10, fontFamily: 'monospace')),
                    ),
                  ],
                  if (tool.state == InstallState.failed) ...[
                    const SizedBox(width: 8),
                    const Text('Failed', style: TextStyle(color: _red, fontSize: 11, fontFamily: 'monospace')),
                  ],
                ]),
                const SizedBox(height: 2),
                Text(tool.description, style: const TextStyle(color: _muted, fontSize: 12)),
                if (tool.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(tool.error!,
                        style: const TextStyle(color: _red, fontSize: 10, fontFamily: 'monospace'),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _ActionButton(tool: tool, onInstall: onInstall, onAuth: onAuth),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final CliTool tool;
  final VoidCallback onInstall;
  final Future<String?> Function() onAuth;

  const _ActionButton({required this.tool, required this.onInstall, required this.onAuth});

  static const _green  = Color(0xFF00FF88);
  static const _cyan   = Color(0xFF00D4FF);
  static const _red    = Color(0xFFFF5555);
  static const _muted  = Color(0xFF666688);
  static const _bg     = Color(0xFF0A0A0F);

  @override
  Widget build(BuildContext context) {
    switch (tool.state) {
      case InstallState.installing:
        return const SizedBox(
          width: 20, height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: _green),
        );

      case InstallState.installed:
        if (tool.oauthUrl != null) {
          return _btn('Auth', _cyan, onAuth);
        }
        return const Icon(Icons.check_circle_outline, color: _green, size: 20);

      case InstallState.failed:
        return _btn('Retry', _red, () => onInstall());

      case InstallState.idle:
        return _btn('Install', _green, () => onInstall());
    }
  }

  Widget _btn(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.7)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label,
            style: TextStyle(color: color, fontSize: 12, fontFamily: 'monospace')),
      ),
    );
  }
}
