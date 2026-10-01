import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/business_card.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../catalog/domain/entities/business.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';

/// Businesses the signed-in user has bookmarked.
class SavedTab extends ConsumerWidget {
  const SavedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final favorites = ref.watch(favoriteBusinessesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Saved'),
        automaticallyImplyLeading: false,
      ),
      body: !isAuthenticated
          ? AppEmptyState(
              title: 'Sign in to save favourites',
              message:
                  'Create a free account to bookmark businesses and keep your coupons in one place.',
              icon: Icons.bookmark_border_rounded,
              actionLabel: 'Sign In / Sign Up',
              onAction: () =>
                  Navigator.of(context).pushNamed(AppRoutes.login),
            )
          : AsyncValueView<List<Business>>(
              value: favorites,
              onRetry: () => ref.invalidate(favoriteBusinessesProvider),
              builder: (context, list) {
                if (list.isEmpty) {
                  return AppEmptyState(
                    title: 'No saved businesses yet',
                    message:
                        'Tap the bookmark icon on any business to save it here.',
                    icon: Icons.bookmark_border_rounded,
                    actionLabel: 'Explore categories',
                    onAction: () =>
                        Navigator.of(context).pushNamed(AppRoutes.allCategories),
                  );
                }
                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    context.pagePadding,
                    AppSpacing.md,
                    context.pagePadding,
                    AppSpacing.xxxl,
                  ),
                  itemCount: list.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) => BusinessListTile(
                    business: list[index],
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRoutes.business,
                      arguments: list[index].id,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
