import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Background
  static const Color background = Color(0xFF0A0E21);
  static const Color surface = Color(0xFF1A1F3A);
  static const Color surfaceLight = Color(0xFF252A4A);

  // Accents
  static const Color accentPrimary = Color(0xFF00D9FF);
  static const Color accentSecondary = Color(0xFF7B2FFF);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8D8DAA);

  // Gradients
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentPrimary, accentSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [
      Color(0x991A1F3A),
      Color(0x661A1F3A),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glow
  static const Color glow = Color(0x4D00D9FF);
  static const Color glowPurple = Color(0x4D7B2FFF);
}
