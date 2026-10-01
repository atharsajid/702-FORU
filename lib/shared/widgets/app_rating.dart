import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/utils/formatters.dart';

/// Read-only star row. Supports half stars.
class AppRatingStars extends StatelessWidget {
  const AppRatingStars({
    super.key,
    required this.rating,
    this.size = 16,
    this.color = AppColors.gold,
  });

  final double rating;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final position = index + 1;
        final IconData icon;
        if (rating >= position) {
          icon = Icons.star_rounded;
        } else if (rating >= position - 0.5) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_outline_rounded;
        }
        return Icon(
          icon,
          size: size,
          color: icon == Icons.star_outline_rounded
              ? AppColors.greyLight
              : color,
        );
      }),
    );
  }
}

/// Compact `★ 4.8 (214)` badge.
class AppRatingBadge extends StatelessWidget {
  const AppRatingBadge({
    super.key,
    required this.rating,
    this.reviewCount,
    this.compact = false,
  });

  final double rating;
  final int? reviewCount;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 16, color: AppColors.gold),
        const SizedBox(width: 3),
        Text(
          AppFormatters.rating(rating),
          style: TextStyle(
            fontSize: compact ? 12.5 : 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        if (reviewCount != null) ...[
          const SizedBox(width: AppSpacing.xs),
          Text(
            '(${AppFormatters.compact(reviewCount!)})',
            style: TextStyle(
              fontSize: compact ? 11 : 12.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

/// Interactive 1–5 star picker used when writing a review.
class AppRatingPicker extends StatelessWidget {
  const AppRatingPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 34,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = (index + 1).toDouble();
        final isFilled = value >= starValue;
        return IconButton(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 2),
          constraints: const BoxConstraints(),
          tooltip: '${starValue.toInt()} star${index == 0 ? '' : 's'}',
          onPressed: () => onChanged(starValue),
          icon: Icon(
            isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
            size: size,
            color: isFilled ? AppColors.gold : AppColors.greyLight,
          ),
        );
      }),
    );
  }
}
