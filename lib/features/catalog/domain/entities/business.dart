import '../../../../core/utils/json_utils.dart';

/// A listed business. Every business shares the same "layout page" shape.
class Business {
  const Business({
    required this.id,
    required this.name,
    required this.categoryId,
    this.logoUrl,
    this.coverUrl,
    this.videoUrl,
    this.rating = 0,
    this.reviewCount = 0,
    this.address = '',
    this.latitude,
    this.longitude,
    this.description = '',
    this.phone = '',
    this.website = '',
    this.services = const [],
    this.gallery = const [],
    this.isSponsored = false,
    this.trackingCode = '',
    this.ownerId,
    required this.createdAt,
  });

  final String id;
  final String name;

  /// Category this business registered under.
  final String categoryId;

  /// Square logo / avatar.
  final String? logoUrl;

  /// Wide hero image at the top of the layout page.
  final String? coverUrl;

  /// Optional promo video shown instead of the logo (with 702FORU backlink).
  final String? videoUrl;

  final double rating;
  final int reviewCount;
  final String address;
  final double? latitude;
  final double? longitude;
  final String description;
  final String phone;
  final String website;
  final List<String> services;
  final List<String> gallery;

  /// Paid "Spotlight" placement.
  final bool isSponsored;

  /// 702-4U tracking code used for coupon attribution and monthly billing.
  final String trackingCode;

  /// [AppUser.id] of the provider that owns this listing (null for seeded demo
  /// businesses).
  final String? ownerId;

  final DateTime createdAt;

  Business copyWith({
    String? name,
    String? categoryId,
    String? logoUrl,
    String? coverUrl,
    String? videoUrl,
    double? rating,
    int? reviewCount,
    String? address,
    double? latitude,
    double? longitude,
    String? description,
    String? phone,
    String? website,
    List<String>? services,
    List<String>? gallery,
    bool? isSponsored,
    String? trackingCode,
    String? ownerId,
  }) {
    return Business(
      id: id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      logoUrl: logoUrl ?? this.logoUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      services: services ?? this.services,
      gallery: gallery ?? this.gallery,
      isSponsored: isSponsored ?? this.isSponsored,
      trackingCode: trackingCode ?? this.trackingCode,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'categoryId': categoryId,
        'logoUrl': logoUrl,
        'coverUrl': coverUrl,
        'videoUrl': videoUrl,
        'rating': rating,
        'reviewCount': reviewCount,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'description': description,
        'phone': phone,
        'website': website,
        'services': services,
        'gallery': gallery,
        'isSponsored': isSponsored,
        'trackingCode': trackingCode,
        'ownerId': ownerId,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory Business.fromMap(Map<String, dynamic> map) => Business(
        id: Json.string(map['id']),
        name: Json.string(map['name']),
        categoryId: Json.string(map['categoryId']),
        logoUrl: Json.nullableString(map['logoUrl']),
        coverUrl: Json.nullableString(map['coverUrl']),
        videoUrl: Json.nullableString(map['videoUrl']),
        rating: Json.toDouble(map['rating']),
        reviewCount: Json.toInt(map['reviewCount']),
        address: Json.string(map['address']),
        latitude: Json.nullableDouble(map['latitude']),
        longitude: Json.nullableDouble(map['longitude']),
        description: Json.string(map['description']),
        phone: Json.string(map['phone']),
        website: Json.string(map['website']),
        services: Json.stringList(map['services']),
        gallery: Json.stringList(map['gallery']),
        isSponsored: Json.toBool(map['isSponsored']),
        trackingCode: Json.string(map['trackingCode']),
        ownerId: Json.nullableString(map['ownerId']),
        createdAt: Json.dateTime(map['createdAt']),
      );

  @override
  bool operator ==(Object other) => other is Business && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
