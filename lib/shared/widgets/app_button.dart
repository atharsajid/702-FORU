import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

enum AppButtonVariant { primary, secondary, outline, ghost, danger }

enum AppButtonSize { small, medium, large }

/// The single button used across the app.
///
/// Handles loading state, icons, full-width layout and haptics-free disabled
/// states so screens never re-implement button styling.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.enabled = true,
    this.textColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool isLoading;
  final Color? textColor;

  /// Stretch to the parent width (default) or hug the content.
  final bool isFullWidth;
  final bool enabled;

  bool get _isEnabled => enabled && !isLoading && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final content = _content(context);
    final padding = _padding;
    final radius = BorderRadius.circular(AppRadius.md);

    final button = switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
          onPressed: _isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.purple,
            foregroundColor: AppColors.white,
            padding: padding,
            shape: RoundedRectangleBorder(borderRadius: radius),
          ),
          child: content,
        ),
      AppButtonVariant.secondary => ElevatedButton(
          onPressed: _isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.navy,
            foregroundColor: AppColors.white,
            padding: padding,
            shape: RoundedRectangleBorder(borderRadius: radius),
          ),
          child: content,
        ),
      AppButtonVariant.outline => OutlinedButton(
          onPressed: _isEnabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.navy,
            padding: padding,
            shape: RoundedRectangleBorder(borderRadius: radius),
          ),
          child: content,
        ),
      AppButtonVariant.ghost => TextButton(
          onPressed: _isEnabled ? onPressed : null,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.purple,
            padding: padding,
            shape: RoundedRectangleBorder(borderRadius: radius),
          ),
          child: content,
        ),
      AppButtonVariant.danger => ElevatedButton(
          onPressed: _isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.white,
            padding: padding,
            shape: RoundedRectangleBorder(borderRadius: radius),
          ),
          child: content,
        ),
    };

    if (!isFullWidth) return button;
    return SizedBox(width: double.infinity, child: button);
  }

  EdgeInsets get _padding => switch (size) {
        AppButtonSize.small => const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
        AppButtonSize.medium => const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
        AppButtonSize.large => const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.lg,
          ),
      };

  double get _fontSize => switch (size) {
        AppButtonSize.small => 13,
        AppButtonSize.medium => 15,
        AppButtonSize.large => 16,
      };

  double get _loaderSize => switch (size) {
        AppButtonSize.small => 14,
        AppButtonSize.medium => 18,
        AppButtonSize.large => 20,
      };

  Widget _content(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: _loaderSize,
        width: _loaderSize,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: _fontSize + 3),
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: _fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
              color: textColor,
            ),
          ),
        ),
        if (trailingIcon != null) ...[
          const SizedBox(width: AppSpacing.sm),
          Icon(trailingIcon, size: _fontSize + 1),
        ],
      ],
    );
  }
}
