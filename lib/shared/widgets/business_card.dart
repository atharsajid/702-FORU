import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../features/catalog/domain/entities/business.dart';
import 'app_card.dart';
import 'app_network_image.dart';
import 'app_rating.dart';

/// Vertical card used in the 2-column category / search grid.
class BusinessCard extends StatelessWidget {
  const BusinessCard({super.key, required this.business, required this.onTap});

  final Business business;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover image with a Sponsored pill when applicable.
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 10,
                child: AppNetworkImage(
                  url: business.coverUrl ?? business.logoUrl,
                  width: double.infinity,
                  placeholderIcon: Icons.storefront_outlined,
                ),
              ),
              if (business.isSponsored)
                const Positioned(
                  top: AppSpacing.sm,
                  left: AppSpacing.sm,
                  child: AppTag(
                    label: 'SPOTLIGHT',
                    color: AppColors.gold,
                    textColor: AppColors.navy,
                    compact: true,
                  ),
                ),
            ],
          ),
          // Fills whatever height the grid gives the card, so a one-line name
          // and a two-line name both look balanced instead of leaving a gap.
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    business.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  AppRatingBadge(
                    rating: business.rating,
                    reviewCount: business.reviewCount,
                    compact: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Large swipeable card used in the Home "Spotlight Businesses" carousel.
///
/// Unlike [BusinessCard] it has room for the address and an explicit
/// "View details" affordance, and the image flexes so the card keeps its
/// proportions on tablets.
class SpotlightBusinessCard extends StatelessWidget {
  const SpotlightBusinessCard({
    super.key,
    required this.business,
    required this.onTap,
  });

  final Business business;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                AppNetworkImage(
                  url: business.coverUrl ?? business.logoUrl,
                  width: double.infinity,
                  height: double.infinity,
                  placeholderIcon: Icons.storefront_outlined,
                ),
                const Positioned(
                  top: AppSpacing.md,
                  left: AppSpacing.md,
                  child: AppTag(
                    label: 'SPOTLIGHT',
                    color: AppColors.gold,
                    textColor: AppColors.navy,
                    compact: true,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  business.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        business.address.isEmpty ? 'Las Vegas, NV' : business.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    AppRatingBadge(
                      rating: business.rating,
                      reviewCount: business.reviewCount,
                      compact: true,
                    ),
                    const Spacer(),
                    const Text(
                      'View details',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.purple,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: AppColors.purple,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal row used in search results and favourites lists.
class BusinessListTile extends StatelessWidget {
  const BusinessListTile({
    super.key,
    required this.business,
    required this.onTap,
    this.trailing,
  });

  final Business business;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: AppNetworkImage(
              url: business.coverUrl ?? business.logoUrl,
              width: 64,
              height: 64,
              placeholderIcon: Icons.storefront_outlined,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  business.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  business.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                AppRatingBadge(
                  rating: business.rating,
                  reviewCount: business.reviewCount,
                  compact: true,
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.sm),
            trailing!,
          ] else
            const Icon(
              Icons.chevron_right,
              color: AppColors.grey,
              size: 20,
            ),
        ],
      ),
    );
  }
}
