import 'package:flutter/material.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/promo_banners.dart';

/// Destination of the "Spotlight your business" ad on every category page.
class SpotlightInfoScreen extends StatelessWidget {
  const SpotlightInfoScreen({super.key});

  static const List<({String title, String price, String body})> _packages = [
    (
      title: 'Category Spotlight',
      price: '\$99 / month',
      body: 'Featured card at the top of one category page.',
    ),
    (
      title: 'Home Spotlight',
      price: '\$199 / month',
      body: 'Rotating banner on the home screen plus a category placement.',
    ),
    (
      title: 'Citywide Campaign',
      price: 'Custom',
      body: 'Across multiple categories with a dedicated exclusive offer.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Spotlight')),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: context.pagePadding,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SpotlightBanner(onTap: _noop),

            const SizedBox(height: AppSpacing.xl),
            Text(
              'Advertise on 702FORU',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Spotlight placements sit at the top of each category page and rotate '
              'on the home screen, putting your business in front of locals and '
              'visitors exactly when they are deciding what to do.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
            ),

            const SizedBox(height: AppSpacing.xl),

            for (final package in _packages) ...[
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppIconTile(icon: Icons.campaign_outlined, size: 44),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  package.title,
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                              ),
                              Text(
                                package.price,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.purple,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            package.body,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            const SizedBox(height: AppSpacing.md),
            AppCard(
              color: AppColors.purple.withValues(alpha: 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Provider agreement',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Choose to run payments through 702FORU for a 12% commission, '
                    'or keep your own processing and pay a flat monthly fee. Every '
                    'coupon carries your 702-4U tracking code for accurate billing.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'List your business',
              size: AppButtonSize.large,
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.signUpProvider),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: 'How it works',
              variant: AppButtonVariant.outline,
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.howItWorks),
            ),
          ],
        ),
      ),
    );
  }

  static void _noop() {}
}
