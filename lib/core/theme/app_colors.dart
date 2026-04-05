import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF1B5E7B);
  static const Color primaryLight = Color(0xFF4A90B8);
  static const Color primaryDark = Color(0xFF0D3B52);
  static const Color accent = Color(0xFFE8A838);
  static const Color accentLight = Color(0xFFF5D590);

  // Semantic
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);

  // Attendance
  static const Color present = Color(0xFF27AE60);
  static const Color absent = Color(0xFFE74C3C);
  static const Color excused = Color(0xFFF39C12);
  static const Color late = Color(0xFFE67E22);

  // Prayer status
  static const Color completed = Color(0xFF27AE60);
  static const Color missed = Color(0xFFE74C3C);
  static const Color pending = Color(0xFF95A5A6);
  static const Color snoozed = Color(0xFFF39C12);

  // Backgrounds
  static const Color backgroundLight = Color(0xFFF7F8FC);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFF0F2F8);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);

  // Others
  static const Color divider = Color(0xFFE5E7EB);
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1B5E7B), Color(0xFF2980B9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
