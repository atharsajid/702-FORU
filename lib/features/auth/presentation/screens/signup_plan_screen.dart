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
            padding: EdgeInsets.symmetric(horizontal: context.pagePadding, vertical: AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SignupStepHeader(
                    step: 1,
                    total: 4,
                    title: 'Choose Your Plan',
                    subtitle:
                        'Start with a Basic Listing and add optional '
                        'advertising whenever you\'re ready.',
                    stepLabels: ['Plan', 'Business', 'Advertising', 'Agreement'],
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
                            const AppIconTile(icon: Icons.storefront_outlined, size: 42),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(child: Text(BusinessListingPricing.planName, style: Theme.of(context).textTheme.headlineSmall)),
                            const Icon(Icons.check_circle_rounded, color: AppColors.purple, size: 22),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          BusinessListingPricing.trialLabel.toUpperCase(),
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.purple),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Then ${BusinessListingPricing.monthlyLabel}, '
                          'unless you cancel before your trial ends.',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        for (final item in const [
                          'Business listing with your description and contact details',
                          'Website and social media links',
                          'Standard visibility in search results and categories',
                        ])
                          Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle_rounded, size: 15, color: AppColors.success),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(child: Text(item, style: const TextStyle(fontSize: 12.5, height: 1.35))),
                              ],
                            ),
                          ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          "A valid payment method is required to start your free trial. You won't be charged today. Your subscription will automatically renew at ${BusinessListingPricing.monthlyLabel} after the 30-day trial unless you cancel before the trial ends.",
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
                            const Icon(Icons.campaign_outlined, size: 20, color: AppColors.purple),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(child: Text('Want More Visibility?', style: Theme.of(context).textTheme.headlineSmall)),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          "Promote your business with optional Spotlight placements, video advertising, and premium banners.\n\nExplore advertising options during Step 3. All advertising prices will be confirmed with you before purchase.",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AppButton(
                          label: 'See Advertising Options',
                          variant: AppButtonVariant.ghost,
                          size: AppButtonSize.small,
                          icon: Icons.open_in_new_rounded,
                          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.spotlightInfo),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: 'Continue',
                    size: AppButtonSize.large,
                    trailingIcon: Icons.arrow_forward_rounded,
                    onPressed: () => Navigator.of(context).pushNamed(AppRoutes.signUpProviderBusiness),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Center(
                    child: Text(
                      'No charge today. Your 30-day free trial begins when your listing is activated.',
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
