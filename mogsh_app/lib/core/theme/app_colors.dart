import 'package:flutter/material.dart';

class AppColors {
  static const bg       = Color(0xFF0A0A14);
  static const bgDark   = Color(0xFF0A0E1A);
  static const surface  = Color(0xFF0F0F1A);
  static const surface2 = Color(0xFF151520);
  static const border   = Color(0xFF1A2A2A);
  static const border2  = Color(0xFF1A1A2A);

  static const teal    = Color(0xFF4AE8C0);  // primary text/icon teal
  static const green   = Color(0xFF00FFAA);  // neon green (active/success)
  static const blue    = Color(0xFF00AAFF);  // blue (SSH/info)
  static const amber   = Color(0xFFFFAA00);  // warning/agent
  static const red     = Color(0xFFFF4444);  // offline/danger

  static const textPrimary   = Color(0xFFC0D8D0);
  static const textSecondary = Color(0xFF7AA8CC);
  static const textMuted     = Color(0xFF4A6A60);

  // Legacy aliases so existing code doesn't break
  static const primary   = green;
  static const secondary = blue;
  static const danger    = red;
  static const warning   = amber;
}
