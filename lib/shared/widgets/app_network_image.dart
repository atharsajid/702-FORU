import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/utils/image_url.dart';

/// The only way the app loads remote images.
///
/// Centralising this guarantees disk caching, a fade-in, identical
/// placeholder / error states everywhere – and, critically, that **every**
/// image is downloaded and decoded at the size it is actually painted.
///
/// An un-capped network image is a memory bomb: a 3928x2945 stock photo
/// decodes to ~44 MB of bitmap, so a scrolling grid of them is enough for the
/// OS to kill the app. Two independent guards prevent that:
///
///  * the CDN is asked for a pre-compressed, right-sized file via [ImageUrl];
///  * [memCacheWidth] caps the decoded bitmap, so a host that ignores resize
///    parameters (a future backend, say) still cannot blow the budget.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderIcon = Icons.image_outlined,
    this.backgroundColor,
    this.alignment = Alignment.center,
    this.cacheWidth,
    this.cacheHeight,
    this.maxDecodePixels = ImageUrl.maxDecodePixels,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData placeholderIcon;
  final Color? backgroundColor;
  final Alignment alignment;

  /// Decode size in logical pixels, overriding [width] / [height].
  ///
  /// Leave null – the widget derives the target from the box it is given.
  final double? cacheWidth;
  final double? cacheHeight;

  /// Ceiling for the decoded bitmap width, in physical pixels. Raise it only
  /// for a genuinely full-bleed hero.
  final int maxDecodePixels;

  @override
  Widget build(BuildContext context) {
    final image = _build(context);
    final radius = borderRadius;
    if (radius == null) return image;
    return ClipRRect(borderRadius: radius, child: image);
  }

  Widget _build(BuildContext context) {
    final source = url?.trim() ?? '';
    if (source.isEmpty) return _placeholder(isError: true);

    final dpr = MediaQuery.devicePixelRatioOf(context);
    final knownWidth = _finite(cacheWidth ?? width);
    final knownHeight = _finite(cacheHeight ?? height);

    // Callers that pass an explicit box (thumbnails, avatars, banners) already
    // describe the target, so no extra layout pass is needed.
    if (knownWidth != null && knownHeight != null) {
      return _image(source, knownWidth, knownHeight, dpr);
    }

    // "Fill the space" callers pass `double.infinity`, so the real size is only
    // known once laid out. Measuring here keeps grid tiles and hero banners
    // decoding at the size they are actually painted.
    return LayoutBuilder(
      builder: (context, constraints) {
        return _image(
          source,
          knownWidth ??
              _bounded(constraints.hasBoundedWidth, constraints.maxWidth),
          knownHeight ??
              _bounded(constraints.hasBoundedHeight, constraints.maxHeight),
          dpr,
        );
      },
    );
  }

  Widget _image(
    String source,
    double? logicalWidth,
    double? logicalHeight,
    double dpr,
  ) {
    var decodeWidth = _toPixels(logicalWidth, dpr);
    final decodeHeight = _toPixels(logicalHeight, dpr);

    // Even a fully unbounded parent gets a ceiling rather than the original
    // multi-megapixel file.
    decodeWidth ??= maxDecodePixels;

    return CachedNetworkImage(
      imageUrl: ImageUrl.optimized(
        source,
        width: decodeWidth,
        height: decodeHeight,
      ),
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      fadeInDuration: AppDurations.fast,
      fadeOutDuration: AppDurations.instant,
      // Only the width is pinned so the aspect ratio is always preserved – the
      // URL above already bounds the other axis.
      memCacheWidth: decodeWidth,
      placeholder: (_, __) => _placeholder(),
      errorWidget: (_, __, ___) => _placeholder(isError: true),
    );
  }

  /// A usable logical size, or null when the value cannot describe a box.
  static double? _finite(double? value) {
    if (value == null || !value.isFinite || value <= 0) return null;
    return value;
  }

  static double? _bounded(bool hasBounded, double value) =>
      hasBounded ? _finite(value) : null;

  /// Converts a logical size to a physical pixel count, clamped to the ceiling.
  int? _toPixels(double? logical, double dpr) {
    if (logical == null) return null;
    final scaled = (logical * dpr).round();
    if (scaled < 1) return 1;
    return scaled > maxDecodePixels ? maxDecodePixels : scaled;
  }

  Widget _placeholder({bool isError = false}) {
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? AppColors.surfaceMuted,
      alignment: Alignment.center,
      child: Icon(
        isError ? Icons.broken_image_outlined : placeholderIcon,
        color: AppColors.grey,
        size: 22,
      ),
    );
  }
}

/// Circular avatar with an initials fallback – used in profile, reviews and
/// provider cards.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.size = 40,
    this.backgroundColor,
    this.foregroundColor,
    this.icon,
  });

  final String? imageUrl;
  final String? initials;
  final double size;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final hasImage = (imageUrl?.trim().isNotEmpty ?? false);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? AppColors.purple.withValues(alpha: 0.12),
      ),
      alignment: Alignment.center,
      child: hasImage
          ? ClipOval(
              child: AppNetworkImage(
                url: imageUrl,
                width: size,
                height: size,
                placeholderIcon: Icons.person_outline,
              ),
            )
          : _fallback(),
    );
  }

  Widget _fallback() {
    if (icon != null) {
      return Icon(
        icon,
        size: size * 0.5,
        color: foregroundColor ?? AppColors.purple,
      );
    }
    final text = initials?.trim();
    if (text == null || text.isEmpty) {
      return Icon(
        Icons.person_outline,
        size: size * 0.5,
        color: foregroundColor ?? AppColors.purple,
      );
    }
    return Text(
      text,
      style: TextStyle(
        fontSize: size * 0.36,
        fontWeight: FontWeight.w700,
        color: foregroundColor ?? AppColors.purple,
      ),
    );
  }
}
