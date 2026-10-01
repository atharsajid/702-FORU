import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

/// Convenience accessors so screens read `context.text.headlineSmall` instead of
/// `Theme.of(context).textTheme.headlineSmall`.
extension AppContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;

  Size get screenSize => MediaQuery.sizeOf(this);
  bool get keyboardVisible => MediaQuery.viewInsetsOf(this).bottom > 0;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  void unfocus() => FocusScope.of(this).unfocus();

  /// Shows a themed snackbar. Use for lightweight feedback; for errors prefer
  /// `AppErrorHandler.show`.
  void showSnack(String message, {bool isError = false}) {
    final messenger = ScaffoldMessenger.maybeOf(this);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: isError ? AppColors.error : AppColors.success,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(message)),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
  }
}
