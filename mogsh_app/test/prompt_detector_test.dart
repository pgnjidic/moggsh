import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mogsh/features/terminal/services/prompt_detector.dart';

Future<void> _flush(Duration debounce) =>
    Future.delayed(debounce + const Duration(milliseconds: 20));

void main() {
  const debounce = Duration(milliseconds: 150);

  group('PromptDetector — yesNo', () {
    test('detects rm -i style (y/n)?', () async {
      final ctrl = StreamController<String>();
      final d = PromptDetector();
      d.attach(ctrl.stream);
      ctrl.add("rm: remove regular file 'foo'? (y/n) ");
      await _flush(debounce);
      expect(d.current.type, PromptType.yesNo);
      expect(d.current.options.map((o) => o.label), ['Yes', 'No']);
      expect(d.current.options[0].key, 'y\r');
      expect(d.current.options[1].key, 'n\r');
      await ctrl.close();
      d.dispose();
    });

    test('detects apt-style [Y/n]', () async {
      final ctrl = StreamController<String>();
      final d = PromptDetector();
      d.attach(ctrl.stream);
      ctrl.add('Do you want to continue? [Y/n] ');
      await _flush(debounce);
      expect(d.current.type, PromptType.yesNo);
      await ctrl.close();
      d.dispose();
    });

    test('detects overwrite? without explicit y/n', () async {
      final ctrl = StreamController<String>();
      final d = PromptDetector();
      d.attach(ctrl.stream);
      ctrl.add('overwrite? ');
      await _flush(debounce);
      expect(d.current.type, PromptType.yesNo);
      await ctrl.close();
      d.dispose();
    });

    test('case-insensitive', () async {
      final ctrl = StreamController<String>();
      final d = PromptDetector();
      d.attach(ctrl.stream);
      ctrl.add('Continue? ');
      await _flush(debounce);
      expect(d.current.type, PromptType.yesNo);
      await ctrl.close();
      d.dispose();
    });
  });

  group('PromptDetector — numbered', () {
    test('detects bash read menu 1/2/3 with trailing prompt', () async {
      final ctrl = StreamController<String>();
      final d = PromptDetector();
      d.attach(ctrl.stream);
      ctrl.add('Choose an option:\n'
          '1. Apple\n'
          '2. Banana\n'
          '3. Cherry\n'
          'choice> ');
      await _flush(debounce);
      expect(d.current.type, PromptType.numbered);
      expect(d.current.options.length, 3);
      expect(d.current.options[0].label, '1');
      expect(d.current.options[0].key, '1\r');
      expect(d.current.options[0].hint, 'Apple');
      expect(d.current.options[2].hint, 'Cherry');
      await ctrl.close();
      d.dispose();
    });

    test('takes precedence over yesNo', () async {
      final ctrl = StreamController<String>();
      final d = PromptDetector();
      d.attach(ctrl.stream);
      ctrl.add('Pick one (y/n fallback):\n'
          '1) First\n'
          '2) Second\n'
          'select: ');
      await _flush(debounce);
      expect(d.current.type, PromptType.numbered);
      await ctrl.close();
      d.dispose();
    });

    test('truncates long labels to 20 chars', () async {
      final ctrl = StreamController<String>();
      final d = PromptDetector();
      d.attach(ctrl.stream);
      ctrl.add('Menu:\n'
          '1. aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa long option\n'
          '2. short\n'
          'choice> ');
      await _flush(debounce);
      expect(d.current.type, PromptType.numbered);
      expect(d.current.options[0].hint!.length, lessThanOrEqualTo(20));
      expect(d.current.options[0].hint!.endsWith('…'), isTrue);
      await ctrl.close();
      d.dispose();
    });

    test('ignores single numbered line', () async {
      final ctrl = StreamController<String>();
      final d = PromptDetector();
      d.attach(ctrl.stream);
      ctrl.add('Step 1. of many things to do here\n\$ ');
      await _flush(debounce);
      expect(d.current.type, PromptType.none);
      await ctrl.close();
      d.dispose();
    });
  });

  group('PromptDetector — claudeCode', () {
    test('detects Claude Code TUI box', () async {
      final ctrl = StreamController<String>();
      final d = PromptDetector();
      d.attach(ctrl.stream);
      ctrl.add('╭───────────────────────────╮\n'
          '│ > \n'
          '│\n');
      await _flush(debounce);
      expect(d.current.type, PromptType.claudeCode);
      expect(d.current.options.map((o) => o.label),
          ['Send', 'Multiline', 'Esc']);
      await ctrl.close();
      d.dispose();
    });
  });

  group('PromptDetector — none / clearing', () {
    test('clears back to none when tail stops matching', () async {
      final ctrl = StreamController<String>();
      final d = PromptDetector();
      d.attach(ctrl.stream);
      ctrl.add('Continue? (y/n) ');
      await _flush(debounce);
      expect(d.current.type, PromptType.yesNo);

      // User answers — echo + prompt replaces the question.
      ctrl.add('y\nok\nuser@host:~\$ ');
      await _flush(debounce);
      expect(d.current.type, PromptType.none);
      await ctrl.close();
      d.dispose();
    });

    test('detach emits none', () async {
      final ctrl = StreamController<String>();
      final d = PromptDetector();
      d.attach(ctrl.stream);
      ctrl.add('Continue? (y/n) ');
      await _flush(debounce);
      expect(d.current.type, PromptType.yesNo);

      d.detach();
      expect(d.current.type, PromptType.none);
      await ctrl.close();
      d.dispose();
    });

    test('seed primes detector without waiting for chunk', () async {
      final ctrl = StreamController<String>();
      final d = PromptDetector();
      d.attach(ctrl.stream, seed: 'Continue? (y/n) ');
      await _flush(debounce);
      expect(d.current.type, PromptType.yesNo);
      await ctrl.close();
      d.dispose();
    });
  });
}
