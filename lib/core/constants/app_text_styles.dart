import 'package:flutter/material.dart';
import 'app_color.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle displayXL = TextStyle(
    fontSize: 56, fontWeight: FontWeight.w800,
    color: AppColors.textPrimary, letterSpacing: -2, height: 1.0,
  );

  static const TextStyle display = TextStyle(
    fontSize: 40, fontWeight: FontWeight.w800,
    color: AppColors.textPrimary, letterSpacing: -1.5, height: 1.1,
  );

  static const TextStyle headline = TextStyle(
    fontSize: 26, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, letterSpacing: -0.5,
  );

  static const TextStyle title = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400,
    color: AppColors.textPrimary, height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w400,
    color: AppColors.textSecondary, letterSpacing: 0.2,
  );

  static const TextStyle label = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w700,
    color: AppColors.textSecondary, letterSpacing: 1.5,
  );

  static const TextStyle gpaHero = TextStyle(
    fontSize: 72, fontWeight: FontWeight.w900,
    color: AppColors.accent, letterSpacing: -3, height: 1.0,
  );

  static const TextStyle percentHero = TextStyle(
    fontSize: 60, fontWeight: FontWeight.w900,
    color: AppColors.teal, letterSpacing: -2, height: 1.0,
  );
}