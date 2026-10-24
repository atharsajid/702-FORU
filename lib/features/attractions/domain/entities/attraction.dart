import '../../../../core/utils/json_utils.dart';

/// A free, local thing to do.
///
/// Attractions are intentionally separate from [Business]: they have no
/// coupons, reviews or billing, but they do need a location, opening hours and
/// a page of their own.
class Attraction {
  const Attraction({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.imageUrl,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.gallery = const [],
    this.hoursLabel = '',
    this.costLabel = 'Free',
    this.website = '',
    this.goodToKnow = const [],
    this.isActive = true,
    this.sortOrder = 0,
    required this.lastVerifiedAt,
  });

  final String id;
  final String name;

  /// One-line hook shown on the listing card.
  final String tagline;

  final String description;

  /// Hero photo.
  final String imageUrl;

  final List<String> gallery;

  final String address;
  final double latitude;
  final double longitude;

  /// Human-readable opening hours, e.g. `Open daily, sunrise–sunset`.
  final String hoursLabel;

  /// Almost always `Free`, kept as a field for the occasional paid extra.
  final String costLabel;

  final String website;

  /// Short practical tips ("Bring water", "Best at sunset").
  final List<String> goodToKnow;

  /// Closed or retired attractions stay in storage but never render.
  final bool isActive;

  final int sortOrder;

  /// When someone last confirmed the place is open and still free.
  final DateTime lastVerifiedAt;

  Attraction copyWith({
    String? name,
    String? tagline,
    String? description,
    String? imageUrl,
    List<String>? gallery,
    String? address,
    double? latitude,
    double? longitude,
    String? hoursLabel,
    String? costLabel,
    String? website,
    List<String>? goodToKnow,
    bool? isActive,
    int? sortOrder,
    DateTime? lastVerifiedAt,
  }) {
    return Attraction(
      id: id,
      name: name ?? this.name,
      tagline: tagline ?? this.tagline,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      gallery: gallery ?? this.gallery,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      hoursLabel: hoursLabel ?? this.hoursLabel,
      costLabel: costLabel ?? this.costLabel,
      website: website ?? this.website,
      goodToKnow: goodToKnow ?? this.goodToKnow,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      lastVerifiedAt: lastVerifiedAt ?? this.lastVerifiedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'tagline': tagline,
        'description': description,
        'imageUrl': imageUrl,
        'gallery': gallery,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'hoursLabel': hoursLabel,
        'costLabel': costLabel,
        'website': website,
        'goodToKnow': goodToKnow,
        'isActive': isActive,
        'sortOrder': sortOrder,
        'lastVerifiedAt': lastVerifiedAt.millisecondsSinceEpoch,
      };

  factory Attraction.fromMap(Map<String, dynamic> map) => Attraction(
        id: Json.string(map['id']),
        name: Json.string(map['name']),
        tagline: Json.string(map['tagline']),
        description: Json.string(map['description']),
        imageUrl: Json.string(map['imageUrl']),
        gallery: Json.stringList(map['gallery']),
        address: Json.string(map['address']),
        latitude: Json.toDouble(map['latitude']),
        longitude: Json.toDouble(map['longitude']),
        hoursLabel: Json.string(map['hoursLabel']),
        costLabel: Json.string(map['costLabel'], fallback: 'Free'),
        website: Json.string(map['website']),
        goodToKnow: Json.stringList(map['goodToKnow']),
        isActive: Json.toBool(map['isActive'], fallback: true),
        sortOrder: Json.toInt(map['sortOrder']),
        lastVerifiedAt: Json.dateTime(map['lastVerifiedAt']),
      );

  @override
  bool operator ==(Object other) => other is Attraction && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
