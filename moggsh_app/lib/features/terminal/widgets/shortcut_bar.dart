import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/theme/app_colors.dart';
import '../services/voice_input_service.dart';
import 'joystick_controller.dart';

/// Composer that stitches together the voice-transcript bar and
/// [JoystickController].
class ShortcutBar extends StatefulWidget {
  final void Function(String) onSend;
  final VoidCallback? onCopy;
  final bool copyModeActive;
  final VoidCallback? onShowKeyboard;

  const ShortcutBar({
    super.key,
    required this.onSend,
    this.onCopy,
    this.copyModeActive = false,
    this.onShowKeyboard,
  });

  @override
  State<ShortcutBar> createState() => _ShortcutBarState();
}

class _ShortcutBarState extends State<ShortcutBar> {
  static const _storage = FlutterSecureStorage();
  static const _storageKey = 'custom_snippets_v1';
  static const _seededKey = 'snippets_seeded_v1';

  static const _defaultSnippets = [
    _Snippet('F1', '\x1bOP'),
    _Snippet('F2', '\x1bOQ'),
    _Snippet('F3', '\x1bOR'),
    _Snippet('F4', '\x1bOS'),
    _Snippet('F5', '\x1b[15~'),
    _Snippet('F6', '\x1b[17~'),
  ];

  final _voice = VoiceInputService();
  List<_Snippet> _snippets = [];

  @override
  void initState() {
    super.initState();
    _loadSnippets();
  }

  @override
  void dispose() {
    _voice.dispose();
    super.dispose();
  }

  Future<void> _loadSnippets() async {
    final raw = await _storage.read(key: _storageKey);
    final seeded = await _storage.read(key: _seededKey);
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      if (!mounted) return;
      setState(() {
        _snippets = list
            .map((e) => _Snippet(e['label'] as String, e['data'] as String))
            .toList();
      });
    } else if (seeded == null) {
      // First launch — seed F1–F6 so power users can still reach them.
      await _writeSnippets(List.of(_defaultSnippets));
      await _storage.write(key: _seededKey, value: '1');
    }
  }

  Future<void> _writeSnippets(List<_Snippet> next) async {
    await _storage.write(
      key: _storageKey,
      value: jsonEncode(
          next.map((s) => {'label': s.label, 'data': s.data}).toList()),
    );
    if (!mounted) return;
    setState(() => _snippets = next);
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
          style: const TextStyle(
              color: AppColors.red, fontFamily: 'monospace', fontSize: 12),
        ),
      ));
    }
  }

  void _showSnippetManager() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (_) => _SnippetManager(
        snippets: _snippets,
        onAdd: (label, data) =>
            _writeSnippets([..._snippets, _Snippet(label, data)]),
        onDelete: (i) =>
            _writeSnippets([..._snippets]..removeAt(i)),
        onReorder: (o, n) {
          final next = [..._snippets];
          if (n > o) n--;
          final item = next.removeAt(o);
          next.insert(n, item);
          _writeSnippets(next);
        },
        onSend: (s) {
          Navigator.pop(context);
          HapticFeedback.lightImpact();
          widget.onSend(s.data);
        },
        onResetDefaults: () => _writeSnippets(List.of(_defaultSnippets)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final landscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
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
            JoystickController(
              onSend: widget.onSend,
              landscape: landscape,
              onOpenSnippets: _showSnippetManager,
              onCopy: widget.onCopy,
              copyModeActive: widget.copyModeActive,
              onShowKeyboard: widget.onShowKeyboard,
              voiceBtn: _VoiceBtn(
                listening: listening,
                error: _voice.state == VoiceState.error,
                level: _voice.level,
                onTap: _toggleVoice,
                compact: landscape,
              ),
            ),
          ]),
        );
      },
    );
  }

  Widget _voiceTranscriptBar() {
    final listening = _voice.state == VoiceState.listening;
    final txt = _voice.transcript.isEmpty ? 'Listening…' : _voice.transcript;
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
          width: 6,
          height: 6,
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
                color: AppColors.teal, fontSize: 11, fontFamily: 'monospace'),
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
}

class _VoiceBtn extends StatelessWidget {
  final bool listening;
  final bool error;
  final double level;
  final VoidCallback onTap;
  final bool compact;

  const _VoiceBtn({
    required this.listening,
    required this.error,
    required this.level,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = error ? AppColors.red : AppColors.green;
    final amplitude = level.clamp(0.0, 10.0) / 10.0;
    final glow = listening ? (0.35 + amplitude * 0.55) : 0.22;
    final fillOuter = listening ? 0.38 + amplitude * 0.22 : 0.22;
    final size = compact ? 38.0 : 60.0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [
            color.withValues(alpha: fillOuter),
            color.withValues(alpha: 0.06),
          ]),
          border: Border.all(
              color: color.withValues(alpha: listening ? 0.95 : 0.6), width: 2),
          boxShadow: [
            BoxShadow(
                color: color.withValues(alpha: glow),
                blurRadius: listening ? 22 : 12),
          ],
        ),
        child: Icon(
          listening ? Icons.stop_rounded : Icons.mic_rounded,
          size: compact ? 18 : 28,
          color: color,
        ),
      ),
    );
  }
}

class _Snippet {
  final String label;
  final String data;
  const _Snippet(this.label, this.data);
}

// ── Snippet manager ────────────────────────────────────────────────────────

class _SnippetManager extends StatefulWidget {
  final List<_Snippet> snippets;
  final void Function(String, String) onAdd;
  final void Function(int) onDelete;
  final void Function(int, int) onReorder;
  final void Function(_Snippet) onSend;
  final VoidCallback onResetDefaults;

  const _SnippetManager({
    required this.snippets,
    required this.onAdd,
    required this.onDelete,
    required this.onReorder,
    required this.onSend,
    required this.onResetDefaults,
  });

  @override
  State<_SnippetManager> createState() => _SnippetManagerState();
}

class _SnippetManagerState extends State<_SnippetManager> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(mainAxisSize: MainAxisSize.max, children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            const Text('Snippets',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontFamily: 'monospace',
                    fontSize: 14)),
            const Spacer(),
            TextButton.icon(
              onPressed: _confirmReset,
              icon: const Icon(Icons.restart_alt,
                  size: 15, color: AppColors.textMuted),
              label: const Text('Reset',
                  style: TextStyle(
                      color: AppColors.textMuted, fontFamily: 'monospace')),
            ),
            TextButton.icon(
              onPressed: _addDialog,
              icon: const Icon(Icons.add, size: 15, color: AppColors.green),
              label: const Text('Add',
                  style: TextStyle(
                      color: AppColors.green, fontFamily: 'monospace')),
            ),
          ]),
        ),
        Expanded(
          child: widget.snippets.isEmpty
              ? const Center(
                  child: Text('No snippets yet',
                      style: TextStyle(
                          color: AppColors.textMuted,
                          fontFamily: 'monospace',
                          fontSize: 12)),
                )
              : ReorderableListView(
                  onReorder: widget.onReorder,
                  children: [
                    for (int i = 0; i < widget.snippets.length; i++)
                      ListTile(
                        key: ValueKey(i),
                        dense: true,
                        onTap: () => widget.onSend(widget.snippets[i]),
                        title: Text(widget.snippets[i].label,
                            style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontFamily: 'monospace',
                                fontSize: 12)),
                        subtitle: Text(
                          _preview(widget.snippets[i].data),
                          style: const TextStyle(
                              color: AppColors.textMuted,
                              fontFamily: 'monospace',
                              fontSize: 10),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              size: 15, color: AppColors.textMuted),
                          onPressed: () => widget.onDelete(i),
                        ),
                      ),
                  ],
                ),
        ),
      ]),
    );
  }

  String _preview(String data) =>
      data.replaceAll('\x1b', r'\e').replaceAll('\r', r'\r').replaceAll('\t', r'\t');

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Reset to defaults?',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontFamily: 'monospace',
                fontSize: 14)),
        content: const Text(
            'Replaces the current snippets with F1–F6. This cannot be undone.',
            style: TextStyle(
                color: AppColors.textMuted,
                fontFamily: 'monospace',
                fontSize: 12)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textMuted))),
          TextButton(
            onPressed: () {
              widget.onResetDefaults();
              Navigator.pop(context);
            },
            child: const Text('Reset',
                style: TextStyle(color: AppColors.amber)),
          ),
        ],
      ),
    );
  }

  void _addDialog() {
    final labelCtrl = TextEditingController();
    final dataCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('New snippet',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontFamily: 'monospace',
                fontSize: 14)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          _field(labelCtrl, 'Label (e.g. deploy)'),
          const SizedBox(height: 8),
          _field(dataCtrl, 'Command'),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textMuted))),
          TextButton(
            onPressed: () {
              if (labelCtrl.text.isNotEmpty && dataCtrl.text.isNotEmpty) {
                widget.onAdd(labelCtrl.text.trim(), '${dataCtrl.text.trim()}\r');
                Navigator.pop(context);
              }
            },
            child:
                const Text('Add', style: TextStyle(color: AppColors.green)),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint) => TextField(
        controller: ctrl,
        style: const TextStyle(
            color: AppColors.textPrimary,
            fontFamily: 'monospace',
            fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              const TextStyle(color: AppColors.textMuted, fontSize: 12),
          enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.border)),
          focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.green)),
        ),
      );
}
