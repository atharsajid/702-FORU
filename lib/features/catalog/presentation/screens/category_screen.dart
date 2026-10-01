import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/business_card.dart';
import '../../../../shared/widgets/promo_banners.dart';
import '../../domain/entities/business.dart';
import '../../domain/entities/category.dart';
import '../providers/catalog_providers.dart';

/// Every category shares this layout: logo header, spotlight ad, business list.
class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key, required this.category});

  final Category category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businesses = ref.watch(businessesByCategoryProvider(category.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(category.name)),
      body: RefreshIndicator(
        color: AppColors.purple,
        onRefresh: () async {
          ref.invalidate(businessesByCategoryProvider(category.id));
          await ref.read(businessesByCategoryProvider(category.id).future);
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

            // 702FORU logo keeps the brand present on every category page.
            SliverToBoxAdapter(
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  
                  child: Image.asset('assets/logo.png', height: 100)),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

            if (category.description.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: context.pagePadding),
                  child: Text(
                    category.description,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

            // Running "Spotlight your business" ad – same on every category.
            SliverToBoxAdapter(
              child: SpotlightBanner(
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.spotlightInfo),
              ),
            ),

            SliverToBoxAdapter(
              child: AppSectionHeader(
                title: 'Businesses in ${category.name}',
                subtitle: category.description,
              ),
            ),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
              sliver: SliverToBoxAdapter(
                child: AsyncValueView<List<Business>>(
                  value: businesses,
                  onRetry: () => ref
                      .invalidate(businessesByCategoryProvider(category.id)),
                  builder: (context, list) {
                    if (list.isEmpty) {
                      return AppEmptyState(
                        title: 'No businesses yet',
                        message:
                            'Be the first to list in ${category.name}. Providers can join in a few minutes.',
                        icon: Icons.storefront_outlined,
                        actionLabel: 'List your business',
                        onAction: () => Navigator.of(context)
                            .pushNamed(AppRoutes.signUpProvider),
                      );
                    }

                    final columns =
                        context.gridColumns(mobile: 2, tablet: 3, desktop: 4);

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: list.length,
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisSpacing: AppSpacing.md,
                        mainAxisExtent: 208,
                      ),
                      itemBuilder: (context, index) => BusinessCard(
                        business: list[index],
                        onTap: () => Navigator.of(context).pushNamed(
                          AppRoutes.business,
                          arguments: list[index].id,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
          ],
        ),
      ),
    );
  }
}
