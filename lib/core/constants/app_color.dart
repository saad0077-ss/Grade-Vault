import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background     = Color(0xFF080B14);
  static const Color surface        = Color(0xFF111523);
  static const Color surfaceLight   = Color(0xFF1A1F35);
  static const Color card           = Color(0xFF161B2E);
  static const Color cardBorder     = Color(0xFF252B45);

  // Primary gold accent
  static const Color accent         = Color(0xFFFFBB38);
  static const Color accentDark     = Color(0xFFCC8F00);
  static const Color accentGlow     = Color(0x33FFBB38);

  // Secondary accents
  static const Color teal           = Color(0xFF38D9FF);
  static const Color tealGlow       = Color(0x2238D9FF);
  static const Color rose           = Color(0xFFFF5E7D);
  static const Color roseGlow       = Color(0x22FF5E7D);
  static const Color violet         = Color(0xFFAA7FFF);
  static const Color violetGlow     = Color(0x22AA7FFF);
  static const Color mint           = Color(0xFF38FFB4);
  static const Color mintGlow       = Color(0x2238FFB4);

  // Grade colors
  static const Color gradeA         = Color(0xFF38D985);
  static const Color gradeB         = Color(0xFF38C8FF);
  static const Color gradeC         = Color(0xFFFFBB38);
  static const Color gradeD         = Color(0xFFFF8C38);
  static const Color gradeF         = Color(0xFFFF4C6A);

  // Text
  static const Color textPrimary    = Color(0xFFF0F4FF);
  static const Color textSecondary  = Color(0xFF7B85A8);
  static const Color textHint       = Color(0xFF3D445E);

  static Color gradeColor(String grade) {
    if (grade.startsWith('A')) return gradeA;
    if (grade.startsWith('B')) return gradeB;
    if (grade.startsWith('C')) return gradeC;
    if (grade.startsWith('D')) return gradeD;
    return gradeF;
  }

  static Color percentageColor(double pct) {
    if (pct >= 85) return gradeA;
    if (pct >= 70) return gradeB;
    if (pct >= 55) return gradeC;
    if (pct >= 40) return gradeD;
    return gradeF;
  }
}