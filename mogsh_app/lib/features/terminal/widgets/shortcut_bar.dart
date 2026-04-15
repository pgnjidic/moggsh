import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ShortcutBar extends StatefulWidget {
  final void Function(String) onSend;

  const ShortcutBar({super.key, required this.onSend});

  @override
  State<ShortcutBar> createState() => _ShortcutBarState();
}

class _ShortcutBarState extends State<ShortcutBar> {
  static const _storage = FlutterSecureStorage();
  static const _storageKey = 'custom_snippets_v1';

  // Built-in keys: label → data sent to PTY
  static const _builtins = [
    _Key('Ctrl+C', '\x03'),
    _Key('Ctrl+D', '\x04'),
    _Key('Ctrl+Z', '\x1a'),
    _Key('Tab',    '\t'),
    _Key('Esc',    '\x1b'),
    _Key('↑',      '\x1b[A'),
    _Key('↓',      '\x1b[B'),
    _Key('→',      '\x1b[C'),
    _Key('←',      '\x1b[D'),
  ];

  List<_Key> _snippets = [];

  @override
  void initState() {
    super.initState();
    _loadSnippets();
  }

  Future<void> _loadSnippets() async {
    final raw = await _storage.read(key: _storageKey);
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      setState(() {
        _snippets = list
            .map((e) => _Key(e['label'] as String, e['data'] as String))
            .toList();
      });
    }
  }

  Future<void> _saveSnippets() async {
    final encoded = jsonEncode(
        _snippets.map((s) => {'label': s.label, 'data': s.data}).toList());
    await _storage.write(key: _storageKey, value: encoded);
  }

  void _tap(String data) {
    HapticFeedback.lightImpact();
    widget.onSend(data);
  }

  void _showSnippetManager() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF12121A),
      builder: (_) => _SnippetManager(
        snippets: _snippets,
        onAdd: (label, data) {
          setState(() => _snippets.add(_Key(label, data)));
          _saveSnippets();
        },
        onDelete: (index) {
          setState(() => _snippets.removeAt(index));
          _saveSnippets();
        },
        onReorder: (oldIdx, newIdx) {
          setState(() {
            if (newIdx > oldIdx) newIdx--;
            final item = _snippets.removeAt(oldIdx);
            _snippets.insert(newIdx, item);
          });
          _saveSnippets();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final all = [..._builtins, ..._snippets];

    return Container(
      height: 38,
      color: const Color(0xFF0D0D14),
      child: Row(
        children: [
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              itemCount: all.length,
              separatorBuilder: (_, _) => const SizedBox(width: 4),
              itemBuilder: (_, i) => _KeyButton(
                key: ValueKey(all[i].label),
                label: all[i].label,
                isCtrl: all[i].data.codeUnitAt(0) < 32,
                onTap: () => _tap(all[i].data),
              ),
            ),
          ),
          // Snippet manager button
          GestureDetector(
            onTap: _showSnippetManager,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.tune, size: 16, color: Color(0xFF444466)),
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  final String label;
  final bool isCtrl;
  final VoidCallback onTap;

  const _KeyButton({super.key, required this.label, required this.isCtrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            color: isCtrl
                ? const Color(0xFFFF5555).withValues(alpha: 0.5)
                : const Color(0xFF2A2A3E),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isCtrl ? const Color(0xFFFF5555) : const Color(0xFFCCCCDD),
            fontSize: 11,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}

class _Key {
  final String label;
  final String data;
  const _Key(this.label, this.data);
}

class _SnippetManager extends StatefulWidget {
  final List<_Key> snippets;
  final void Function(String label, String data) onAdd;
  final void Function(int index) onDelete;
  final void Function(int oldIdx, int newIdx) onReorder;

  const _SnippetManager({
    required this.snippets,
    required this.onAdd,
    required this.onDelete,
    required this.onReorder,
  });

  @override
  State<_SnippetManager> createState() => _SnippetManagerState();
}

class _SnippetManagerState extends State<_SnippetManager> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Snippets',
                  style: TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 14)),
              TextButton.icon(
                onPressed: _addDialog,
                icon: const Icon(Icons.add, size: 16, color: Color(0xFF00FF88)),
                label: const Text('Add', style: TextStyle(color: Color(0xFF00FF88), fontFamily: 'monospace')),
              ),
            ],
          ),
        ),
        Expanded(
          child: ReorderableListView(
            onReorder: widget.onReorder,
            children: [
              for (int i = 0; i < widget.snippets.length; i++)
                ListTile(
                  key: ValueKey(i),
                  dense: true,
                  title: Text(widget.snippets[i].label,
                      style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 12)),
                  subtitle: Text(widget.snippets[i].data,
                      style: const TextStyle(color: Color(0xFF666688), fontFamily: 'monospace', fontSize: 10)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFF444466)),
                    onPressed: () => widget.onDelete(i),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _addDialog() {
    final labelCtrl = TextEditingController();
    final dataCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF12121A),
        title: const Text('New snippet',
            style: TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 14)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(labelCtrl, 'Label (e.g. deploy)'),
            const SizedBox(height: 8),
            _field(dataCtrl, 'Command (e.g. ./deploy.sh)'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF666688)))),
          TextButton(
            onPressed: () {
              if (labelCtrl.text.isNotEmpty && dataCtrl.text.isNotEmpty) {
                widget.onAdd(labelCtrl.text.trim(), '${dataCtrl.text.trim()}\r');
                Navigator.pop(context);
              }
            },
            child: const Text('Add', style: TextStyle(color: Color(0xFF00FF88))),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF444466), fontSize: 12),
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF2A2A3E))),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF00FF88))),
      ),
    );
  }
}
