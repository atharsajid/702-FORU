import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../../catalog/domain/entities/category.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../../domain/entities/offer.dart';
import '../providers/offers_providers.dart';

/// "Exclusive 702FORU Offer → Explore Now" destination.
class OffersScreen extends ConsumerWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offers = ref.watch(offersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Exclusive Offers')),
      body: RefreshIndicator(
        color: AppColors.purple,
        onRefresh: () async => ref.invalidate(offersProvider),
        child: AsyncValueView<List<Offer>>(
          value: offers,
          onRetry: () => ref.invalidate(offersProvider),
          builder: (context, list) {
            if (list.isEmpty) {
              return const AppEmptyState(
                title: 'No live offers right now',
                message: 'New exclusive deals drop every week.',
                icon: Icons.local_offer_outlined,
              );
            }

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.pagePadding,
                  ),
                  sliver: SliverList.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) => _OfferCard(
                      offer: list[index],
                      onTap: () => _open(context, ref, list[index]),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xxxl),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    Offer offer,
  ) async {
    if (offer.businessId != null) {
      Navigator.of(context).pushNamed(
        AppRoutes.business,
        arguments: offer.businessId,
      );
      return;
    }

    if (offer.categoryId != null) {
      final categories = await ref.read(categoriesProvider.future);
      final match = categories.where((c) => c.id == offer.categoryId);
      if (!context.mounted) return;
      if (match.isNotEmpty) {
        final Category category = match.first;
        Navigator.of(context).pushNamed(AppRoutes.category, arguments: category);
        return;
      }
    }

    if (context.mounted) {
      context.showSnack('This offer is available in the app soon.');
    }
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.offer, required this.onTap});

  final Offer offer;
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
                  url: offer.imageUrl,
                  width: double.infinity,
                  placeholderIcon: Icons.local_offer_outlined,
                ),
              ),
              const Positioned(
                top: AppSpacing.md,
                left: AppSpacing.md,
                child: AppTag(
                  label: 'EXCLUSIVE',
                  color: AppColors.purple,
                  textColor: AppColors.white,
                  compact: true,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.purple,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  offer.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Text(
                      offer.ctaLabel,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.purple,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    const Icon(
                      Icons.arrow_forward,
                      size: 16,
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
