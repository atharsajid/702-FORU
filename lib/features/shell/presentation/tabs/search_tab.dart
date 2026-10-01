import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/business_card.dart';
import '../../../catalog/domain/entities/business.dart';
import '../../../catalog/domain/entities/category.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';

/// Search across businesses, services and addresses.
class SearchTab extends ConsumerStatefulWidget {
  const SearchTab({super.key});

  @override
  ConsumerState<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends ConsumerState<SearchTab> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 280), () {
      if (mounted) setState(() => _query = value.trim());
    });
  }

  void _clear() {
    _controller.clear();
    _debounce?.cancel();
    setState(() => _query = '');
  }

  void _openBusiness(Business business) {
    Navigator.of(context).pushNamed(
      AppRoutes.business,
      arguments: business.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(searchResultsProvider(_query));
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.pagePadding,
                AppSpacing.md,
                context.pagePadding,
                AppSpacing.md,
              ),
              child: AppSearchField(
                controller: _controller,
                hint: 'Search businesses, services…',
                onChanged: _onChanged,
                onClear: _query.isEmpty ? null : _clear,
              ),
            ),
            Expanded(
              child: _query.isEmpty
                  ? _CategoryShortcuts(
                      categories: categories,
                      onCategoryTap: (category) => Navigator.of(context)
                          .pushNamed(AppRoutes.category, arguments: category),
                      onRetry: () => ref.invalidate(categoriesProvider),
                    )
                  : AsyncValueView<List<Business>>(
                      value: results,
                      onRetry: () =>
                          ref.invalidate(searchResultsProvider(_query)),
                      builder: (context, list) {
                        if (list.isEmpty) {
                          return AppEmptyState(
                            title: 'No matches for "$_query"',
                            message:
                                'Try a different keyword, or browse the categories.',
                            icon: Icons.search_off_rounded,
                            actionLabel: 'Clear search',
                            onAction: _clear,
                          );
                        }
                        return ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            context.pagePadding,
                            AppSpacing.xs,
                            context.pagePadding,
                            AppSpacing.xxxl,
                          ),
                          itemCount: list.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) => BusinessListTile(
                            business: list[index],
                            onTap: () => _openBusiness(list[index]),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown before the user types – quick access to every category.
class _CategoryShortcuts extends StatelessWidget {
  const _CategoryShortcuts({
    required this.categories,
    required this.onCategoryTap,
    required this.onRetry,
  });

  final AsyncValue<List<Category>> categories;
  final ValueChanged<Category> onCategoryTap;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AsyncValueView<List<Category>>(
      value: categories,
      onRetry: onRetry,
      builder: (context, list) {
        if (list.isEmpty) {
          return const AppEmptyState(
            title: 'Nothing to browse yet',
            icon: Icons.category_outlined,
          );
        }
        final columns = context.gridColumns(mobile: 2, tablet: 3, desktop: 4);

        return GridView.builder(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            context.pagePadding,
            AppSpacing.xs,
            context.pagePadding,
            AppSpacing.xxxl,
          ),
          itemCount: list.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            mainAxisExtent: 64,
          ),
          itemBuilder: (context, index) {
            final category = list[index];
            return AppCard(
              onTap: () => onCategoryTap(category),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  const AppIconTile(icon: Icons.category_outlined, size: 34),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      category.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
