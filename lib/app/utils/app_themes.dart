import 'package:flutter/material.dart';

class AppColors {
  // 🌟 Primary Brand Colors
  static const Color primary = Color(0xFF0A73B7);
  static const Color secondary = Color(0xFF1D9BF0);
  static const Color accent = Color(0xFF77D1DA); // Splash screen color

  // 🩶 Neutrals
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color darkGrey = Color(0xFF424242);

  // 🖤 Backgrounds
  static Color splashBackgroundColor = Color.fromRGBO(0, 9, 64, 0.943);
  static const Color backgroundLight = Color(0xFFF9F9F9);
  static const Color backgroundDark = Color(0xFF121212);

  // ❤️ Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // 🌈 Gradient Example
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
