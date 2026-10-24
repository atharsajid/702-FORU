import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/category_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/category_sphere.dart';
import '../../domain/entities/category.dart';
import '../providers/catalog_providers.dart';

/// Full grid of every active category.
class AllCategoriesScreen extends ConsumerWidget {
  const AllCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('All Categories')),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          context.pagePadding,
          AppSpacing.lg,
          context.pagePadding,
          AppSpacing.xxxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AsyncValueView<List<Category>>(
              value: categories,
              onRetry: () => ref.invalidate(categoriesProvider),
              builder: (context, list) {
                if (list.isEmpty) {
                  return const AppEmptyState(
                    title: 'No categories yet',
                    icon: Icons.category_outlined,
                  );
                }
                return CategorySphereGrid(
                  categories: list,
                  padding: EdgeInsets.zero,
                  onCategoryTap: (category) => openCategory(context, category),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Row(
                children: [
                  const AppIconTile(
                    icon: Icons.info_outline_rounded,
                    color: AppColors.cyan,
                    size: 38,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Categories are managed by 702FORU and can grow as the city does.',
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
