/// Layout tokens. Use these instead of magic numbers so spacing stays on a
/// consistent 4pt rhythm across the app.
class AppSpacing {
  const AppSpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;

  /// Standard horizontal padding for page content.
  static const double page = 16;
}

class AppRadius {
  const AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double pill = 999;
}

/// Centralised animation timings so motion feels uniform and "natural".
class AppDurations {
  const AppDurations._();

  static const Duration instant = Duration(milliseconds: 120);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 450);
  static const Duration slower = Duration(milliseconds: 700);

  /// Splash → next screen.
  static const Duration splash = Duration(seconds: 2);
}

/// Standard elevation/opacity values.
class AppElevation {
  const AppElevation._();

  static const double none = 0;
  static const double low = 2;
  static const double medium = 6;
  static const double high = 12;
}
