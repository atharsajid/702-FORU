import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import 'app_button.dart';
import 'app_network_image.dart';

/// Big tappable brand card at the top of Home (logo, or a video later).
/// Tapping it opens "About 702FORU".
class BrandBanner extends StatelessWidget {
  const BrandBanner({
    super.key,
    required this.onTap,
    this.imageAsset = 'assets/logo.png',
    this.height = 200,
  });

  final VoidCallback onTap;
  final String imageAsset;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Material(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(imageAsset, fit: BoxFit.cover),
                // Subtle "watch animation" affordance, matching iOS chrome.
                Positioned(
                  left: AppSpacing.md,
                  top: AppSpacing.md,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.play_circle_outline,
                          size: 13,
                          color: AppColors.white,
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Text(
                          'Watch Animation',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "Exclusive 702FORU Offer" banner with the Explore-Now CTA.
class OfferBanner extends StatelessWidget {
  const OfferBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.onPressed,
    this.ctaLabel = 'Explore Now',
  });

  final String title;
  final String subtitle;
  final String imageUrl;
  final VoidCallback onPressed;
  final String ctaLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.brandGradient,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: AppColors.purple.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: ctaLabel,
                    size: AppButtonSize.small,
                    variant: AppButtonVariant.outline,
                    isFullWidth: false,
                    onPressed: onPressed,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: AppNetworkImage(
                url: imageUrl,
                width: 96,
                height: 96,
                placeholderIcon: Icons.local_offer_outlined,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Spotlight Your Business" card shown on every category page.
class SpotlightBanner extends StatelessWidget {
  const SpotlightBanner({
    super.key,
    required this.onTap,
    this.title = 'Spotlight Your Business',
    this.subtitle = 'Click here to learn more',
  });

  final VoidCallback onTap;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: AppColors.white.withValues(alpha: 0.85),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: AppColors.white,
                      size: 18,
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
