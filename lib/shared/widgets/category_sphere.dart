import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/utils/responsive.dart';
import '../../features/catalog/domain/entities/category.dart';
import 'app_network_image.dart';

/// A single category "sphere".
///
/// A photo set down inside a thick, glossy violet rim. The light comes from the
/// top right: the rim is near-white where it catches it, rolls through vivid
/// violet and buries the bottom left in shadow, while the photo sits in its own
/// recess, shaded away from the light. A soft halo blooms into the page.
///
/// Every dimension comes from the laid-out tile, so the effect holds at any size
/// and column count. The decoration is static, so the grid costs nothing per
/// frame.
class CategorySphere extends StatelessWidget {
  const CategorySphere({super.key, required this.category, required this.onTap});

  final Category category;
  final VoidCallback onTap;

  /// Rim thickness as a share of the sphere's diameter.
  static const double _rimRatio = 0.085;

  /// Halo blurs, as a share of the sphere's diameter.
  static const double _glowBlur = 0.10;
  static const double _bloomBlur = 10;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sphereSize = constraints.maxWidth * 0.68;
        // Never thinner than 3pt, and never so thick that the photo vanishes.
        final rimWidth = math.min(math.max(sphereSize * _rimRatio, 3.0), sphereSize * 0.225);
        // Rim thickness and where the photo starts, both in sphere radii.
        final rim = rimWidth * 2 / sphereSize;
        final inner = 1 - rim;

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppColors.sphereGlow.withAlpha(75), blurRadius: 15, spreadRadius: 0, offset: Offset(-1, 2))],
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    alignment: Alignment.center,
                    children: [
                      Image.asset("assets/ring_image.png", fit: BoxFit.contain),

                      // The rim is painted *under* an inset photo, so it reads as
                      // a raised ring the picture sits down inside of.
                      Padding(
                        padding: EdgeInsets.all(12.5),
                        child: ClipOval(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              AppNetworkImage(
                                url: category.imageUrl,
                                width: double.infinity,
                                height: double.infinity,
                                placeholderIcon: Icons.category_outlined,
                              ),
                              // Shade falling across the photo, away from the
                              // light: the rim casts it in towards bottom left.
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topRight,
                                    end: Alignment.bottomLeft,
                                    colors: [AppColors.transparent, AppColors.transparent, AppColors.sphereRecess.withValues(alpha: 0.32)],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: Text(
                  category.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.25, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Responsive sphere grid. Overflow-proof: the label flexes, never clips.
class CategorySphereGrid extends StatelessWidget {
  const CategorySphereGrid({super.key, required this.categories, required this.onCategoryTap, this.shrinkWrap = true, this.padding});

  final List<Category> categories;
  final ValueChanged<Category> onCategoryTap;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final columns = context.gridColumns(mobile: 3, tablet: 4, desktop: 5);

    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
      // A shrink-wrapped grid never scrolls, so nothing can spill: letting the
      // halo paint past its bounds keeps the glow soft at the outer edges.
      clipBehavior: shrinkWrap ? Clip.none : Clip.hardEdge,
      padding: padding ?? EdgeInsets.symmetric(horizontal: context.pagePadding),
      itemCount: categories.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.lg,
        childAspectRatio: context.responsive(mobile: 0.74, tablet: 0.8),
      ),
      itemBuilder: (context, index) {
        final category = categories[index];
        return CategorySphere(category: category, onTap: () => onCategoryTap(category));
      },
    );
  }
}
