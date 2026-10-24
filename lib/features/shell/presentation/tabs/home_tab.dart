import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/router/category_navigation.dart';
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
import '../../../catalog/domain/entities/business.dart';
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

              // 702FORU logo (kept, now fitted) → About 702FORU
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                  child: BrandBanner(
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.about),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

              // RSS / news ticker (Home only)
              const SliverToBoxAdapter(child: RssMarquee(items: _rssItems)),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

              // Featured in Vegas → the featured business's detail page
              SliverToBoxAdapter(
                child: Consumer(
                  builder: (context, ref, child) {
                    final featured = ref.watch(featuredSpotlightProvider);

                    return featured.maybeWhen(
                      data: (spotlight) {
                        if (spotlight == null) return const SizedBox.shrink();
                        final businessId = spotlight.businessId;

                        return FeaturedInVegasBanner(
                          title: spotlight.title,
                          subtitle: spotlight.subtitle,
                          imageUrl: spotlight.imageUrl,
                          categoryLabel: spotlight.categoryLabel,
                          rating: spotlight.rating,
                          reviewCount: spotlight.reviewCount,
                          hasVideo: spotlight.hasVideo,
                          ctaLabel: spotlight.ctaLabel,
                          onPressed: () {
                            if (businessId != null &&
                                businessId.isNotEmpty) {
                              Navigator.of(context).pushNamed(
                                AppRoutes.business,
                                arguments: businessId,
                              );
                            } else {
                              Navigator.of(context)
                                  .pushNamed(AppRoutes.offers);
                            }
                          },
                        );
                      },
                      orElse: () => const _BannerSkeleton(),
                    );
                  },
                ),
              ),

              SliverToBoxAdapter(
                child: AppSectionHeader(
                  title: 'Explore Categories',
                  subtitle: 'Tap a sphere to discover local businesses',
                  actionLabel: 'See all',
                  onAction: () => Navigator.of(context)
                      .pushNamed(AppRoutes.allCategories),
                ),
              ),

              SliverToBoxAdapter(
                child: Consumer(
                  builder: (context, ref, child) {
                    final categories = ref.watch(categoriesProvider);

                    return AsyncValueView<List<Category>>(
                      value: categories,
                      onRetry: () => ref.invalidate(categoriesProvider),
                      builder: (context, list) => CategorySphereGrid(
                        categories: list,
                        onCategoryTap: (category) =>
                            openCategory(context, category),
                      ),
                    );
                  },
                ),
              ),

              SliverToBoxAdapter(
                child: AppSectionHeader(
                  title: 'Spotlight Businesses',
                  subtitle: 'Featured partners this week',
                  actionLabel: 'See All',
                  onAction: () => Navigator.of(context)
                      .pushNamed(AppRoutes.spotlightBusinesses),
                ),
              ),

              SliverToBoxAdapter(
                child: Consumer(
                  builder: (context, ref, child) {
                    final sponsored = ref.watch(sponsoredBusinessesProvider);

                    return AsyncValueView(
                      value: sponsored,
                      onRetry: () => ref.invalidate(sponsoredBusinessesProvider),
                      builder: (context, list) {
                        if (list.isEmpty) {
                          return const AppEmptyState(
                            title: 'No spotlight businesses yet',
                            message:
                                'Check back soon — we add new partners weekly.',
                            icon: Icons.storefront_outlined,
                          );
                        }
                        return _SpotlightCarousel(businesses: list);
                      },
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

/// Swipeable, page-snapped row of spotlight partners with page dots.
class _SpotlightCarousel extends StatefulWidget {
  const _SpotlightCarousel({required this.businesses});

  final List<Business> businesses;

  @override
  State<_SpotlightCarousel> createState() => _SpotlightCarouselState();
}

class _SpotlightCarouselState extends State<_SpotlightCarousel> {
  static const double _cardHeight = 318;

  final PageController _controller = PageController(viewportFraction: 0.86);
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _open(Business business) {
    Navigator.of(context).pushNamed(
      AppRoutes.business,
      arguments: business.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: _cardHeight,
          child: Padding(
            padding: EdgeInsets.only(left: context.pagePadding),
            child: PageView.builder(
              controller: _controller,
              padEnds: false,
              physics: const BouncingScrollPhysics(),
              itemCount: widget.businesses.length,
              onPageChanged: (index) => setState(() => _page = index),
              itemBuilder: (context, index) {
                final business = widget.businesses[index];
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: SpotlightBusinessCard(
                    business: business,
                    onTap: () => _open(business),
                  ),
                );
              },
            ),
          ),
        ),
        if (widget.businesses.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var index = 0; index < widget.businesses.length; index++)
                  AnimatedContainer(
                    duration: AppDurations.fast,
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 6,
                    width: index == _page ? 18 : 6,
                    decoration: BoxDecoration(
                      color: index == _page
                          ? AppColors.purple
                          : AppColors.greyLight,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
              ],
            ),
          ),
      ],
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
                  user == null
                      ? 'Welcome to 702FORU'
                      : 'Hi, ${user.fullName.split(' ').first}',
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
              label: 'Sign In',
              size: AppButtonSize.small,
              isFullWidth: false,
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.login),
            )
          else
            GestureDetector(
              onTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.profile),
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

/// Placeholder shown while the featured banner loads.
class _BannerSkeleton extends StatelessWidget {
  const _BannerSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
      child: Container(
        height: 244,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
    );
  }
}
