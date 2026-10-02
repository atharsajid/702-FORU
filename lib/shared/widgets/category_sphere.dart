import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/utils/responsive.dart';
import '../../features/catalog/domain/entities/category.dart';
import 'app_network_image.dart';

/// A single category "sphere".
///
/// The design pairs a glossy ball with the category name underneath. The ball
/// carries a slowly drifting gradient so the grid feels alive without costing
/// frames – only the decoration rebuilds, never the image.
class CategorySphere extends StatefulWidget {
  const CategorySphere({super.key, required this.category, required this.onTap, this.animationDelay = Duration.zero});

  final Category category;
  final VoidCallback onTap;
  final Duration animationDelay;

  @override
  State<CategorySphere> createState() => _CategorySphereState();
}

class _CategorySphereState extends State<CategorySphere> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sphereSize = constraints.maxWidth * 0.68;

        return InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Scale-in entrance, then a continuous soft glow behind the ball.
              SizedBox(
                child: Container(
                  height: sphereSize,
                  width: sphereSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.15,
                      colors: [AppColors.sphereGradient[0], AppColors.sphereGradient[1], AppColors.sphereGradient[2]],
                      stops: [0.05, 0.55, 1],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.purple.withValues(alpha: 0.22 + 0.12 ),
                        blurRadius: 14 + 8 ,
                        spreadRadius: 1 + 2 ,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(3),
                  child: ClipOval(
                    child: AppNetworkImage(
                      url: widget.category.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      placeholderIcon: Icons.category_outlined,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: Text(
                  widget.category.name,
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
          animationDelay: Duration(milliseconds: 60 * index),
          onTap: () => onCategoryTap(category),
        );
      },
    );
  }
}
