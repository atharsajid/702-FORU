import 'dart:convert';

import '../../../../core/utils/json_utils.dart';

/// Who is using the app. Providers own a business listing; users consume.
enum UserRole {
  user,
  provider;

  static UserRole fromName(String? value) => UserRole.values.firstWhere(
        (role) => role.name == value,
        orElse: () => UserRole.user,
      );

  bool get isProvider => this == UserRole.provider;
  bool get isUser => this == UserRole.user;

  String get label => isProvider ? 'Business' : 'Visitor';
}

/// A registered account (either a visitor or a business provider).
///
/// NOTE: authentication is **local-mock only** until a backend is introduced.
/// [passwordHash] is a reversible local placeholder – never ship it as-is.
class AppUser {
  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.phone = '',
    this.avatarUrl,
    this.businessId,
    this.passwordHash = '',
    this.marketingOptIn = false,
    required this.createdAt,
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final UserRole role;

  /// Remote avatar (rendered with CachedNetworkImage).
  final String? avatarUrl;

  /// Set for providers: the business they own.
  final String? businessId;

  /// Local-only placeholder. Documented as insecure on purpose so it is
  /// impossible to miss before going to production.
  final String passwordHash;

  final bool marketingOptIn;
  final DateTime createdAt;

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  /// Encodes a raw password for local storage only.
  static String encodePassword(String raw) => base64Encode(utf8.encode(raw));

  bool matchesPassword(String raw) => passwordHash == encodePassword(raw);

  AppUser copyWith({
    String? fullName,
    String? email,
    String? phone,
    UserRole? role,
    String? avatarUrl,
    String? businessId,
    String? passwordHash,
    bool? marketingOptIn,
  }) {
    return AppUser(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      businessId: businessId ?? this.businessId,
      passwordHash: passwordHash ?? this.passwordHash,
      marketingOptIn: marketingOptIn ?? this.marketingOptIn,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'role': role.name,
        'avatarUrl': avatarUrl,
        'businessId': businessId,
        'passwordHash': passwordHash,
        'marketingOptIn': marketingOptIn,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
        id: Json.string(map['id']),
        fullName: Json.string(map['fullName']),
        email: Json.string(map['email']),
        phone: Json.string(map['phone']),
        role: UserRole.fromName(Json.nullableString(map['role'])),
        avatarUrl: Json.nullableString(map['avatarUrl']),
        businessId: Json.nullableString(map['businessId']),
        passwordHash: Json.string(map['passwordHash']),
        marketingOptIn: Json.toBool(map['marketingOptIn']),
        createdAt: Json.dateTime(map['createdAt']),
      );

  @override
  bool operator ==(Object other) => other is AppUser && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
