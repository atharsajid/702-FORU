import '../../../../core/error/error_handler.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_local_data_source.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._local);

  final NotificationsLocalDataSource _local;

  @override
  Future<Result<List<AppNotification>>> getNotifications() =>
      AppErrorHandler.guard(() async => _local.getAll());

  @override
  Future<Result<int>> getUnreadCount() => AppErrorHandler.guard(
        () async => _local.getAll().where((n) => !n.isRead).length,
      );

  @override
  Future<Result<void>> markAsRead(String id) => AppErrorHandler.guard(() async {
        final match = _local.getAll().where((n) => n.id == id);
        if (match.isNotEmpty) {
          await _local.upsert(match.first.copyWith(isRead: true));
        }
      });

  @override
  Future<Result<void>> markAllAsRead() => AppErrorHandler.guard(() async {
        final updated = _local
            .getAll()
            .map((n) => n.copyWith(isRead: true))
            .toList(growable: false);
        await _local.putAll(updated);
      });

  @override
  Future<Result<void>> clearAll() =>
      AppErrorHandler.guard(() => _local.deleteAll());

  @override
  Future<Result<void>> push(AppNotification notification) =>
      AppErrorHandler.guard(() => _local.upsert(notification));
}
