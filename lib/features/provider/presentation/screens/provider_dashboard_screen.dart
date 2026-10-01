import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../../../shared/widgets/app_rating.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../catalog/domain/entities/business.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../providers/provider_providers.dart';

/// Business owner's control centre.
class ProviderDashboardScreen extends ConsumerWidget {
  const ProviderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final business = ref.watch(myBusinessProvider);
    final summary = ref.watch(providerSummaryProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Provider Dashboard')),
      body: RefreshIndicator(
        color: AppColors.purple,
        onRefresh: () async {
          ref.invalidate(myBusinessProvider);
          ref.invalidate(myCouponsProvider);
          ref.invalidate(providerSummaryProvider);
          await ref.read(myBusinessProvider.future);
        },
        child: AsyncValueView<Business?>(
          value: business,
          onRetry: () => ref.invalidate(myBusinessProvider),
          builder: (context, listing) {
            if (user == null) {
              return const AppEmptyState(
                title: 'Please sign in',
                message: 'Sign in with a business account to manage your listing.',
                icon: Icons.lock_outline_rounded,
              );
            }
            if (listing == null) {
              return AppEmptyState(
                title: 'No listing yet',
                message:
                    'Create your business listing to start receiving coupon redemptions.',
                icon: Icons.storefront_outlined,
                actionLabel: 'Create a listing',
                onAction: () => Navigator.of(context)
                    .pushNamed(AppRoutes.signUpProvider),
              );
            }

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(
                context.pagePadding,
                AppSpacing.lg,
                context.pagePadding,
                AppSpacing.xxxl,
              ),
              children: [
                // ── Listing header ───────────────────────────────────────
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: AppNetworkImage(
                          url: listing.logoUrl ?? listing.coverUrl,
                          width: 62,
                          height: 62,
                          placeholderIcon: Icons.storefront_outlined,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              listing.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              listing.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            AppRatingBadge(
                              rating: listing.rating,
                              reviewCount: listing.reviewCount,
                              compact: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      AppTag(
                        label: listing.trackingCode.isEmpty
                            ? '702-4U'
                            : listing.trackingCode,
                        color: AppColors.purple.withValues(alpha: 0.10),
                        textColor: AppColors.purple,
                        compact: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // ── Stats ────────────────────────────────────────────────
                summary.when(
                  data: (data) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _StatTile(
                              label: 'Coupons',
                              value: '${data.coupons}',
                              icon: Icons.confirmation_number_outlined,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _StatTile(
                              label: 'Redemptions',
                              value: AppFormatters.compact(data.redemptions),
                              icon: Icons.redeem_outlined,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: _StatTile(
                              label: 'Reviews',
                              value: '${data.reviews}',
                              icon: Icons.rate_review_outlined,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _StatTile(
                              label: 'Rating',
                              value: AppFormatters.rating(data.rating),
                              icon: Icons.star_outline_rounded,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // ── Billing ────────────────────────────────────────
                      AppCard(
                        color: AppColors.navy,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.receipt_long_outlined,
                                  color: AppColors.cyan,
                                  size: 20,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  'Estimated billing this period',
                                  style: TextStyle(
                                    color: AppColors.white.withValues(alpha: 0.85),
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: _BillingFigure(
                                    label:
                                        '12% commission\n(${data.redemptions} × \$${ProviderSummary.averageTicket.toStringAsFixed(0)})',
                                    value: AppFormatters.price(data.commissionOwed),
                                  ),
                                ),
                                Container(
                                  height: 46,
                                  width: 1,
                                  color: AppColors.white.withValues(alpha: 0.15),
                                ),
                                Expanded(
                                  child: _BillingFigure(
                                    label: 'Flat fee option',
                                    value: AppFormatters.price(data.flatFee),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Commission is calculated from coupon redemptions tracked '
                              'through your ${listing.trackingCode} code.',
                              style: TextStyle(
                                color: AppColors.white.withValues(alpha: 0.7),
                                fontSize: 11,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  loading: () => const AppLoading(),
                  error: (error, _) => AppErrorView(
                    message: 'Could not load your stats.',
                    onRetry: () => ref.invalidate(providerSummaryProvider),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // ── Actions ──────────────────────────────────────────────
                AppButton(
                  label: 'Manage coupons',
                  icon: Icons.local_offer_outlined,
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.providerCoupons),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: 'Edit listing',
                  variant: AppButtonVariant.secondary,
                  icon: Icons.edit_outlined,
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.businessEditor),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: 'View public page',
                  variant: AppButtonVariant.outline,
                  icon: Icons.visibility_outlined,
                  onPressed: () => Navigator.of(context).pushNamed(
                    AppRoutes.business,
                    arguments: listing.id,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIconTile(icon: icon, size: 34),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _BillingFigure extends StatelessWidget {
  const _BillingFigure({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.7),
              fontSize: 11,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
