import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Single source of truth for the type scale.
class AppTypography {
  const AppTypography._();

  static const TextTheme textTheme = TextTheme(
    // Display / hero
    displayLarge: TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.w800,
      height: 1.15,
      color: AppColors.textPrimary,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      height: 1.18,
      color: AppColors.textPrimary,
    ),

    // Headings
    headlineLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.22,
      color: AppColors.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      height: 1.25,
      color: AppColors.textPrimary,
    ),
    headlineSmall: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      height: 1.3,
      color: AppColors.textPrimary,
    ),

    // Body
    bodyLarge: TextStyle(
      fontSize: 16,
      height: 1.5,
      color: AppColors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      height: 1.45,
      color: AppColors.textSecondary,
    ),
    bodySmall: TextStyle(
      fontSize: 12.5,
      height: 1.4,
      color: AppColors.textSecondary,
    ),

    // Labels / buttons
    labelLarge: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.1,
      color: AppColors.textPrimary,
    ),
    labelMedium: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    labelSmall: TextStyle(
      fontSize: 11.5,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
      color: AppColors.textSecondary,
    ),
  );
}
