import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../../../shared/widgets/business_card.dart';
import '../../../../shared/widgets/category_sphere.dart';
import '../../../../shared/widgets/notification_bell.dart';
import '../../../../shared/widgets/promo_banners.dart';
import '../../../../shared/widgets/rss_marquee.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../catalog/domain/entities/category.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../../../offers/presentation/providers/offers_providers.dart';

/// Primary landing screen.
class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  /// Static headline items – replaced by a real RSS feed later.
  static const List<String> _rssItems = [
    'Las Vegas traffic flowing smoothly on I-15',
    'Sunny all week — highs around 78°F',
    'New businesses added to 702FORU today',
    'Free Things To Do: updated weekly',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final heroOffer = ref.watch(heroOfferProvider);
    final sponsored = ref.watch(sponsoredBusinessesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.purple,
        onRefresh: () async {
          ref.invalidate(categoriesProvider);
          ref.invalidate(offersProvider);
          ref.invalidate(sponsoredBusinessesProvider);
          await Future.wait([
            ref.read(categoriesProvider.future),
            ref.read(offersProvider.future),
          ]);
        },
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
              const SliverToBoxAdapter(child: _HomeHeader()),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
              const SliverToBoxAdapter(child: _HomeSearchBar()),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

              // Brand banner → About 702FORU
              SliverToBoxAdapter(
                child: BrandBanner(
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.about),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

              // RSS / news ticker (Home only)
              const SliverToBoxAdapter(
                child: RssMarquee(items: _rssItems),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

              // Exclusive offer banner → Explore Now
              SliverToBoxAdapter(
                child: heroOffer.maybeWhen(
                  data: (offer) => offer == null
                      ? const SizedBox.shrink()
                      : OfferBanner(
                          title: offer.title,
                          subtitle: offer.subtitle,
                          imageUrl: offer.imageUrl,
                          ctaLabel: offer.ctaLabel,
                          onPressed: () => Navigator.of(context)
                              .pushNamed(AppRoutes.offers),
                        ),
                  orElse: () => const _BannerSkeleton(),
                ),
              ),

              SliverToBoxAdapter(
                child: AppSectionHeader(
                  title: 'Explore Categories',
                  subtitle: 'Tap a sphere to discover local businesses',
                  actionLabel: 'See all',
                  onAction: () =>
                      Navigator.of(context).pushNamed(AppRoutes.allCategories),
                ),
              ),

              SliverToBoxAdapter(
                child: AsyncValueView<List<Category>>(
                  value: categories,
                  onRetry: () => ref.invalidate(categoriesProvider),
                  builder: (context, list) => CategorySphereGrid(
                    categories: list,
                    onCategoryTap: (category) => Navigator.of(context)
                        .pushNamed(AppRoutes.category, arguments: category),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: AppSectionHeader(
                  title: 'Spotlight Businesses',
                  subtitle: 'Featured partners this week',
                  actionLabel: 'Browse',
                  onAction: () =>
                      Navigator.of(context).pushNamed(AppRoutes.search),
                ),
              ),

              SliverToBoxAdapter(
                child: AsyncValueView(
                  value: sponsored,
                  onRetry: () => ref.invalidate(sponsoredBusinessesProvider),
                  builder: (context, list) {
                    if (list.isEmpty) {
                      return const AppEmptyState(
                        title: 'No spotlight businesses yet',
                        message: 'Check back soon — we add new partners weekly.',
                        icon: Icons.storefront_outlined,
                      );
                    }
                    final cardWidth = context.responsive(
                      mobile: 190.0,
                      tablet: 220.0,
                    );
                    return SizedBox(
                      height: 214,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: context.pagePadding,
                        ),
                        itemCount: list.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: AppSpacing.md),
                        itemBuilder: (context, index) {
                          final business = list[index];
                          return SizedBox(
                            width: cardWidth,
                            child: BusinessCard(
                              business: business,
                              onTap: () => Navigator.of(context).pushNamed(
                                AppRoutes.business,
                                arguments: business.id,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Greeting + authentication shortcut + notification bell.
class _HomeHeader extends ConsumerWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user == null ? 'Welcome to 702FORU' : 'Hi, ${user.fullName.split(' ').first}',
                  style: text.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Your Vegas, ready.',
                  style: text.headlineMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (user == null)
            AppButton(
              label: 'Sign In / Sign Up',
              size: AppButtonSize.small,
              isFullWidth: false,
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.login),
            )
          else
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.profile),
              child: AppAvatar(
                imageUrl: user.avatarUrl,
                initials: user.initials,
                size: 38,
              ),
            ),
          const SizedBox(width: AppSpacing.xs),
          NotificationBell(
            onTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.notifications),
          ),
        ],
      ),
    );
  }
}

/// Home search entry point – opens the dedicated search screen.
class _HomeSearchBar extends StatelessWidget {
  const _HomeSearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.search),
        child: AbsorbPointer(
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                const Icon(Icons.search, size: 20, color: AppColors.grey),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Search businesses, services, events…',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Placeholder shown while the offer banner loads.
class _BannerSkeleton extends StatelessWidget {
  const _BannerSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
      child: Container(
        height: 128,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
    );
  }
}
