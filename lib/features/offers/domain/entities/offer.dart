import '../../../../core/utils/json_utils.dart';

/// An "Exclusive 702FORU Offer" surfaced on the home banner and the
/// Explore-Now screen.
class Offer {
  const Offer({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.ctaLabel = 'Explore Now',
    this.businessId,
    this.categoryId,
    this.route,
    this.expiresAt,
    this.isActive = true,
    this.isFeatured = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String ctaLabel;

  /// Optional link to a business / category so "Explore Now" has a target.
  final String? businessId;
  final String? categoryId;

  /// Optional app route for offers that are not tied to a listing – the
  /// advertising page or the sign-up flow, for example.
  final String? route;

  /// Whether tapping this offer leads somewhere.
  bool get hasTarget =>
      businessId != null || categoryId != null || route != null;

  final DateTime? expiresAt;
  final bool isActive;

  /// Marks the one offer promoted to the Home "Featured in Vegas" banner.
  final bool isFeatured;

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'imageUrl': imageUrl,
        'ctaLabel': ctaLabel,
        'businessId': businessId,
        'categoryId': categoryId,
        'route': route,
        'expiresAt': expiresAt?.millisecondsSinceEpoch,
        'isActive': isActive,
        'isFeatured': isFeatured,
      };

  factory Offer.fromMap(Map<String, dynamic> map) => Offer(
        id: Json.string(map['id']),
        title: Json.string(map['title']),
        subtitle: Json.string(map['subtitle']),
        imageUrl: Json.string(map['imageUrl']),
        ctaLabel: Json.string(map['ctaLabel'], fallback: 'Explore Now'),
        businessId: Json.nullableString(map['businessId']),
        categoryId: Json.nullableString(map['categoryId']),
        route: Json.nullableString(map['route']),
        expiresAt: Json.nullableDateTime(map['expiresAt']),
        isActive: Json.toBool(map['isActive'], fallback: true),
        isFeatured: Json.toBool(map['isFeatured']),
      );

  @override
  bool operator ==(Object other) => other is Offer && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
