import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Progress header shared by the business signup steps.
class SignupStepHeader extends StatelessWidget {
  const SignupStepHeader({
    super.key,
    required this.step,
    required this.total,
    required this.title,
    required this.subtitle,
    this.stepLabels = const [],
  });

  final int step;
  final int total;
  final String title;
  final String subtitle;
  final List<String> stepLabels;

  @override
  Widget build(BuildContext context) {
    final label = stepLabels.length >= step ? stepLabels[step - 1] : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'STEP $step OF $total',
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppColors.purple,
              ),
            ),
            if (label != null) ...[
              const SizedBox(width: AppSpacing.sm),
              Text(
                '· $label',
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: LinearProgressIndicator(
            value: step / total,
            minHeight: 5,
            backgroundColor: AppColors.greyLight,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.purple),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(title, style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
