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
  static const Color transparent = Color(0x00000000);
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

  // ── Category spheres ──────────────────────────────────────────────────
  /// Hot specular riding the rim of every category sphere.
  static const Color sphereHighlight = Color(0xFFF7F1FF);

  /// Violet the rim and its shadows settle into away from the light.
  static const Color sphereRecess = Color(0xFF2B0F5E);

  /// Halo bleeding out of every sphere – a saturated core plus a wide bloom.
  /// Alphas are baked in; both layers sit *behind* the rim.
  static const Color sphereGlow = Color(0x997B2FF7);
  static const Color sphereGlowBloom = Color(0x40A855F7);

  /// Rim lighting for every category sphere.
  ///
  /// Runs across the ball on the light's own axis – brightest at the top with a
  /// lean to the right, rolling through vivid violet into a deep shadow at the
  /// bottom – which is what makes the rim read as a convex tube rather than a
  /// flat band. Stops bunch up at the dark end so the shadow has a soft
  /// shoulder instead of a hard terminator.
  static const LinearGradient sphereRimGradient = LinearGradient(
    begin: Alignment(0.45, -1),
    end: Alignment(-0.45, 1),
    colors: [
      white,
      sphereHighlight,
      Color(0xFFE6D8FF),
      Color(0xFFCFAEFF),
      Color(0xFFA56CFA),
      Color(0xFF8340E0),
      Color(0xFF5B1FB8),
      Color(0xFF45158A),
      Color(0xFF340F6B),
    ],
    stops: [0, 0.09, 0.22, 0.34, 0.47, 0.60, 0.74, 0.88, 1],
  );

  /// Radial gradient applied to category spheres that have no photo yet.
  static const List<Color> spherePlaceholderGradient = [
    Color(0xFFA855F7),
    Color(0xFF6D28D9),
    Color(0xFF3B1D6E),
  ];
}
