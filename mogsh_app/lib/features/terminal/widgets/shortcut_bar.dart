import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/theme/app_colors.dart';

class ShortcutBar extends StatefulWidget {
  final void Function(String) onSend;
  const ShortcutBar({super.key, required this.onSend});

  @override
  State<ShortcutBar> createState() => _ShortcutBarState();
}

class _ShortcutBarState extends State<ShortcutBar> {
  static const _storage    = FlutterSecureStorage();
  static const _storageKey = 'custom_snippets_v1';

  static const _row1 = [
    _Key('ESC', '\x1b'),
    _Key('F1',  '\x1bOP'),
    _Key('F2',  '\x1bOQ'),
    _Key('F3',  '\x1bOR'),
    _Key('F4',  '\x1bOS'),
    _Key('F5',  '\x1b[15~'),
    _Key('F6',  '\x1b[17~'),
  ];

  static const _row2 = [
    _Key('Tab',  '\t'),
    _Key('Ctrl+C', '\x03'),
    _Key('Ctrl+D', '\x04'),
    _Key('Ctrl+Z', '\x1a'),
    _Key('↑',   '\x1b[A'),
    _Key('↓',   '\x1b[B'),
    _Key('←',   '\x1b[D'),
    _Key('→',   '\x1b[C'),
    _Key('PgUp', '\x1b[5~'),
  ];

  List<_Key> _snippets = [];

  @override
  void initState() { super.initState(); _loadSnippets(); }

  Future<void> _loadSnippets() async {
    final raw = await _storage.read(key: _storageKey);
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      if (mounted) { setState(() {
        _snippets = list.map((e) => _Key(e['label'] as String, e['data'] as String)).toList();
      }); }
    }
  }

  Future<void> _saveSnippets() async {
    await _storage.write(key: _storageKey,
        value: jsonEncode(_snippets.map((s) => {'label': s.label, 'data': s.data}).toList()));
  }

  void _tap(String data) {
    HapticFeedback.lightImpact();
    widget.onSend(data);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgDark,
      padding: const EdgeInsets.fromLTRB(4, 5, 4, 5),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Row 1: ESC + F keys
        SizedBox(
          height: 28,
          child: Row(children: [
            Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ..._row1.map((k) => _KeyBtn(label: k.label, style: _keyStyle(k), onTap: () => _tap(k.data))),
                  if (_snippets.isNotEmpty)
                    ..._snippets.map((k) => _KeyBtn(label: k.label, style: _BtnStyle.snippet, onTap: () => _tap(k.data))),
                ],
              ),
            ),
            _IconBtn(icon: Icons.tune, onTap: _showSnippetManager),
          ]),
        ),
        const SizedBox(height: 4),
        // Row 2: Tab, Ctrl combos, arrows
        SizedBox(
          height: 28,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: _row2.map((k) => _KeyBtn(label: k.label, style: _keyStyle(k), onTap: () => _tap(k.data))).toList(),
          ),
        ),
      ]),
    );
  }

  _BtnStyle _keyStyle(_Key k) {
    if (k.label.startsWith('Ctrl')) return _BtnStyle.ctrl;
    if (k.label.startsWith('F') && k.label.length <= 3) return _BtnStyle.fn;
    if (k.label == 'ESC') return _BtnStyle.esc;
    return _BtnStyle.normal;
  }

  void _showSnippetManager() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (_) => _SnippetManager(
        snippets: _snippets,
        onAdd: (label, data) { setState(() => _snippets.add(_Key(label, data))); _saveSnippets(); },
        onDelete: (i) { setState(() => _snippets.removeAt(i)); _saveSnippets(); },
        onReorder: (o, n) {
          setState(() { if (n > o) n--; final item = _snippets.removeAt(o); _snippets.insert(n, item); });
          _saveSnippets();
        },
      ),
    );
  }
}

enum _BtnStyle { esc, fn, ctrl, normal, snippet }

class _KeyBtn extends StatelessWidget {
  final String label;
  final _BtnStyle style;
  final VoidCallback onTap;
  const _KeyBtn({required this.label, required this.style, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (bg, border, fg) = switch (style) {
      _BtnStyle.esc     => (AppColors.green.withValues(alpha: 0.12), AppColors.green.withValues(alpha: 0.3), AppColors.teal),
      _BtnStyle.ctrl    => (AppColors.amber.withValues(alpha: 0.1),  AppColors.amber.withValues(alpha: 0.25), AppColors.amber),
      _BtnStyle.fn      => (AppColors.surface2.withValues(alpha: 0.6), AppColors.border.withValues(alpha: 0.4), AppColors.textMuted),
      _BtnStyle.snippet => (AppColors.blue.withValues(alpha: 0.12), AppColors.blue.withValues(alpha: 0.3), AppColors.blue),
      _BtnStyle.normal  => (AppColors.surface2.withValues(alpha: 0.5), AppColors.border.withValues(alpha: 0.4), AppColors.textMuted),
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: border),
        ),
        child: Text(label, style: TextStyle(color: fg, fontSize: 10, fontFamily: 'monospace')),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Icon(icon, size: 15, color: AppColors.textMuted.withValues(alpha: 0.6)),
    ),
  );
}

class _Key {
  final String label, data;
  const _Key(this.label, this.data);
}

// ── Snippet manager ────────────────────────────────────────────────────────

class _SnippetManager extends StatefulWidget {
  final List<_Key> snippets;
  final void Function(String, String) onAdd;
  final void Function(int) onDelete;
  final void Function(int, int) onReorder;
  const _SnippetManager({required this.snippets, required this.onAdd,
      required this.onDelete, required this.onReorder});

  @override
  State<_SnippetManager> createState() => _SnippetManagerState();
}

class _SnippetManagerState extends State<_SnippetManager> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          const Text('Snippets', style: TextStyle(color: AppColors.textPrimary,
              fontFamily: 'monospace', fontSize: 14)),
          const Spacer(),
          TextButton.icon(
            onPressed: _addDialog,
            icon: const Icon(Icons.add, size: 15, color: AppColors.green),
            label: const Text('Add', style: TextStyle(color: AppColors.green, fontFamily: 'monospace')),
          ),
        ]),
      ),
      Expanded(
        child: ReorderableListView(
          onReorder: widget.onReorder,
          children: [
            for (int i = 0; i < widget.snippets.length; i++)
              ListTile(
                key: ValueKey(i), dense: true,
                title: Text(widget.snippets[i].label,
                    style: const TextStyle(color: AppColors.textPrimary,
                        fontFamily: 'monospace', fontSize: 12)),
                subtitle: Text(widget.snippets[i].data,
                    style: const TextStyle(color: AppColors.textMuted,
                        fontFamily: 'monospace', fontSize: 10)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, size: 15, color: AppColors.textMuted),
                  onPressed: () => widget.onDelete(i),
                ),
              ),
          ],
        ),
      ),
    ]);
  }

  void _addDialog() {
    final labelCtrl = TextEditingController();
    final dataCtrl  = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('New snippet',
            style: TextStyle(color: AppColors.textPrimary, fontFamily: 'monospace', fontSize: 14)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          _field(labelCtrl, 'Label (e.g. deploy)'),
          const SizedBox(height: 8),
          _field(dataCtrl, 'Command'),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted))),
          TextButton(
            onPressed: () {
              if (labelCtrl.text.isNotEmpty && dataCtrl.text.isNotEmpty) {
                widget.onAdd(labelCtrl.text.trim(), '${dataCtrl.text.trim()}\r');
                Navigator.pop(context);
              }
            },
            child: const Text('Add', style: TextStyle(color: AppColors.green)),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint) => TextField(
    controller: ctrl,
    style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'monospace', fontSize: 13),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.green)),
    ),
  );
}
