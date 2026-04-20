import 'package:flutter/material.dart';

class TmuxPickerSheet extends StatelessWidget {
  final List<String> sessions;
  final ValueChanged<String?> onSelect; // null = new shell

  const TmuxPickerSheet({super.key, required this.sessions, required this.onSelect});

  static const _green = Color(0xFF00FF88);
  static const _bg    = Color(0xFF12121A);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('tmux sessions',
              style: TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 14)),
          const SizedBox(height: 12),
          ...sessions.map((s) => ListTile(
            dense: true,
            leading: const Icon(Icons.terminal, color: _green, size: 16),
            title: Text(s,
                style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 13)),
            trailing: const Text('attach',
                style: TextStyle(color: _green, fontSize: 11, fontFamily: 'monospace')),
            onTap: () { Navigator.pop(context); onSelect(s); },
          )),
          const Divider(color: Color(0xFF1E1E2E)),
          ListTile(
            dense: true,
            leading: const Icon(Icons.add, color: Color(0xFF666688), size: 16),
            title: const Text('New shell',
                style: TextStyle(color: Color(0xFF888899), fontFamily: 'monospace', fontSize: 13)),
            onTap: () { Navigator.pop(context); onSelect(null); },
          ),
        ],
      ),
    );
  }
}
