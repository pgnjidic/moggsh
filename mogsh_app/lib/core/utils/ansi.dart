/// Strips ANSI escape sequences from [input].
///
/// Covers the subset xterm emits in practice:
/// - CSI sequences (SGR colors, cursor movement, erase, etc.)
/// - OSC sequences (window titles, hyperlinks) terminated by BEL or ST
/// - Single-char C1 escapes (ESC 7, ESC 8, ESC D, ESC M, ...)
///
/// Plain control chars (\r, \n, \t, \x08) are preserved — the detector relies
/// on line structure to find prompts.
String stripAnsi(String input) {
  if (input.isEmpty) return input;

  // OSC: ESC ] ... (BEL | ESC \)
  final osc = RegExp(r'\x1b\][\s\S]*?(?:\x07|\x1b\\)');
  // CSI: ESC [ <params> <final byte 0x40-0x7E>
  final csi = RegExp(r'\x1b\[[\x30-\x3f]*[\x20-\x2f]*[\x40-\x7e]');
  // Charset selection & other two-byte intermediates: ESC ( x, ESC ) x, ESC # x
  final twoByteEsc = RegExp(r'\x1b[\(\)#%*+][\x20-\x7e]');
  // Any remaining ESC + single printable byte (ESC 7/8/c/D/M/=/>/N/O/...)
  final singleEsc = RegExp(r'\x1b[\x20-\x7e]');

  return input
      .replaceAll(osc, '')
      .replaceAll(csi, '')
      .replaceAll(twoByteEsc, '')
      .replaceAll(singleEsc, '');
}
