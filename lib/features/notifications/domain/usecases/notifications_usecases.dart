import '../../../../core/error/error_handler.dart';
import '../entities/app_notification.dart';
import '../repositories/notifications_repository.dart';

class GetNotifications {
  const GetNotifications(this._repository);
  final NotificationsRepository _repository;

  Future<Result<List<AppNotification>>> call() => _repository.getNotifications();
}

class GetUnreadNotificationCount {
  const GetUnreadNotificationCount(this._repository);
  final NotificationsRepository _repository;

  Future<Result<int>> call() => _repository.getUnreadCount();
}

class MarkNotificationRead {
  const MarkNotificationRead(this._repository);
  final NotificationsRepository _repository;

  Future<Result<void>> call(String id) => _repository.markAsRead(id);
}

class MarkAllNotificationsRead {
  const MarkAllNotificationsRead(this._repository);
  final NotificationsRepository _repository;

  Future<Result<void>> call() => _repository.markAllAsRead();
}

class ClearNotifications {
  const ClearNotifications(this._repository);
  final NotificationsRepository _repository;

  Future<Result<void>> call() => _repository.clearAll();
}
