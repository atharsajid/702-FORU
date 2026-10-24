import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/map_launcher.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../../../shared/widgets/map_preview_card.dart';
import '../../domain/entities/attraction.dart';
import '../providers/attraction_providers.dart';

/// A single free attraction: photo, description, location and a map handoff.
///
/// Every attraction gets its own page — free spots are never combined into one
/// shared detail page.
class AttractionDetailScreen extends ConsumerWidget {
  const AttractionDetailScreen({super.key, required this.attractionId});

  final String attractionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attraction = ref.watch(attractionByIdProvider(attractionId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AsyncValueView<Attraction>(
        value: attraction,
        onRetry: () => ref.invalidate(attractionByIdProvider(attractionId)),
        builder: (context, data) => _AttractionContent(attraction: data),
      ),
    );
  }
}

class _AttractionContent extends StatelessWidget {
  const _AttractionContent({required this.attraction});

  final Attraction attraction;

  Future<void> _openMaps(BuildContext context) async {
    final launched = await MapLauncher.openCoordinates(
      latitude: attraction.latitude,
      longitude: attraction.longitude,
    );
    if (!launched && context.mounted) showMapUnavailable(context);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 250,
          pinned: true,
          title: Text(
            attraction.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                AppNetworkImage(
                  url: attraction.imageUrl,
                  placeholderIcon: Icons.attractions_outlined,
                ),
                // Keeps the app-bar controls legible over bright photos.
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x80000000), Color(0x00000000)],
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
            padding: EdgeInsets.fromLTRB(
              context.pagePadding,
              AppSpacing.lg,
              context.pagePadding,
              AppSpacing.xxxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        attraction.name,
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: AppTag(
                        label: attraction.costLabel.toUpperCase(),
                        color: AppColors.success.withValues(alpha: 0.14),
                        textColor: AppColors.success,
                        icon: Icons.sell_outlined,
                        iconColor: AppColors.success,
                        compact: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  attraction.tagline,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                ),

                const SizedBox(height: AppSpacing.xl),
                const _SectionTitle('About'),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  attraction.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.6,
                      ),
                ),

                if (attraction.goodToKnow.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  const _SectionTitle('Good to know'),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final tip in attraction.goodToKnow)
                        AppTag(
                          label: tip,
                          icon: Icons.check_circle_outline_rounded,
                          iconColor: AppColors.purple,
                          bordered: true,
                        ),
                    ],
                  ),
                ],

                const SizedBox(height: AppSpacing.xl),
                const _SectionTitle('Location'),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: AppColors.purple,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        attraction.address,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                MapPreviewCard(
                  latitude: attraction.latitude,
                  longitude: attraction.longitude,
                  label: attraction.name,
                  address: attraction.address,
                  onOpen: () => _openMaps(context),
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: 'Open in Maps',
                  icon: Icons.map_outlined,
                  onPressed: () => _openMaps(context),
                ),

                if (attraction.gallery.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  const _SectionTitle('Photos'),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    height: 130,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: attraction.gallery.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: AppSpacing.sm),
                      itemBuilder: (context, index) => ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: AppNetworkImage(
                          url: attraction.gallery[index],
                          width: 180,
                          height: 130,
                          placeholderIcon: Icons.photo_outlined,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.xl),
                const _SectionTitle('Plan your visit'),
                const SizedBox(height: AppSpacing.sm),
                if (attraction.hoursLabel.isNotEmpty)
                  _InfoTile(
                    icon: Icons.schedule_outlined,
                    title: 'Hours',
                    value: attraction.hoursLabel,
                  ),
                const SizedBox(height: AppSpacing.sm),
                _InfoTile(
                  icon: Icons.sell_outlined,
                  title: 'Cost',
                  value: attraction.costLabel,
                ),
                if (attraction.website.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _InfoTile(
                    icon: Icons.language_outlined,
                    title: 'Website',
                    value: attraction.website,
                  ),
                ],

                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    const Icon(
                      Icons.verified_outlined,
                      size: 15,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        'Verified ${AppFormatters.date(attraction.lastVerifiedAt)} · '
                        'Hours can change, so confirm before you go.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) =>
      Text(title, style: Theme.of(context).textTheme.headlineMedium);
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          AppIconTile(icon: icon, size: 38),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
