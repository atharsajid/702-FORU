import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

/// The only way the app loads remote images.
///
/// Centralising this guarantees disk caching, a fade-in, and identical
/// placeholder / error states everywhere.
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
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData placeholderIcon;
  final Color? backgroundColor;
  final AlignmentGeometry alignment;

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

    return CachedNetworkImage(
      imageUrl: source,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      fadeInDuration: AppDurations.fast,
      fadeOutDuration: AppDurations.instant,
      placeholder: (_, __) => _placeholder(),
      errorWidget: (_, __, ___) => _placeholder(isError: true),
    );
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
