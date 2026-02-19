import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background    = Color(0xFF0D0F1A);
  static const Color surface       = Color(0xFF161928);
  static const Color surfaceLight  = Color(0xFF1E2235);
  static const Color card          = Color(0xFF1A1E30);


  // Accents
  static const Color accent         = Color(0xFFE8B84B);   // Gold
  static const Color accentSecondary = Color(0xFF4BE8C8);  // Teal
  static const Color accentPurple   = Color(0xFF8B6FE8);

  // Status colors
  static const Color success = Color(0xFF4CAF82);
  static const Color warning = Color(0xFFF5A623);
  static const Color danger  = Color(0xFFE85D5D);

  // Text
  static const Color textPrimary   = Color(0xFFF0F2FF);
  static const Color textSecondary = Color(0xFF8A90B0);
  static const Color textHint      = Color(0xFF4A5070);

  // Grade colors map
  static Color gradeColor(String grade) {
    switch (grade) {
      case 'A+':
      case 'A':
        return const Color(0xFF4CAF82);
      case 'A-':
      case 'B+':
        return const Color(0xFF6BCF7F);
      case 'B':
      case 'B-':
        return const Color(0xFFE8B84B);
      case 'C+':
      case 'C':
        return const Color(0xFFF5A623);
      case 'C-':
      case 'D':
        return const Color(0xFFE85D5D);
      case 'F':
        return const Color(0xFFB84B4B);
      default:
        return const Color(0xFF8A90B0);
    }
  }



}