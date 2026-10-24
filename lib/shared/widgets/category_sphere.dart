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

  /// Largest the sphere ever grows on tablets and desktop.
  static const double maxDiameter = 152;

  /// Halo blur, as a share of the sphere's diameter.
  static const double _glowBlurRatio = 0.14;

  /// Where the photo starts inside the ring, as a share of the diameter.
  static const double photoInsetRatio = 0.1136;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final diameter = math.min(constraints.maxWidth, maxDiameter);

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: diameter,
                height: diameter,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.sphereGlow.withValues(alpha: 0.29),
                        blurRadius: diameter * _glowBlurRatio,
                        spreadRadius: 0,
                        offset: const Offset(-1, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    alignment: Alignment.center,
                    children: [
                      Image.asset('assets/ring_image.png', fit: BoxFit.contain),

                      // The rim is painted *under* an inset photo, so it reads as
                      // a raised ring the picture sits down inside of.
                      Padding(
                        padding: EdgeInsets.all(diameter * photoInsetRatio),
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
              Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.25, color: AppColors.textPrimary),
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
    const spacing = AppSpacing.md;
    final gridPadding =
        padding ?? EdgeInsets.symmetric(horizontal: context.pagePadding);

    return LayoutBuilder(
      builder: (context, constraints) {
        // The tile hugs the sphere plus its two-line label, so the grid stays
        // tight at every width instead of reserving empty space on tablets.
        final horizontalInset = gridPadding is EdgeInsets
            ? gridPadding.left + gridPadding.right
            : 0.0;
        final tileWidth =
            (constraints.maxWidth - horizontalInset - spacing * (columns - 1)) /
                columns;
        final diameter = math.min(tileWidth, CategorySphere.maxDiameter);
        final labelHeight =
            MediaQuery.textScalerOf(context).scale(12) * 1.25 * 2 + 4;

        return GridView.builder(
          shrinkWrap: shrinkWrap,
          physics:
              shrinkWrap ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
          // A shrink-wrapped grid never scrolls, so nothing can spill: letting
          // the halo paint past its bounds keeps the glow soft at the edges.
          clipBehavior: shrinkWrap ? Clip.none : Clip.hardEdge,
          padding: gridPadding,
          itemCount: categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: AppSpacing.lg,
            mainAxisExtent: diameter + AppSpacing.sm + labelHeight,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
            return CategorySphere(category: category, onTap: () => onCategoryTap(category));
          },
        );
      },
    );
  }
}
