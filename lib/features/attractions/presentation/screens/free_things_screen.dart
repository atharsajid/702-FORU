import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../domain/entities/attraction.dart';
import '../providers/attraction_providers.dart';

/// "Free Things To Do" — one listing card per attraction.
///
/// Replaces the generic category page for this category: each card opens that
/// attraction's own detail page, rather than a single page listing everything.
class FreeThingsScreen extends ConsumerWidget {
  const FreeThingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attractions = ref.watch(attractionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Free Things To Do')),
      body: RefreshIndicator(
        color: AppColors.purple,
        onRefresh: () async {
          ref.invalidate(attractionsProvider);
          await ref.read(attractionsProvider.future);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.lg),
            ),
            const SliverToBoxAdapter(child: _FreeThingsHero()),
            SliverToBoxAdapter(
              child: AsyncValueView<List<Attraction>>(
                value: attractions,
                onRetry: () => ref.invalidate(attractionsProvider),
                builder: (context, list) {
                  if (list.isEmpty) {
                    return const AppEmptyState(
                      title: 'No free spots listed right now',
                      message: 'We check every listing before it goes live.',
                      icon: Icons.attractions_outlined,
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          context.pagePadding,
                          AppSpacing.xxl,
                          context.pagePadding,
                          AppSpacing.md,
                        ),
                        child: Text(
                          '${list.length} free spots, verified this month',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      for (final attraction in list)
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            context.pagePadding,
                            0,
                            context.pagePadding,
                            AppSpacing.md,
                          ),
                          child: AttractionCard(
                            attraction: attraction,
                            onTap: () => Navigator.of(context).pushNamed(
                              AppRoutes.attraction,
                              arguments: attraction.id,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.xxxl),
            ),
          ],
        ),
      ),
    );
  }
}

class _FreeThingsHero extends StatelessWidget {
  const _FreeThingsHero();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: AppColors.navyGradient,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: const Text(
                '100% FREE',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Free things to do in Vegas',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Gardens, landmarks and monthly events — hand-checked, with no '
              'tickets and no cover charge.',
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.82),
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One photo-led card per attraction.
class AttractionCard extends StatelessWidget {
  const AttractionCard({
    super.key,
    required this.attraction,
    required this.onTap,
  });

  final Attraction attraction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: AppNetworkImage(
                  url: attraction.imageUrl,
                  width: double.infinity,
                  placeholderIcon: Icons.attractions_outlined,
                ),
              ),
              Positioned(
                top: AppSpacing.md,
                left: AppSpacing.md,
                child: AppTag(
                  label: attraction.costLabel.toUpperCase(),
                  color: AppColors.success,
                  textColor: AppColors.white,
                  compact: true,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attraction.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  attraction.tagline,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppColors.purple,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        attraction.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
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
