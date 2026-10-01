import '../../../../core/utils/json_utils.dart';

/// A redeemable coupon belonging to a business.
///
/// [redemptionCount] powers the usage/billing reporting the client asked for
/// ("track my code 702-4U … so we can bill them").
class Coupon {
  const Coupon({
    required this.id,
    required this.businessId,
    required this.title,
    required this.code,
    this.description = '',
    this.discountPercent = 0,
    this.redemptionCount = 0,
    this.expiresAt,
    this.isActive = true,
  });

  final String id;
  final String businessId;
  final String title;

  /// The redeemable code shown to the user.
  final String code;

  final String description;
  final double discountPercent;
  final int redemptionCount;
  final DateTime? expiresAt;
  final bool isActive;

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());

  bool get isRedeemable => isActive && !isExpired;

  Coupon copyWith({
    String? title,
    String? code,
    String? description,
    double? discountPercent,
    int? redemptionCount,
    DateTime? expiresAt,
    bool? isActive,
  }) {
    return Coupon(
      id: id,
      businessId: businessId,
      title: title ?? this.title,
      code: code ?? this.code,
      description: description ?? this.description,
      discountPercent: discountPercent ?? this.discountPercent,
      redemptionCount: redemptionCount ?? this.redemptionCount,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'businessId': businessId,
        'title': title,
        'code': code,
        'description': description,
        'discountPercent': discountPercent,
        'redemptionCount': redemptionCount,
        'expiresAt': expiresAt?.millisecondsSinceEpoch,
        'isActive': isActive,
      };

  factory Coupon.fromMap(Map<String, dynamic> map) => Coupon(
        id: Json.string(map['id']),
        businessId: Json.string(map['businessId']),
        title: Json.string(map['title']),
        code: Json.string(map['code']),
        description: Json.string(map['description']),
        discountPercent: Json.toDouble(map['discountPercent']),
        redemptionCount: Json.toInt(map['redemptionCount']),
        expiresAt: Json.nullableDateTime(map['expiresAt']),
        isActive: Json.toBool(map['isActive'], fallback: true),
      );

  @override
  bool operator ==(Object other) => other is Coupon && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
