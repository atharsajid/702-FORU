// -----------------------------------------------------------
// ⭐ ANIMATED RSS TICKER (Marquee Style)
// -----------------------------------------------------------
import 'package:flutter/material.dart';

class RSSMarquee extends StatefulWidget {
  final List<String> items;

  const RSSMarquee({super.key, required this.items});

  @override
  State<RSSMarquee> createState() => _RSSMarqueeState();
}

class _RSSMarqueeState extends State<RSSMarquee>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _animation = Tween<double>(
      begin: 1,
      end: -1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.items.join("    ⚫    ");

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 38,
        color: Colors.black87,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return FractionalTranslation(
              translation: Offset(_animation.value, 0),
              child: child,
            );
          },
          child: Row(
            children: [
              Text(
                "  📰  $text   ",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
