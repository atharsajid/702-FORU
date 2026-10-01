import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/hive_service.dart';
import '../../domain/entities/app_notification.dart';

class NotificationsLocalDataSource {
  const NotificationsLocalDataSource();

  Box<dynamic> get _box => HiveService.box(HiveBoxes.notifications);

  List<AppNotification> getAll() {
    try {
      return _box.values
          .whereType<Map>()
          .map((e) => AppNotification.fromMap(Map<String, dynamic>.from(e)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      throw const LocalStorageException('Could not load notifications.');
    }
  }

  Future<void> upsert(AppNotification notification) async {
    try {
      await _box.put(notification.id, notification.toMap());
    } catch (_) {
      throw const LocalStorageException();
    }
  }

  Future<void> putAll(List<AppNotification> notifications) async {
    try {
      final entries = {
        for (final n in notifications) n.id: n.toMap(),
      };
      await _box.putAll(entries);
    } catch (_) {
      throw const LocalStorageException();
    }
  }

  Future<void> deleteAll() async {
    try {
      await _box.clear();
    } catch (_) {
      throw const LocalStorageException();
    }
  }
}
