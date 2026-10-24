import '../../../../core/utils/formatters.dart';
import '../../../catalog/domain/entities/business.dart';
import 'offer.dart';

/// The business promoted in the Home "Featured in Vegas" banner.
///
/// The offer carries the editorial copy ("Featured in Vegas", CTA) while the
/// business supplies the photo, rating and the page the banner links to.
class FeaturedSpotlight {
  const FeaturedSpotlight({required this.offer, this.business});

  final Offer offer;
  final Business? business;

  String get title => business?.name ?? offer.title;
  String get subtitle => offer.subtitle;
  String get ctaLabel => offer.ctaLabel;

  String get imageUrl =>
      business?.coverUrl ?? business?.logoUrl ?? offer.imageUrl;

  bool get hasVideo => (business?.videoUrl?.trim().isNotEmpty ?? false);

  /// Null when the promoted listing has no rating yet.
  double? get rating {
    final value = business?.rating ?? 0;
    return value > 0 ? value : null;
  }

  int get reviewCount => business?.reviewCount ?? 0;

  String? get categoryLabel {
    final id = business?.categoryId.trim();
    if (id == null || id.isEmpty) return null;
    return AppFormatters.titleCase(id.replaceAll('-', ' '));
  }

  /// Where a tap should go; null when the offer has no target.
  String? get businessId => business?.id ?? offer.businessId;
}
