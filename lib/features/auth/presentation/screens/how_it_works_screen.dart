import 'package:flutter/material.dart';

import '../../../../core/config/pricing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';

/// "How it works" with separate explanations for users and providers,
/// exactly as requested for the sign-up journey.
class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('How it works'),
          bottom: const TabBar(
            labelColor: AppColors.white,
            unselectedLabelColor: AppColors.greyLight,
            indicatorColor: AppColors.violet,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
            tabs: [
              Tab(text: 'For visitors'),
              Tab(text: 'For businesses'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _HowItWorksTab(
              intro:
                  '702FORU is your guide to everything worth doing in Las Vegas — curated by locals.',
              steps: const [
                _Step(
                  icon: Icons.category_outlined,
                  title: 'Browse 12 categories',
                  body:
                      'Tap a sphere on the home grid to jump into Arts & Culture, Food & Drink, Free Things To Do and more.',
                ),
                _Step(
                  icon: Icons.search_rounded,
                  title: 'Search anything',
                  body:
                      'Looking for a specific service? Search by name, service or neighbourhood.',
                ),
                _Step(
                  icon: Icons.storefront_outlined,
                  title: 'Open a business page',
                  body:
                      'Every business shares the same layout: photos, map, services, coupons and reviews.',
                ),
                _Step(
                  icon: Icons.confirmation_number_outlined,
                  title: 'Redeem your coupons',
                  body:
                      'Free accounts include ${ConsumerCouponPricing.freeCoupons} coupons. Show the code in store, and upgrade any time for more.',
                ),
                _Step(
                  icon: Icons.rate_review_outlined,
                  title: 'Leave a review',
                  body:
                      'Registered visitors can rate and review any business they have used.',
                ),
              ],
              ctaLabel: 'Create a free account',
              ctaRoute: AppRoutes.signUpUser,
            ),
            _HowItWorksTab(
              intro:
                  'List your business in front of thousands of Las Vegas locals and visitors — free for ${BusinessListingPricing.trialDays} days.',
              steps: const [
                _Step(
                  icon: Icons.app_registration_rounded,
                  title: 'Choose the Basic Listing',
                  body:
                      'Free for ${BusinessListingPricing.trialDays} days, then ${BusinessListingPricing.monthlyLabel} unless you cancel. Add advertising whenever you are ready.',
                ),
                _Step(
                  icon: Icons.badge_outlined,
                  title: 'Add your business information',
                  body:
                      'Legal and public name, category, address, contact details, hours and a short description — the same details as the enrollment form.',
                ),
                _Step(
                  icon: Icons.dashboard_customize_outlined,
                  title: 'Get your own listing page',
                  body:
                      'Upload your logo or promo video, describe your services and add photos.',
                ),
                _Step(
                  icon: Icons.local_offer_outlined,
                  title: 'Create coupons',
                  body:
                      'Each coupon carries your 702-4U code, so you can see which offers are working.',
                ),
                _Step(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Get paid directly',
                  body:
                      'Customers pay you directly. 702FORU does not collect customer payments or take a commission on your sales.',
                ),
                _Step(
                  icon: Icons.campaign_outlined,
                  title: 'Grow with advertising',
                  body:
                      'Ask for a quote on Spotlight, video advertising or a premium banner. Pricing is confirmed before anything is charged.',
                ),
              ],
              ctaLabel: 'Start my free listing',
              ctaRoute: AppRoutes.signUpProvider,
            ),
          ],
        ),
      ),
    );
  }
}

class _HowItWorksTab extends StatelessWidget {
  const _HowItWorksTab({
    required this.intro,
    required this.steps,
    required this.ctaLabel,
    required this.ctaRoute,
  });

  final String intro;
  final List<_Step> steps;
  final String ctaLabel;
  final String ctaRoute;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: context.pagePadding,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              intro,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSpacing.xl),
            for (final step in steps) ...[
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppIconTile(icon: step.icon, size: 44),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step.title,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            step.body,
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
            AppButton(
              label: ctaLabel,
              size: AppButtonSize.large,
              onPressed: () => Navigator.of(context).pushNamed(ctaRoute),
            ),
          ],
        ),
      ),
    );
  }
}

class _Step {
  const _Step({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;
}
