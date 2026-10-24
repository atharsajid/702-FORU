import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/external_link.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/map_launcher.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../../../shared/widgets/app_rating.dart';
import '../../../../shared/widgets/map_preview_card.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/business.dart';
import '../../domain/entities/coupon.dart';
import '../../domain/entities/review.dart';
import '../providers/catalog_providers.dart';
import '../providers/coupon_quota_providers.dart';
import '../widgets/coupon_access_sheet.dart';

/// The layout every business on 702FORU shares.
class BusinessScreen extends ConsumerWidget {
  const BusinessScreen({super.key, required this.businessId});

  final String businessId;

  /// Reference point for the distance label: the centre of the Strip. There is
  /// no device geolocation yet, so the card never claims "from you".
  static const double _refLat = 36.1699;
  static const double _refLng = -115.1398;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final business = ref.watch(businessByIdProvider(businessId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AsyncValueView<Business>(
        value: business,
        onRetry: () => ref.invalidate(businessByIdProvider(businessId)),
        builder: (context, data) => _BusinessContent(business: data),
      ),
    );
  }

  static String distanceLabel(Business business) {
    final lat = business.latitude;
    final lng = business.longitude;
    if (lat == null || lng == null) return 'Las Vegas, NV';

    const earthRadiusMiles = 3958.8;
    final dLat = _toRadians(lat - _refLat);
    final dLng = _toRadians(lng - _refLng);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) + math.cos(_toRadians(_refLat)) * math.cos(_toRadians(lat)) * math.sin(dLng / 2) * math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final miles = earthRadiusMiles * c;
    if (miles < 0.1) return '< 0.1 mi from the Strip';
    return '${miles.toStringAsFixed(1)} mi from the Strip';
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180;
}

class _BusinessContent extends ConsumerWidget {
  const _BusinessContent({required this.business});

  final Business business;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isFavorite = ref.watch(isFavoriteProvider(business.id));
    final coupons = ref.watch(couponsForBusinessProvider(business.id));
    final reviews = ref.watch(reviewsProvider(business.id));
    final isOwner = user?.businessId == business.id;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Hero cover ─────────────────────────────────────────────────
        SliverAppBar(
          expandedHeight: 230,
          pinned: true,
          title: Text(business.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          actions: [
            IconButton(
              tooltip: isFavorite ? 'Remove from saved' : 'Save business',
              onPressed: () async {
                if (user == null) {
                  Navigator.of(context).pushNamed(AppRoutes.login);
                  return;
                }
                await ref.read(favoritesControllerProvider.notifier).toggle(business.id);
                if (context.mounted) {
                  context.showSnack(isFavorite ? 'Removed from saved' : 'Saved to your list');
                }
              },
              icon: Icon(isFavorite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                AppNetworkImage(url: business.coverUrl ?? business.logoUrl, placeholderIcon: Icons.storefront_outlined),
                // Keeps the app bar icons legible over bright photos.
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x66000000), Color(0x00000000)],
                      stops: [0, 0.6],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.pagePadding, vertical: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Name + rating ────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(business.name, style: Theme.of(context).textTheme.displayMedium)),
                    const SizedBox(width: AppSpacing.sm),
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: AppRatingBadge(rating: business.rating, reviewCount: business.reviewCount),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                if (business.isSponsored) ...[
                  const SizedBox(height: AppSpacing.sm),
                  const AppTag(
                    label: 'SPOTLIGHT',
                    color: AppColors.gold,
                    textColor: AppColors.navy,
                    compact: true,
                  ),
                ],

                const SizedBox(height: AppSpacing.md),

                // ── Address ──────────────────────────────────────────────
                _InfoRow(icon: Icons.location_on_outlined, text: business.address.isEmpty ? 'Las Vegas, NV' : business.address),
                if (business.serviceArea.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  _InfoRow(icon: Icons.map_outlined, text: business.serviceArea),
                ],
                if (business.hours.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  _InfoRow(icon: Icons.schedule_outlined, text: business.hours),
                ],
                const SizedBox(height: AppSpacing.sm),

                // ── Map with distance ────────────────────────────────────
                if (business.latitude != null && business.longitude != null)
                  MapPreviewCard(
                    latitude: business.latitude!,
                    longitude: business.longitude!,
                    label: BusinessScreen.distanceLabel(business),
                    address: business.address,
                    height: 132,
                    onOpen: () => _openMaps(context),
                  ),

                if (isOwner) ...[
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: 'Edit your listing',
                    icon: Icons.edit_outlined,
                    variant: AppButtonVariant.secondary,
                    onPressed: () => Navigator.of(context).pushNamed(AppRoutes.businessEditor),
                  ),
                ],

                // ── About ────────────────────────────────────────────────
                if (business.description.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  _SectionTitle('About'),
                  const SizedBox(height: AppSpacing.sm),
                  Text(business.description, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
                ],

                // ── Services ─────────────────────────────────────────────
                if (business.services.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  _SectionTitle('Services'),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final service in business.services)
                        AppTag(label: service, icon: Icons.check_circle_outline_rounded, iconColor: AppColors.purple, bordered: true),
                    ],
                  ),
                ],

                // ── Gallery ──────────────────────────────────────────────
                if (business.gallery.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  _SectionTitle('Photos'),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: business.gallery.length,
                      separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                      itemBuilder: (context, index) => ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: AppNetworkImage(url: business.gallery[index], width: 168, height: 120),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // ── Coupons ────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: AsyncValueView<List<Coupon>>(
            value: coupons,
            onRetry: () => ref.invalidate(couponsForBusinessProvider(business.id)),
            loading: const SizedBox.shrink(),
            builder: (context, list) {
              if (list.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: EdgeInsets.only(top: AppSpacing.xl, left: context.pagePadding, right: context.pagePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle('Coupons'),
                    const SizedBox(height: AppSpacing.sm),
                    const CouponAllowanceBar(),
                    const SizedBox(height: AppSpacing.sm),
                    for (final coupon in list)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _CouponCard(coupon: coupon, onRedeem: () => _redeem(context, ref, coupon)),
                      ),
                  ],
                ),
              );
            },
          ),
        ),

        // ── Reviews ────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(context.pagePadding, AppSpacing.xl, context.pagePadding, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(child: _SectionTitle('Reviews')),
                    TextButton.icon(
                      onPressed: () {
                        if (user == null) {
                          Navigator.of(context).pushNamed(AppRoutes.login);
                          return;
                        }
                        Navigator.of(context).pushNamed(AppRoutes.writeReview, arguments: business.id);
                      },
                      icon: const Icon(Icons.rate_review_outlined, size: 18),
                      label: const Text('Write a review'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                AsyncValueView<List<Review>>(
                  value: reviews,
                  onRetry: () => ref.invalidate(reviewsProvider(business.id)),
                  loading: const AppLoading(),
                  builder: (context, list) {
                    if (list.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.lg)),
                        child: Text(
                          user == null
                              ? 'No reviews yet. Sign in to be the first to review.'
                              : 'No reviews yet — be the first to share your experience.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    }
                    return Column(
                      children: [
                        for (final review in list)
                          Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: _ReviewCard(review: review),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // ── Contact ────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(context.pagePadding, AppSpacing.xl, context.pagePadding, AppSpacing.xxxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (business.phone.isNotEmpty || business.website.isNotEmpty) ...[
                  const _SectionTitle('Contact'),
                  const SizedBox(height: AppSpacing.sm),
                  if (business.phone.isNotEmpty)
                    _ContactTile(
                      icon: Icons.phone_outlined,
                      title: 'Phone',
                      value: business.phone,
                      onTap: () => _call(context),
                    ),
                  if (business.phone.isNotEmpty && business.website.isNotEmpty)
                    const SizedBox(height: AppSpacing.sm),
                  if (business.website.isNotEmpty)
                    _ContactTile(
                      icon: Icons.language_outlined,
                      title: 'Website',
                      value: _displayWebsite,
                      onTap: () => _openWebsite(context),
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  String get _displayWebsite => business.website
      .replaceFirst(RegExp(r'^https?://'), '')
      .replaceFirst(RegExp(r'/$'), '');

  Future<void> _openMaps(BuildContext context) async {
    final launched = await MapLauncher.openCoordinates(
      latitude: business.latitude!,
      longitude: business.longitude!,
    );
    if (!launched && context.mounted) showMapUnavailable(context);
  }

  Future<void> _call(BuildContext context) async {
    final number = business.phone.replaceAll(RegExp(r'[^0-9+]'), '');
    await _openExternal(context, Uri(scheme: 'tel', path: number));
  }

  Future<void> _openWebsite(BuildContext context) async {
    final raw = business.website.trim();
    final uri = Uri.tryParse(
      raw.startsWith('http') ? raw : 'https://$raw',
    );
    if (uri == null) return;
    await _openExternal(context, uri);
  }

  Future<void> _openExternal(BuildContext context, Uri uri) async {
    final launched = await ExternalLink.open(uri);
    if (!launched && context.mounted) {
      context.showSnack(
        'Could not open this link on this device.',
        isError: true,
      );
    }
  }

  Future<void> _redeem(BuildContext context, WidgetRef ref, Coupon coupon) async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      await showGuestCouponSheet(context);
      return;
    }

    final quota = await ref.read(couponQuotaProvider.future);
    if (!quota.canRedeem) {
      if (context.mounted) await showCouponUpgradeSheet(context);
      return;
    }

    final result = await ref.read(redeemCouponProvider)(coupon.id);
    if (!context.mounted) return;

    await result.when(
      success: (redeemed) async {
        await ref.read(couponQuotaProvider.notifier).recordRedemption();
        if (!context.mounted) return;
        final remaining =
            ref.read(couponQuotaProvider).valueOrNull?.remaining ?? 0;
        ref.invalidate(couponsForBusinessProvider(business.id));
        await _showCodeDialog(context, redeemed, remaining);
        // The client asked for the upgrade prompt once the 10 free coupons
        // are gone, so show it as soon as the last code dialog is dismissed.
        if (remaining == 0 && context.mounted) {
          await showCouponUpgradeSheet(context);
        }
      },
      failure: (failure) async =>
          context.showSnack(failure.message, isError: true),
    );
  }

  Future<void> _showCodeDialog(
    BuildContext context,
    Coupon coupon,
    int remaining,
  ) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(coupon.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
              decoration: BoxDecoration(color: AppColors.purple.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(AppRadius.md)),
              child: Text(
                coupon.code,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 2, color: AppColors.purple),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Show this code to the business to redeem. '
              'Your account has $remaining free coupons left.',
              textAlign: TextAlign.center,
              style: Theme.of(dialogContext).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Done'))],
      ),
    );
  }
}

// ── Small building blocks ─────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Text(title, style: Theme.of(context).textTheme.headlineMedium);
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.purple),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
      ],
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          AppIconTile(icon: icon, size: 38),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(
              Icons.open_in_new_rounded,
              size: 18,
              color: AppColors.purple,
            ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(imageUrl: review.userAvatarUrl, initials: review.userName.isEmpty ? '?' : review.userName[0].toUpperCase(), size: 34),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.userName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    Text(AppFormatters.relative(review.createdAt), style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              AppRatingStars(rating: review.rating, size: 14),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(review.comment, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  const _CouponCard({required this.coupon, required this.onRedeem});

  final Coupon coupon;
  final VoidCallback onRedeem;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(gradient: AppColors.brandGradient, borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coupon.title,
                  style: const TextStyle(color: AppColors.white, fontSize: 15, fontWeight: FontWeight.w700),
                ),
                if (coupon.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(coupon.description, style: TextStyle(color: AppColors.white.withValues(alpha: 0.85), fontSize: 12)),
                ],
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${AppFormatters.compact(coupon.redemptionCount)} redeemed',
                  style: TextStyle(color: AppColors.white.withValues(alpha: 0.75), fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppButton(label: 'Redeem', size: AppButtonSize.small, variant: AppButtonVariant.outline, isFullWidth: false, onPressed: onRedeem, textColor: AppColors.white,),
        ],
      ),
    );
  }
}
