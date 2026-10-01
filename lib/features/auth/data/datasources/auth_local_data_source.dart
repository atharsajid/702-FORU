import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/hive_service.dart';
import '../../domain/entities/app_user.dart';

/// Stores accounts and the active session in Hive.
///
/// Local-mock only: swap this class for a Firebase/Supabase data source later –
/// nothing else in the app talks to Hive directly for auth.
class AuthLocalDataSource {
  const AuthLocalDataSource();

  Box<dynamic> get _users => HiveService.box(HiveBoxes.users);
  Box<dynamic> get _session => HiveService.box(HiveBoxes.session);

  // ── Session ────────────────────────────────────────────────────────────
  String? get currentUserId {
    final value = _session.get(HiveKeys.currentUserId);
    return value is String ? value : null;
  }

  Future<void> saveSession(String userId) async {
    try {
      await _session.put(HiveKeys.currentUserId, userId);
    } catch (_) {
      throw const LocalStorageException('Could not save your session.');
    }
  }

  Future<void> clearSession() async {
    try {
      await _session.delete(HiveKeys.currentUserId);
    } catch (_) {
      throw const LocalStorageException('Could not clear your session.');
    }
  }

  // ── Accounts ───────────────────────────────────────────────────────────
  List<AppUser> getAllUsers() {
    try {
      return _users.values
          .whereType<Map>()
          .map((e) => AppUser.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      throw const LocalStorageException('Could not read accounts.');
    }
  }

  AppUser? findById(String id) {
    final raw = _users.get(id);
    if (raw is Map) return AppUser.fromMap(Map<String, dynamic>.from(raw));
    return null;
  }

  AppUser? findByEmail(String email) {
    final normalized = email.trim().toLowerCase();
    for (final user in getAllUsers()) {
      if (user.email.toLowerCase() == normalized) return user;
    }
    return null;
  }

  Future<void> upsertUser(AppUser user) async {
    try {
      await _users.put(user.id, user.toMap());
    } catch (_) {
      throw const LocalStorageException('Could not save your account.');
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _users.delete(id);
    } catch (_) {
      throw const LocalStorageException('Could not delete the account.');
    }
  }
}
