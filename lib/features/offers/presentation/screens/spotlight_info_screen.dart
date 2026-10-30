import 'package:flutter/material.dart';

import '../../../../core/config/pricing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';

/// Advertising page: the Basic Listing plus the three paid placements.
///
/// Reached from the "Spotlight your business" card on category pages and from
/// the provider dashboard.
class SpotlightInfoScreen extends StatelessWidget {
  const SpotlightInfoScreen({super.key});

  static const List<String> _basicIncludes = [
    'Your business listed in the relevant 702ForU category',
    'Your business name, approved description, and contact details',
    'Your website and social media links',
    'Standard visibility in search results and categories',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Advertise')),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: context.pagePadding, vertical: AppSpacing.lg),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _AdvertisingHero(),
                const SizedBox(height: AppSpacing.xl),

                // ── Basic listing ──────────────────────────────────────
                Row(
                  children: [
                    const Expanded(child: _SectionTitle('Start with a Basic Listing')),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.purple.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(AppRadius.pill)),
                      child: const Text(
                        'START HERE',
                        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: AppColors.purple),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        BusinessListingPricing.trialLabel.toUpperCase(),
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.purple),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Then ${BusinessListingPricing.monthlyLabel} unless you cancel before your free trial ends.",
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      for (final item in _basicIncludes)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(child: Text(item, style: const TextStyle(fontSize: 13, height: 1.35))),
                            ],
                          ),
                        ),
                      const SizedBox(height: AppSpacing.md),
                      AppButton(
                        label: 'Start My Free Listing',
                        icon: Icons.storefront_outlined,
                        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.signUpProvider),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        "A valid payment method is required to begin your free trial. You won’t be charged during the 30-day trial. Your subscription will automatically renew at \$9.99 per month after the trial unless you cancel before it ends.",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // ── Paid placements ────────────────────────────────────
                const _SectionTitle('Advertising & Placements'),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Enhance your Basic Listing with optional advertising opportunities designed to help customers discover your business. Pricing is provided for your approval before any advertising is purchased.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                for (final product in advertisingProducts) ...[
                  _AdvertisingCard(product: product, onQuote: () => _showQuote(context, product)),
                  const SizedBox(height: AppSpacing.md),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text("All advertising options are optional. Pricing, placement, and duration will be confirmed with you before purchase.", style: Theme.of(context).textTheme.bodySmall)),
                  ],
                ),

                const SizedBox(height: AppSpacing.xxl),

                // ── Payments ───────────────────────────────────────────
                AppCard(
                  color: AppColors.purple.withValues(alpha: 0.06),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.account_balance_wallet_outlined, size: 20, color: AppColors.purple),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(child: Text('Your customers, your payments', style: Theme.of(context).textTheme.headlineSmall)),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Customers pay you directly. 702FORU does not collect '
                        'customer payments or take a commission on your sales — '
                        'the monthly listing fee is the only charge.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: 'List your business',
                  size: AppButtonSize.large,
                  onPressed: () => Navigator.of(context).pushNamed(AppRoutes.signUpProvider),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: 'How it works',
                  variant: AppButtonVariant.outline,
                  onPressed: () => Navigator.of(context).pushNamed(AppRoutes.howItWorks),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void _showQuote(BuildContext context, AdvertisingProduct product) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl))),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(color: AppColors.greyLight, borderRadius: BorderRadius.circular(AppRadius.pill)),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Center(child: AppIconTile(icon: product.icon, size: 54)),
            const SizedBox(height: AppSpacing.md),
            Text(product.name, textAlign: TextAlign.center, style: Theme.of(sheetContext).textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(product.tagline, textAlign: TextAlign.center, style: Theme.of(sheetContext).textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.lg),
            for (final feature in product.features)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: Text(feature, style: const TextStyle(fontSize: 13, height: 1.35))),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppRadius.md)),
              child: Row(
                children: [
                  const Icon(Icons.request_quote_outlined, size: 18, color: AppColors.warning),
                  const SizedBox(width: AppSpacing.sm),
                  const Expanded(
                    child: Text(
                      'Pricing for this placement is pending final '
                      'confirmation. Start your free listing and we will walk '
                      'you through the quote before anything is charged.',
                      style: TextStyle(fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Start with a Basic Listing',
              icon: Icons.storefront_outlined,
              onPressed: () {
                Navigator.of(sheetContext).pop();
                Navigator.of(context).pushNamed(AppRoutes.signUpProvider);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(label: 'Maybe later', variant: AppButtonVariant.ghost, onPressed: () => Navigator.of(sheetContext).pop()),
          ],
        ),
      ),
    );
  }
}

class _AdvertisingHero extends StatelessWidget {
  const _AdvertisingHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(gradient: AppColors.navyGradient, borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
            decoration: BoxDecoration(color: AppColors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppRadius.pill)),
            child: const Text(
              'ADVERTISE ON 702FORU',
              style: TextStyle(color: AppColors.cyan, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Help Las Vegas Discover Your Business',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: AppColors.white, height: 1.15),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Create your Basic Listing to showcase your business to Las Vegas locals and visitors. Add optional Spotlight placements, video advertising, or premium banners whenever you\'re ready.',
            style: TextStyle(color: AppColors.white.withValues(alpha: 0.82), fontSize: 13.5, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _AdvertisingCard extends StatelessWidget {
  const _AdvertisingCard({required this.product, required this.onQuote});

  final AdvertisingProduct product;
  final VoidCallback onQuote;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppIconTile(icon: product.icon, size: 44),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 2),
                    Text(product.tagline, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(product.description, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          for (final feature in product.features)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline_rounded, size: 15, color: AppColors.purple),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(feature, style: const TextStyle(fontSize: 12.5, height: 1.35))),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Expanded(
              //   child: Text(
              //     product.priceLabel,
              //     style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.purple),
              //   ),
              // ),
              AppButton(
                label: 'Request a quote',
                size: AppButtonSize.small,
                variant: AppButtonVariant.outline,
                isFullWidth: false,
                onPressed: onQuote,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Text(title, style: Theme.of(context).textTheme.headlineMedium);
}
