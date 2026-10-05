import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary brand palette inspired by Calorie Tracker / Health & Fitness reference
  static const Color primary = Color(0xFF141618); // Deep charcoal
  static const Color primaryLight = Color(0xFF23262A);
  static const Color primaryDark = Color(0xFF0C0E0F);

  // Vibrant Lime / Mint highlight (Key accent from reference UI)
  static const Color limeAccent = Color(0xFFC8F042); // Bright lime
  static const Color limeLight = Color(0xFFEFFCD0); // Soft pastel lime
  static const Color limeSoft = Color(0xFFF3FCE0); // Ultra soft lime
  static const Color limeText = Color(0xFF284008); // Dark olive for text on lime
  static const Color accent = Color(0xFFC8F042);

  // Background and Surfaces
  static const Color background = Color(0xFFF7F8FA); // Ultra-clean neutral canvas
  static const Color surface = Color(0xFFFFFFFF); // Pure white card
  static const Color surfaceMuted = Color(0xFFF1F3F6); // Soft pill/chip fill
  static const Color border = Color(0xFFECEFF2); // Ultra subtle border
  static const Color borderLight = Color(0xFFF2F4F7);

  // Typography
  static const Color textPrimary = Color(0xFF141618); // Bold dark
  static const Color textSecondary = Color(0xFF7E848D); // Muted secondary
  static const Color textMuted = Color(0xFFA2A7B0); // Tertiary subtle

  // Soft pastel chips (Reference UI Exercise, BPM, Water, Weight)
  static const Color chipLime = Color(0xFFEDFBC8);
  static const Color chipLimeIcon = Color(0xFF5E8B03);
  static const Color chipExercise = Color(0xFFE4F8EB);
  static const Color chipExerciseIcon = Color(0xFF22C55E);
  static const Color chipBpm = Color(0xFFFFECEB);
  static const Color chipBpmIcon = Color(0xFFEF4444);
  static const Color chipWater = Color(0xFFE2F4FE);
  static const Color chipWaterIcon = Color(0xFF0EA5E9);
  static const Color chipWeight = Color(0xFFFFEFE6);
  static const Color chipWeightIcon = Color(0xFFF97316);
  static const Color chipPurple = Color(0xFFF2EBFF);
  static const Color chipPurpleIcon = Color(0xFF8B5CF6);

  // Status semantic
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFE6F9ED);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF7E6);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFFECEC);
  static const Color info = Color(0xFF0EA5E9);
  static const Color infoLight = Color(0xFFE0F4FE);
}
