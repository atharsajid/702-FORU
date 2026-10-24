import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/business_card.dart';
import '../../domain/entities/business.dart';
import '../providers/catalog_providers.dart';

/// Every partner with a paid Spotlight placement.
class SpotlightBusinessesScreen extends ConsumerWidget {
  const SpotlightBusinessesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sponsored = ref.watch(sponsoredBusinessesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Spotlight Businesses')),
      body: RefreshIndicator(
        color: AppColors.purple,
        onRefresh: () async {
          ref.invalidate(sponsoredBusinessesProvider);
          await ref.read(sponsoredBusinessesProvider.future);
        },
        child: AsyncValueView<List<Business>>(
          value: sponsored,
          onRetry: () => ref.invalidate(sponsoredBusinessesProvider),
          builder: (context, list) {
            if (list.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 80),
                  AppEmptyState(
                    title: 'No spotlight businesses yet',
                    message: 'Check back soon — we add new partners weekly.',
                    icon: Icons.storefront_outlined,
                  ),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(
                context.pagePadding,
                AppSpacing.lg,
                context.pagePadding,
                AppSpacing.xxxl,
              ),
              itemCount: list.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      '${list.length} featured partners this week',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                }
                final business = list[index - 1];
                return BusinessListTile(
                  business: business,
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRoutes.business,
                    arguments: business.id,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
