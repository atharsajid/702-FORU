import 'package:flutter/material.dart';

/// Width thresholds used across the app.
class AppBreakpoints {
  const AppBreakpoints._();

  static const double tablet = 600;
  static const double desktop = 1024;

  /// Reference device width used by [ResponsiveX.sp] (iPhone 15 Pro).
  static const double referenceWidth = 390;
}

/// Responsive helpers available on every [BuildContext].
///
/// Usage: `context.sp(16)`, `context.gridColumns()`, `if (context.isTablet) …`
extension ResponsiveX on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  bool get isTablet => screenWidth >= AppBreakpoints.tablet;
  bool get isDesktop => screenWidth >= AppBreakpoints.desktop;
  bool get isPhone => screenWidth < AppBreakpoints.tablet;
  bool get isLandscape =>
      MediaQuery.orientationOf(this) == Orientation.landscape;

  /// Scales a value designed for a 390pt-wide phone up to the current width,
  /// clamped so tablets do not blow up typography.
  double sp(double size) =>
      size * (screenWidth / AppBreakpoints.referenceWidth).clamp(0.9, 1.25);

  /// Picks a value per breakpoint.
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  /// Sensible grid column count for the current width.
  int gridColumns({int mobile = 3, int tablet = 4, int desktop = 5}) =>
      responsive(mobile: mobile, tablet: tablet, desktop: desktop);

  /// Standard page gutter.
  double get pagePadding => isTablet ? 24 : 16;

  /// Constrains content width on large screens so text does not stretch
  /// edge-to-edge.
  double get maxContentWidth => isDesktop ? 720 : double.infinity;
}

/// Constrains its child to a comfortable reading width on tablets/desktop.
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = 720,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
