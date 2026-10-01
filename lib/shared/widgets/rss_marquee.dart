import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

/// Continuous "news ticker" strip (RSS feed area on Home).
///
/// The label is measured with a [TextPainter] and repeated just enough times to
/// fill the strip, then translated by exactly one copy width – giving a
/// seamless, allocation-free loop that only rebuilds a transform.
class RssMarquee extends StatefulWidget {
  const RssMarquee({super.key, required this.items, this.height = 38, this.onTap});

  final List<String> items;
  final double height;
  final VoidCallback? onTap;

  @override
  State<RssMarquee> createState() => _RssMarqueeState();
}

class _RssMarqueeState extends State<RssMarquee> {
  static const TextStyle _style = TextStyle(color: AppColors.white, fontSize: 13.5, fontWeight: FontWeight.w500);

  String get _label {
    final text = widget.items.map((e) => e.trim()).where((e) => e.isNotEmpty).join('     •     ');
    if (text.isEmpty) return '702FORU — Your Vegas, ready.';
    return '$text     •     ';
  }

  @override
  Widget build(BuildContext context) {
    final label = _label;

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
            child: Marquee(text: label, style: _style),
          ),
        ),
      ),
    );
  }
}
