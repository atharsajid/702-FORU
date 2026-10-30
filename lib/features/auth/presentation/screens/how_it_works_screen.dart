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
              intro: '702FORU is your guide to everything worth doing in Las Vegas — curated by locals.',
              steps: const [
                _Step(
                  icon: Icons.category_outlined,
                  title: 'Browse 12 categories',
                  body: 'Tap a sphere on the home grid to jump into Arts & Culture, Food & Drink, Free Things To Do and more.',
                ),
                _Step(
                  icon: Icons.search_rounded,
                  title: 'Search anything',
                  body: 'Looking for a specific service? Search by name, service or neighbourhood.',
                ),
                _Step(
                  icon: Icons.storefront_outlined,
                  title: 'Open a business page',
                  body: 'Every business shares the same layout: photos, map, services, coupons and reviews.',
                ),
                _Step(
                  icon: Icons.confirmation_number_outlined,
                  title: 'Redeem your coupons',
                  body: 'Free accounts include ${ConsumerCouponPricing.freeCoupons} coupons. Show the code in store, and upgrade any time for more.',
                ),
                _Step(
                  icon: Icons.rate_review_outlined,
                  title: 'Leave a review',
                  body: 'Registered visitors can rate and review any business they have used.',
                ),
              ],
              ctaLabel: 'Create a free account',
              ctaRoute: AppRoutes.signUpUser,
            ),
            _HowItWorksTab(
              intro:
                  'Promote your business on 702ForU and help Las Vegas locals and visitors discover what you offer. Get started with a free 30-day trial.',
              steps: const [
                _Step(
                  icon: Icons.app_registration_rounded,
                  title: 'Choose Your Basic Listing',
                  body: 'Your first 30 days are free, then \$9.99 per month unless you cancel. Add optional advertising whenever you\'re ready.',
                ),
                _Step(
                  icon: Icons.badge_outlined,
                  title: 'Add Your Business Information',
                  body:
                      'Enter your business name, category, address, contact details, hours, and a short description so customers can learn more about your business.',
                ),
                _Step(
                  icon: Icons.dashboard_customize_outlined,
                  title: 'Create Your Business Page',
                  body:
                      'Showcase your business with your logo, photos, services, and promotional video, if available. Give potential customers a better idea of what you offer.',
                ),
                _Step(
                  icon: Icons.local_offer_outlined,
                  title: 'Create Coupons & Special Offers',
                  body:
                      'Create exclusive coupons and special offers to encourage customers to discover your business. Track redemptions using your 702ForU coupon codes, if redemption tracking is enabled.',
                ),
                _Step(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Get Paid Directly',
                  body: 'Customers pay you directly. 702ForU does not process customer payments or charge commissions on your sales.',
                ),
                _Step(
                  icon: Icons.campaign_outlined,
                  title: 'Grow Your Visibility with Advertising',
                  body:
                      'Want more exposure? Ask about optional Spotlight placements, video advertising, and premium banners. Pricing is provided for your approval before any advertising purchase.',
                ),
                _Step(
                  icon: null,
                  title: 'Ready to Get Started?',
                  body: 'Choose your listing, showcase your business, and connect with potential customers.',
                ),
              ],
              ctaLabel: 'Start My Free Listing',
              ctaRoute: AppRoutes.signUpProvider,
            ),
          ],
        ),
      ),
    );
  }
}

class _HowItWorksTab extends StatelessWidget {
  const _HowItWorksTab({required this.intro, required this.steps, required this.ctaLabel, required this.ctaRoute});

  final String intro;
  final List<_Step> steps;
  final String ctaLabel;
  final String ctaRoute;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: context.pagePadding, vertical: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(intro, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.xl),
            for (final step in steps) ...[
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (step.icon != null) ...[AppIconTile(icon: step.icon!, size: 44), const SizedBox(width: AppSpacing.md)],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(step.title, style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: AppSpacing.xs),
                          Text(step.body, style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            const SizedBox(height: AppSpacing.md),
            AppButton(label: ctaLabel, size: AppButtonSize.large, onPressed: () => Navigator.of(context).pushNamed(ctaRoute)),
          ],
        ),
      ),
    );
  }
}

class _Step {
  const _Step({required this.icon, required this.title, required this.body});

  final IconData? icon;
  final String title;
  final String body;
}
