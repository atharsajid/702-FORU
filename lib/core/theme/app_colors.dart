import 'package:flutter/material.dart';

/// Central brand palette for 702FORU.
///
/// Feature code must never hard-code a [Color]. Use these tokens (or
/// `Theme.of(context).colorScheme`) so the whole product stays consistent and
/// re-brandable from one place.
class AppColors {
  const AppColors._();

  // ── Brand ─────────────────────────────────────────────────────────────
  /// Deep navy used for app bars, splash and hero surfaces.
  static const Color navy = Color(0xFF0A0A3C);
  static const Color navyLight = Color(0xFF1B1B5A);
  static const Color navyDark = Color(0xFF060628);

  /// Primary action colour (Sign In / Sign Up, CTAs).
  static const Color purple = Color(0xFF7B2FF7);
  static const Color purpleDark = Color(0xFF5B1FB8);
  static const Color violet = Color(0xFFA855F7);

  /// Existing splash accent – kept for brand continuity.
  static const Color cyan = Color(0xFF77D1DA);

  static const Color gold = Color(0xFFFFC107);

  // ── Neutrals ──────────────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF0B0B0F);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFE3E3EA);
  static const Color greyDark = Color(0xFF424242);

  // ── Surfaces ──────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF7F7FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF0F0F6);

  // ── Text ──────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF16161F);
  static const Color textSecondary = Color(0xFF5B5B6B);
  static const Color textInverse = Color(0xFFFFFFFF);

  // ── Status ────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFB300);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  // ── Gradients ─────────────────────────────────────────────────────────
  static const LinearGradient brandGradient = LinearGradient(
    colors: [purple, violet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient navyGradient = LinearGradient(
    colors: [navy, navyLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Radial gradient applied behind every category "sphere".
  static const List<Color> sphereGradient = [
    Color(0xFFB98CFF),
    Color(0xFF7B2FF7),
    Color(0xFF4C1D95),
  ];

  /// Radial gradient applied to category spheres that have no photo yet.
  static const List<Color> spherePlaceholderGradient = [
    Color(0xFFA855F7),
    Color(0xFF6D28D9),
    Color(0xFF3B1D6E),
  ];
}
