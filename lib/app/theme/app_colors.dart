import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFF07110F);
  static const Color backgroundAlt = Color(0xFF111816);
  static const Color surface = Color(0xFF17201D);
  static const Color surfaceLight = Color(0xFF20302B);
  static const Color ink = Color(0xFF0C1210);

  static const Color accentPrimary = Color(0xFF45E0C2);
  static const Color accentSecondary = Color(0xFF34D399);
  static const Color accentTertiary = Color(0xFF059669);
  static const Color accentBlue = Color(0xFF5DB7DE);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB2C3BD);
  static const Color textMuted = Color(0xFF71827C);

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentPrimary, accentSecondary, accentTertiary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xCC17201D), Color(0x8820302B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color glow = Color(0x4D45E0C2);
  static const Color glowWarm = Color(0x4D34D399);
}
