import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../services/voice_input_service.dart';

class ShortcutBar extends StatefulWidget {
  final void Function(String) onSend;
  const ShortcutBar({super.key, required this.onSend});

  @override
  State<ShortcutBar> createState() => _ShortcutBarState();
}

enum _InputMode { voice, text }

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
  final _voice = VoiceInputService();
  _InputMode _mode = _InputMode.voice;
  final _textCtrl = TextEditingController();
  final _textFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadSnippets();
  }

  @override
  void dispose() {
    _voice.dispose();
    _textCtrl.dispose();
    _textFocus.dispose();
    super.dispose();
  }

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

  Future<void> _toggleVoice() async {
    HapticFeedback.mediumImpact();
    if (_voice.state == VoiceState.listening) {
      await _voice.stop();
      return;
    }
    await _voice.start(onFinal: (text) {
      if (text.trim().isEmpty) return;
      widget.onSend(text);
    });
    if (_voice.state == VoiceState.error && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.surface2,
        content: Text(
          _voice.errorMessage ?? 'Microphone unavailable',
          style: const TextStyle(color: AppColors.red, fontFamily: 'monospace', fontSize: 12),
        ),
      ));
    }
  }

  void _switchMode() {
    HapticFeedback.selectionClick();
    setState(() {
      if (_mode == _InputMode.voice) {
        if (_voice.state == VoiceState.listening) _voice.stop();
        _mode = _InputMode.text;
      } else {
        _textFocus.unfocus();
        _mode = _InputMode.voice;
      }
    });
    if (_mode == _InputMode.text) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _textFocus.requestFocus());
    }
  }

  void _submitText({bool withReturn = true}) {
    final text = _textCtrl.text;
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    widget.onSend(withReturn ? '$text\r' : text);
    _textCtrl.clear();
    // Keep focus so user can chain commands quickly
    _textFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final landscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return AnimatedBuilder(
      animation: _voice,
      builder: (_, _) {
        final listening = _voice.state == VoiceState.listening;
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.bgDark,
            border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
          ),
          padding: EdgeInsets.fromLTRB(6, landscape ? 4 : 6, 6, landscape ? 4 : 6),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (listening || _voice.transcript.isNotEmpty) _voiceTranscriptBar(),
            if (landscape) _landscapeRow(listening) else ..._portraitRows(listening),
          ]),
        );
      },
    );
  }

  // ── Portrait: two-row layout ──────────────────────────────────────────────
  List<Widget> _portraitRows(bool listening) {
    return [
      SizedBox(
        height: 30,
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
      const SizedBox(height: 6),
      SizedBox(
        height: 44,
        child: _mode == _InputMode.text
            ? _textInputRow()
            : Row(children: [
                Expanded(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _row2.take(4).map((k) =>
                      _KeyBtn(label: k.label, style: _keyStyle(k), onTap: () => _tap(k.data))).toList(),
                  ),
                ),
                const SizedBox(width: 6),
                _VoiceBtn(
                  listening: listening,
                  error: _voice.state == VoiceState.error,
                  level: _voice.level,
                  onTap: _toggleVoice,
                ),
                const SizedBox(width: 4),
                _ModeToggle(mode: _mode, onTap: _switchMode),
                const SizedBox(width: 4),
                Expanded(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _row2.skip(4).map((k) =>
                      _KeyBtn(label: k.label, style: _keyStyle(k), onTap: () => _tap(k.data))).toList(),
                  ),
                ),
              ]),
      ),
    ];
  }

  // ── Landscape: single compact row ─────────────────────────────────────────
  Widget _landscapeRow(bool listening) {
    if (_mode == _InputMode.text) {
      return SizedBox(height: 36, child: _textInputRow(compact: true));
    }
    final allKeys = <_Key>[..._row1, ..._row2, ..._snippets];
    return SizedBox(
      height: 36,
      child: Row(children: [
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: allKeys.length,
            itemBuilder: (_, i) {
              final k = allKeys[i];
              final style = i >= _row1.length + _row2.length
                  ? _BtnStyle.snippet
                  : _keyStyle(k);
              return _KeyBtn(label: k.label, style: style, onTap: () => _tap(k.data));
            },
          ),
        ),
        const SizedBox(width: 4),
        _VoiceBtn(
          listening: listening,
          error: _voice.state == VoiceState.error,
          level: _voice.level,
          onTap: _toggleVoice,
          compact: true,
        ),
        const SizedBox(width: 4),
        _ModeToggle(mode: _mode, onTap: _switchMode),
        const SizedBox(width: 2),
        _IconBtn(icon: Icons.tune, onTap: _showSnippetManager),
      ]),
    );
  }

  Widget _textInputRow({bool compact = false}) {
    final h = compact ? 32.0 : 40.0;
    return Row(children: [
      Expanded(
        child: Container(
          height: h,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.surface2.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.green.withValues(alpha: 0.25)),
          ),
          child: Center(
            child: TextField(
              controller: _textCtrl,
              focusNode: _textFocus,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submitText(),
              cursorColor: AppColors.green,
              style: const TextStyle(
                color: AppColors.textPrimary, fontFamily: 'monospace', fontSize: 13,
              ),
              decoration: const InputDecoration(
                isDense: true,
                hintText: 'Type command, Enter to send…',
                hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 12),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ),
      const SizedBox(width: 6),
      _SendBtn(onTap: _submitText, compact: compact),
      const SizedBox(width: 4),
      _ModeToggle(mode: _mode, onTap: _switchMode),
    ]);
  }

  Widget _voiceTranscriptBar() {
    final listening = _voice.state == VoiceState.listening;
    final txt = _voice.transcript.isEmpty
        ? 'Listening…'
        : _voice.transcript;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        Container(
          width: 6, height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.green,
            boxShadow: listening
                ? [BoxShadow(color: AppColors.green.withValues(alpha: 0.7), blurRadius: 6)]
                : null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            txt,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.teal, fontSize: 11, fontFamily: 'monospace',
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _voice.cancel(),
          child: const Padding(
            padding: EdgeInsets.all(2),
            child: Icon(Icons.close, size: 14, color: AppColors.textMuted),
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
      _BtnStyle.esc     => (AppColors.green.withValues(alpha: 0.14), AppColors.green.withValues(alpha: 0.35), AppColors.teal),
      _BtnStyle.ctrl    => (AppColors.amber.withValues(alpha: 0.12), AppColors.amber.withValues(alpha: 0.3), AppColors.amber),
      _BtnStyle.fn      => (const Color(0x12FFFFFF), const Color(0x1AFFFFFF), AppColors.textMuted),
      _BtnStyle.snippet => (AppColors.blue.withValues(alpha: 0.14), AppColors.blue.withValues(alpha: 0.35), AppColors.blue),
      _BtnStyle.normal  => (const Color(0x12FFFFFF), const Color(0x1AFFFFFF), AppColors.textMuted),
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: border),
        ),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(color: fg, fontSize: 10, fontFamily: 'monospace')),
      ),
    );
  }
}

class _VoiceBtn extends StatelessWidget {
  final bool listening;
  final bool error;
  final double level;
  final VoidCallback onTap;
  final bool compact;
  const _VoiceBtn({required this.listening, required this.error, required this.level, required this.onTap, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final color = error ? AppColors.red : AppColors.green;
    final amplitude = level.clamp(0.0, 10.0) / 10.0;
    final glow = listening ? (0.3 + amplitude * 0.5) : 0.2;
    final borderAlpha = listening ? 0.9 : 0.55;
    final fillOuter = listening ? 0.35 + amplitude * 0.2 : 0.22;
    final size = compact ? 34.0 : 44.0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [
            color.withValues(alpha: fillOuter),
            color.withValues(alpha: 0.06),
          ]),
          border: Border.all(color: color.withValues(alpha: borderAlpha), width: 2),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: glow), blurRadius: listening ? 18 : 10),
          ],
        ),
        child: Icon(
          listening ? Icons.stop_rounded : Icons.mic_rounded,
          size: compact ? 16 : 20,
          color: color,
        ),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final _InputMode mode;
  final VoidCallback onTap;
  const _ModeToggle({required this.mode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textMode = mode == _InputMode.text;
    final color = textMode ? AppColors.blue : AppColors.textMuted;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 30, height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: textMode ? 0.14 : 0.06),
          border: Border.all(color: color.withValues(alpha: textMode ? 0.45 : 0.25)),
        ),
        child: Icon(
          textMode ? Icons.mic_none_rounded : Icons.keyboard_rounded,
          size: 14,
          color: textMode ? AppColors.blue : AppColors.textMuted,
        ),
      ),
    );
  }
}

class _SendBtn extends StatelessWidget {
  final VoidCallback onTap;
  final bool compact;
  const _SendBtn({required this.onTap, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final size = compact ? 34.0 : 40.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [
            AppColors.green.withValues(alpha: 0.35),
            AppColors.green.withValues(alpha: 0.08),
          ]),
          border: Border.all(color: AppColors.green.withValues(alpha: 0.7), width: 2),
          boxShadow: [
            BoxShadow(color: AppColors.green.withValues(alpha: 0.3), blurRadius: 10),
          ],
        ),
        child: const Icon(Icons.arrow_upward_rounded, size: 18, color: AppColors.green),
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
      child: Icon(icon, size: 16, color: AppColors.textMuted.withValues(alpha: 0.7)),
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
