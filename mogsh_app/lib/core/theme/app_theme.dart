import 'package:flutter/material.dart';

class AppTheme {
  static const _bg = Color(0xFF0A0A0F);
  static const _surface = Color(0xFF12121A);
  static const _primary = Color(0xFF00FF88);
  static const _secondary = Color(0xFF00D4FF);

  static final dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _bg,
    colorScheme: const ColorScheme.dark(
      surface: _surface,
      primary: _primary,
      secondary: _secondary,
    ),
    fontFamily: 'monospace',
  );
}
