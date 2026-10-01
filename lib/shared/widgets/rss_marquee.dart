import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

/// Continuous "news ticker" strip (RSS feed area on Home).
///
/// The label is measured with a [TextPainter] and repeated just enough times to
/// fill the strip, then translated by exactly one copy width – giving a
/// seamless, allocation-free loop that only rebuilds a transform.
class RssMarquee extends StatefulWidget {
  const RssMarquee({
    super.key,
    required this.items,
    this.height = 38,
    this.onTap,
  });

  final List<String> items;
  final double height;
  final VoidCallback? onTap;

  @override
  State<RssMarquee> createState() => _RssMarqueeState();
}

class _RssMarqueeState extends State<RssMarquee>
    with SingleTickerProviderStateMixin {
  static const TextStyle _style = TextStyle(
    color: AppColors.white,
    fontSize: 13.5,
    fontWeight: FontWeight.w500,
  );

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _label {
    final text = widget.items
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .join('     •     ');
    if (text.isEmpty) return '702FORU — Your Vegas, ready.';
    return '$text     •     ';
  }

  @override
  Widget build(BuildContext context) {
    final label = _label;

    final painter = TextPainter(
      text: TextSpan(text: label, style: _style),
      maxLines: 1,
      textDirection: Directionality.of(context),
    )..layout();
    final copyWidth = painter.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: Material(
        color: AppColors.navyDark,
        borderRadius: BorderRadius.circular(AppRadius.md),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          child: SizedBox(
            height: widget.height,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Enough copies to always cover the strip while scrolling.
                final copies = copyWidth <= 0
                    ? 2
                    : (constraints.maxWidth / copyWidth).ceil() + 2;

                return ClipRect(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(-_controller.value * copyWidth, 0),
                      child: child,
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: AppSpacing.md),
                        const Icon(
                          Icons.article_outlined,
                          size: 15,
                          color: AppColors.cyan,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        for (var i = 0; i < copies; i++)
                          Text(label, style: _style, maxLines: 1),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
