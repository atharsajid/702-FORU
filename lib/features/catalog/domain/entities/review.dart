import '../../../../core/utils/json_utils.dart';

/// A review. Only registered users may post one – guests are routed to sign up.
class Review {
  const Review({
    required this.id,
    required this.businessId,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String businessId;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final double rating;
  final String comment;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
        'id': id,
        'businessId': businessId,
        'userId': userId,
        'userName': userName,
        'userAvatarUrl': userAvatarUrl,
        'rating': rating,
        'comment': comment,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory Review.fromMap(Map<String, dynamic> map) => Review(
        id: Json.string(map['id']),
        businessId: Json.string(map['businessId']),
        userId: Json.string(map['userId']),
        userName: Json.string(map['userName']),
        userAvatarUrl: Json.nullableString(map['userAvatarUrl']),
        rating: Json.toDouble(map['rating']),
        comment: Json.string(map['comment']),
        createdAt: Json.dateTime(map['createdAt']),
      );

  @override
  bool operator ==(Object other) => other is Review && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
