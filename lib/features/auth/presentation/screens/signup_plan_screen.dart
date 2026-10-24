import 'package:flutter/material.dart';

import '../../../../core/config/pricing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../widgets/signup_step_header.dart';

/// Business signup step 1 — pick the listing plan.
class SignupPlanScreen extends StatelessWidget {
  const SignupPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Business sign up')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: context.pagePadding,
              vertical: AppSpacing.lg,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SignupStepHeader(
                    step: 1,
                    total: 4,
                    title: 'Choose your plan',
                    subtitle:
                        'Start with the Basic Listing. You can add advertising '
                        'later — or ask for a quote during signup.',
                    stepLabels: [
                      'Plan',
                      'Business',
                      'Advertising',
                      'Agreement',
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  AppCard(
                    border: Border.all(color: AppColors.purple, width: 1.6),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const AppIconTile(
                              icon: Icons.storefront_outlined,
                              size: 42,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                BusinessListingPricing.planName,
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                            ),
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.purple,
                              size: 22,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          BusinessListingPricing.trialLabel.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.purple,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'then ${BusinessListingPricing.monthlyLabel} '
                          'unless cancelled',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        for (final item in const [
                          'Category listing with your description and contact details',
                          'Website and social links',
                          'Standard visibility in search and categories',
                        ])
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.xs),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  size: 15,
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'A valid payment method is required to start the '
                          'trial. Cancel before day '
                          '${BusinessListingPricing.trialDays} to avoid the '
                          'first charge.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  AppCard(
                    color: AppColors.purple.withValues(alpha: 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.campaign_outlined,
                              size: 20,
                              color: AppColors.purple,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                'Want more attention?',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Spotlight placement, video advertising and '
                          'premium banners can be added during step 3. '
                          '${BusinessListingPricing.confirmationNote}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AppButton(
                          label: 'See advertising options',
                          variant: AppButtonVariant.ghost,
                          size: AppButtonSize.small,
                          icon: Icons.open_in_new_rounded,
                          onPressed: () => Navigator.of(context)
                              .pushNamed(AppRoutes.spotlightInfo),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: 'Continue',
                    size: AppButtonSize.large,
                    trailingIcon: Icons.arrow_forward_rounded,
                    onPressed: () => Navigator.of(context)
                        .pushNamed(AppRoutes.signUpProviderBusiness),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Center(
                    child: Text(
                      'No charge today. Your ${BusinessListingPricing.trialDays}-day '
                      'trial starts when the listing is activated.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
