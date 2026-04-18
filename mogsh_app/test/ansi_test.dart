import 'package:flutter_test/flutter_test.dart';
import 'package:mogsh/core/utils/ansi.dart';

void main() {
  group('stripAnsi', () {
    test('returns empty string unchanged', () {
      expect(stripAnsi(''), '');
    });

    test('passes plain text through unchanged', () {
      expect(stripAnsi('hello world'), 'hello world');
    });

    test('preserves newlines, tabs, carriage returns', () {
      expect(stripAnsi('a\r\nb\tc'), 'a\r\nb\tc');
    });

    test('strips SGR color sequences', () {
      expect(stripAnsi('\x1b[31merror\x1b[0m'), 'error');
      expect(stripAnsi('\x1b[1;32;40mbold green\x1b[0m'), 'bold green');
    });

    test('strips cursor movement sequences', () {
      expect(stripAnsi('a\x1b[2Ab\x1b[Hc\x1b[5;10Hd'), 'abcd');
    });

    test('strips erase in line / display', () {
      expect(stripAnsi('line\x1b[K\x1b[2J'), 'line');
    });

    test('strips OSC terminated by BEL', () {
      expect(stripAnsi('\x1b]0;window title\x07after'), 'after');
    });

    test('strips OSC terminated by ST (ESC backslash)', () {
      expect(stripAnsi('\x1b]8;;http://x\x1b\\link\x1b]8;;\x1b\\'), 'link');
    });

    test('strips single-char C1 escapes', () {
      expect(stripAnsi('a\x1b7b\x1b8c\x1bMd'), 'abcd');
    });

    test('strips charset selection escapes', () {
      expect(stripAnsi('a\x1b(Bb\x1b)0c'), 'abc');
    });

    test('handles mixed ANSI in a realistic prompt', () {
      const input = '\x1b[32muser@host\x1b[0m:\x1b[34m~\x1b[0m\$ ';
      expect(stripAnsi(input), 'user@host:~\$ ');
    });
  });
}
