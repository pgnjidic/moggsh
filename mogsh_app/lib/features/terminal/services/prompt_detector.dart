import 'dart:async';
import 'dart:ui' show Color;
import 'package:flutter/foundation.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/ansi.dart';

enum PromptType { none, yesNo, numbered, claudeCode }

@immutable
class PromptOption {
  final String key;     // sent on tap (e.g. 'y\r', '2\r', '\r', '\x1b')
  final String label;   // short button label
  final Color color;    // tint for the button
  final String? hint;   // optional secondary text (mnemonic)

  const PromptOption({
    required this.key,
    required this.label,
    required this.color,
    this.hint,
  });

  @override
  bool operator ==(Object other) =>
      other is PromptOption &&
      other.key == key &&
      other.label == label &&
      other.color.toARGB32() == color.toARGB32() &&
      other.hint == hint;

  @override
  int get hashCode => Object.hash(key, label, color.toARGB32(), hint);
}

@immutable
class PromptContext {
  final PromptType type;
  final List<PromptOption> options;

  const PromptContext({required this.type, required this.options});

  static const PromptContext empty =
      PromptContext(type: PromptType.none, options: <PromptOption>[]);

  @override
  bool operator ==(Object other) {
    if (other is! PromptContext) return false;
    if (other.type != type) return false;
    if (other.options.length != options.length) return false;
    for (var i = 0; i < options.length; i++) {
      if (other.options[i] != options[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(type, Object.hashAll(options));
}

/// Listens to a terminal output stream and infers whether the tail of the
/// buffer represents an interactive prompt (y/n, numbered menu, Claude Code
/// TUI), so UI can surface big context-aware buttons.
class PromptDetector extends ChangeNotifier {
  static const int _maxBufferChars = 8000;
  static const int _retainedChars = 4000;
  static const int _tailLines = 15;
  static const Duration _debounce = Duration(milliseconds: 150);

  final StringBuffer _buf = StringBuffer();
  Timer? _debounceTimer;
  StreamSubscription<String>? _sub;
  PromptContext _current = PromptContext.empty;

  PromptContext get current => _current;

  /// Subscribe to [output]. Any previous subscription is cancelled first.
  /// Optionally seed the buffer with [seed] (e.g. scrollback tail) so the
  /// detector has context immediately on tab switch.
  void attach(Stream<String> output, {String? seed}) {
    detach();
    if (seed != null && seed.isNotEmpty) {
      _buf.write(stripAnsi(seed));
      _trim();
    }
    _sub = output.listen(_onChunk);
    _scheduleRun();
  }

  void detach() {
    _sub?.cancel();
    _sub = null;
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _buf.clear();
    if (_current.type != PromptType.none) {
      _current = PromptContext.empty;
      notifyListeners();
    }
  }

  void _onChunk(String raw) {
    _buf.write(stripAnsi(raw));
    _trim();
    _scheduleRun();
  }

  void _trim() {
    if (_buf.length <= _maxBufferChars) return;
    final tail = _buf.toString();
    final kept = tail.substring(tail.length - _retainedChars);
    _buf
      ..clear()
      ..write(kept);
  }

  void _scheduleRun() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounce, _run);
  }

  void _run() {
    _debounceTimer = null;
    final detected = _detect(_buf.toString());
    if (detected != _current) {
      _current = detected;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    detach();
    super.dispose();
  }

  // ---- detection ---------------------------------------------------------

  static final RegExp _numberedLine =
      RegExp(r'^\s*(\d+)[\.\)\]]\s+(.+?)\s*$');
  static final RegExp _yesNoPattern = RegExp(
    r'(\((y|yes)\s*/\s*(n|no)\))|'
    r'(\[(y|yes)\s*/\s*(n|no)\])|'
    r'(\bcontinue\?)|'
    r'(\bproceed\?)|'
    r'(\bare you sure)|'
    r'(\boverwrite\?)',
    caseSensitive: false,
  );
  static final RegExp _ccBoxPrompt = RegExp(r'^\s*[│>]\s*$');

  PromptContext _detect(String buffer) {
    if (buffer.isEmpty) return PromptContext.empty;

    final lines = buffer.split('\n');
    final tail = lines.length <= _tailLines
        ? lines
        : lines.sublist(lines.length - _tailLines);

    // Last non-empty line — used to confirm a prompt is awaiting input.
    String lastNonEmpty = '';
    for (var i = tail.length - 1; i >= 0; i--) {
      final t = tail[i].trimRight();
      if (t.isNotEmpty) {
        lastNonEmpty = t;
        break;
      }
    }

    // 1. numbered (highest precedence)
    final numbered = _detectNumbered(tail, lastNonEmpty);
    if (numbered != null) return numbered;

    // 2. yesNo
    final yn = _detectYesNo(tail);
    if (yn != null) return yn;

    // 3. claudeCode TUI
    final cc = _detectClaudeCode(tail);
    if (cc != null) return cc;

    return PromptContext.empty;
  }

  PromptContext? _detectNumbered(List<String> tail, String lastNonEmpty) {
    final items = <(int, String)>[];
    int? lastIndex;
    for (var i = 0; i < tail.length; i++) {
      final m = _numberedLine.firstMatch(tail[i]);
      if (m == null) continue;
      if (lastIndex != null && i != lastIndex + 1) {
        // Not consecutive — reset so we only surface a contiguous block.
        items.clear();
      }
      items.add((int.parse(m.group(1)!), m.group(2)!));
      lastIndex = i;
    }
    if (items.length < 2) return null;

    // Ensure a prompt line is actively awaiting input after the menu.
    final awaiting = lastNonEmpty.isEmpty ||
        lastNonEmpty.endsWith('?') ||
        lastNonEmpty.endsWith(':') ||
        lastNonEmpty.endsWith('>') ||
        lastNonEmpty.endsWith('#') ||
        lastNonEmpty.contains(RegExp(r'(choose|select|enter|pick)',
            caseSensitive: false));
    if (!awaiting) return null;

    final options = [
      for (final (n, label) in items)
        PromptOption(
          key: '$n\r',
          label: '$n',
          color: AppColors.teal,
          hint: _truncate(label, 20),
        ),
    ];
    return PromptContext(type: PromptType.numbered, options: options);
  }

  PromptContext? _detectYesNo(List<String> tail) {
    // Only scan the last 2 non-empty lines — once the user answers and the
    // shell prints output + a new prompt, older y/n text scrolls away and
    // must no longer re-trigger the button row.
    final recent = <String>[];
    for (var i = tail.length - 1; i >= 0 && recent.length < 2; i--) {
      final t = tail[i].trim();
      if (t.isEmpty) continue;
      recent.add(t);
    }
    for (final line in recent) {
      if (_yesNoPattern.hasMatch(line)) {
        return const PromptContext(
          type: PromptType.yesNo,
          options: [
            PromptOption(key: 'y\r', label: 'Yes', color: AppColors.green,
                hint: 'y'),
            PromptOption(key: 'n\r', label: 'No', color: AppColors.red,
                hint: 'n'),
          ],
        );
      }
    }
    return null;
  }

  PromptContext? _detectClaudeCode(List<String> tail) {
    final hasBoxTop = tail.any((l) => l.contains('╭'));
    final hasBoxSide = tail.any((l) => l.contains('│'));
    if (!hasBoxTop || !hasBoxSide) return null;

    final hasPromptLine = tail.reversed
        .take(4)
        .any((l) => _ccBoxPrompt.hasMatch(l));
    if (!hasPromptLine) return null;

    return const PromptContext(
      type: PromptType.claudeCode,
      options: [
        PromptOption(
            key: '\r', label: 'Send', color: AppColors.green, hint: '↵'),
        PromptOption(
            key: '\x1b\r', label: 'Multiline', color: AppColors.teal,
            hint: '⇧⏎'),
        PromptOption(
            key: '\x1b', label: 'Esc', color: AppColors.amber, hint: '⎋'),
      ],
    );
  }

  static String _truncate(String s, int max) =>
      s.length <= max ? s : '${s.substring(0, max - 1)}…';
}
