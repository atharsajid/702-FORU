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
  static const double _bloomBlur = 0.28;

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
                width: sphereSize,
                height: sphereSize,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.sphereRimGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.sphereGlow,
                        blurRadius: sphereSize * _glowBlur,
                        spreadRadius: sphereSize * 0.01,
                      ),
                      BoxShadow(
                        color: AppColors.sphereGlowBloom,
                        blurRadius: sphereSize * _bloomBlur,
                        spreadRadius: sphereSize * 0.022,
                      ),
                    ],
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Sheen where the light first strikes the rim, painted
                      // under the photo so it only ever shows on the rim.
                      DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            // Sits on the rim itself at 1.30: the ball's 45°
                            // point is half a box out on both axes.
                            center: const Alignment(0.5, -0.5),
                            radius: 0.24,
                            colors: [
                              AppColors.white.withValues(alpha: 0.55),
                              AppColors.transparent,
                            ],
                          ),
                        ),
                      ),
                      // The rim is painted *under* an inset photo, so it reads as
                      // a raised ring the picture sits down inside of.
                      Padding(
                        padding: EdgeInsets.all(rimWidth),
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
                                    colors: [
                                      AppColors.transparent,
                                      AppColors.transparent,
                                      AppColors.sphereRecess.withValues(alpha: 0.32),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Cross-section of the rim, painted over photo and rim
                      // alike: recess under the overhang, a lit lip where the
                      // tube turns back towards the light, then the silhouette.
                      DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            // Radius 0.5 puts the final stop exactly on the
                            // sphere's edge, so every stop below is a fraction of
                            // its radius.
                            radius: 0.5,
                            colors: [
                              AppColors.transparent,
                              AppColors.transparent,
                              AppColors.sphereRecess.withValues(alpha: 0.30),
                              AppColors.sphereRecess.withValues(alpha: 0.55),
                              AppColors.transparent,
                              AppColors.white.withValues(alpha: 0.60),
                              AppColors.transparent,
                              AppColors.sphereRecess.withValues(alpha: 0.06),
                              AppColors.sphereRecess.withValues(alpha: 0.14),
                            ],
                            stops: [
                              0,
                              inner - 0.09,
                              inner - 0.014,
                              inner,
                              inner + rim * 0.10,
                              inner + rim * 0.18,
                              inner + rim * 0.55,
                              inner + rim * 0.80,
                              1,
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
        return CategorySphere(
          category: category,
          onTap: () => onCategoryTap(category),
        );
      },
    );
  }
}
