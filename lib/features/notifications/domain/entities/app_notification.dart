import '../../../../core/utils/json_utils.dart';

/// What a notification is about – drives the icon and the tap destination.
enum NotificationType {
  offer,
  coupon,
  review,
  business,
  system;

  static NotificationType fromName(String? value) =>
      NotificationType.values.firstWhere(
        (type) => type.name == value,
        orElse: () => NotificationType.system,
      );
}

/// In-app notification. Persisted locally so the list survives restarts.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.businessId,
    this.offerId,
  });

  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;

  /// Optional deep-link targets.
  final String? businessId;
  final String? offerId;

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        title: title,
        body: body,
        type: type,
        createdAt: createdAt,
        isRead: isRead ?? this.isRead,
        businessId: businessId,
        offerId: offerId,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'type': type.name,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'isRead': isRead,
        'businessId': businessId,
        'offerId': offerId,
      };

  factory AppNotification.fromMap(Map<String, dynamic> map) => AppNotification(
        id: Json.string(map['id']),
        title: Json.string(map['title']),
        body: Json.string(map['body']),
        type: NotificationType.fromName(Json.nullableString(map['type'])),
        createdAt: Json.dateTime(map['createdAt']),
        isRead: Json.toBool(map['isRead']),
        businessId: Json.nullableString(map['businessId']),
        offerId: Json.nullableString(map['offerId']),
      );

  @override
  bool operator ==(Object other) => other is AppNotification && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
