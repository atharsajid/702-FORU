import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/utils/formatters.dart';
import 'app_button.dart';
import 'app_network_image.dart';

/// Brand card: the animated 702FORU logo on a navy surface.
///
/// The animation is a 16:9 asset, so the default card keeps that aspect ratio
/// and fills it exactly – no cropping, no distortion. Pass [compact] for the
/// slim brand strip used on secondary screens: the card then takes [height]
/// and letterboxes the logo instead of growing to a full-width hero.
///
/// [onTap] is optional: the logo is decoration on auth and info screens, and
/// only becomes a button where it leads somewhere (Home, category pages).
class BrandBanner extends StatelessWidget {
  const BrandBanner({super.key, this.onTap, this.imageAsset = 'assets/animated_logo.gif'});

  final VoidCallback? onTap;
  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    final banner = Material(
      color: AppColors.navy,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: const BoxDecoration(gradient: AppColors.navyGradient),
          child: Image.asset(imageAsset, fit: BoxFit.fill, filterQuality: FilterQuality.medium, gaplessPlayback: true),
        ),
      ),
    );

    return AspectRatio(aspectRatio: 16 / 9, child: banner);
  }
}

/// "Featured in Vegas" – the editorial hero under the logo.
///
/// Shows the featured business's own photo with a short pitch, its rating and
/// category, and a play badge when the business has a promo video. Tapping
/// anywhere (or the CTA) opens that business's detail page.
class FeaturedInVegasBanner extends StatelessWidget {
  const FeaturedInVegasBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.onPressed,
    this.categoryLabel,
    this.rating,
    this.reviewCount = 0,
    this.hasVideo = false,
    this.ctaLabel = 'View details',
    this.height = 244,
  });

  final String title;
  final String subtitle;
  final String imageUrl;
  final VoidCallback onPressed;
  final String? categoryLabel;
  final double? rating;
  final int reviewCount;
  final bool hasVideo;
  final String ctaLabel;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: SizedBox(
        height: height,
        child: Material(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AppNetworkImage(url: imageUrl, width: double.infinity, height: double.infinity, placeholderIcon: Icons.photo_camera_back_outlined),
                // Scrim: keeps the copy legible over any photo.
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x330A0A3C), Color(0x990A0A3C), AppColors.navy],
                      stops: [0, 0.55, 1],
                    ),
                  ),
                ),
                Positioned(
                  top: AppSpacing.md,
                  left: AppSpacing.md,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 5),
                    decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(AppRadius.pill)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_fire_department_rounded, size: 13, color: AppColors.navy),
                        SizedBox(width: AppSpacing.xs),
                        Text(
                          'FEATURED IN VEGAS',
                          style: TextStyle(color: AppColors.navy, fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),
                ),
                if (hasVideo)
                  Positioned(
                    top: AppSpacing.md,
                    right: AppSpacing.md,
                    child: Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(color: AppColors.white.withValues(alpha: 0.92), shape: BoxShape.circle),
                      child: const Icon(Icons.play_arrow_rounded, color: AppColors.navy, size: 22),
                    ),
                  ),
                Positioned(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  bottom: AppSpacing.lg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.white, fontSize: 21, fontWeight: FontWeight.w800, height: 1.15),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.white.withValues(alpha: 0.82), fontSize: 12.5, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      // Meta and CTA sit on separate rows so a long category
                      // name (or a large text scale) can never overflow.
                      Row(
                        children: [
                          if (rating != null) ...[
                            const Icon(Icons.star_rounded, size: 15, color: AppColors.gold),
                            const SizedBox(width: 3),
                            Text(
                              AppFormatters.rating(rating!),
                              style: const TextStyle(color: AppColors.white, fontSize: 12.5, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '(${AppFormatters.compact(reviewCount)})',
                              style: TextStyle(color: AppColors.white.withValues(alpha: 0.7), fontSize: 11.5),
                            ),
                            if (categoryLabel != null) ...[
                              const SizedBox(width: AppSpacing.sm),
                              Container(
                                height: 3,
                                width: 3,
                                decoration: BoxDecoration(color: AppColors.white.withValues(alpha: 0.5), shape: BoxShape.circle),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                            ],
                          ],
                          if (categoryLabel != null)
                            Flexible(
                              child: Text(
                                categoryLabel!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: AppColors.white.withValues(alpha: 0.85), fontSize: 11.5, fontWeight: FontWeight.w600),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppRadius.pill)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              ctaLabel,
                              style: const TextStyle(color: AppColors.navy, fontSize: 11.5, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(width: 2),
                            const Icon(Icons.arrow_forward_rounded, size: 13, color: AppColors.navy),
                          ],
                        ),
                      ),
                    ],
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
          boxShadow: [BoxShadow(color: AppColors.purple.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 6))],
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
                    style: const TextStyle(color: AppColors.white, fontSize: 12.5, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    title,
                    style: const TextStyle(color: AppColors.white, fontSize: 19, fontWeight: FontWeight.w800, height: 1.2),
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
                    textColor: AppColors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: AppNetworkImage(url: imageUrl, width: 96, height: 96, placeholderIcon: Icons.local_offer_outlined),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Spotlight Your Business" card shown on every category page.
class SpotlightBanner extends StatelessWidget {
  const SpotlightBanner({super.key, required this.onTap, this.title = 'Spotlight Your Business', this.subtitle = 'Click here to learn more'});

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
          decoration: BoxDecoration(gradient: AppColors.brandGradient, borderRadius: BorderRadius.circular(AppRadius.lg)),
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
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.white),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(subtitle, style: TextStyle(color: AppColors.white.withValues(alpha: 0.85), fontSize: 13)),
                      ],
                    ),
                  ),
                  Container(
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(color: AppColors.white.withValues(alpha: 0.18), shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_forward, color: AppColors.white, size: 18),
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
