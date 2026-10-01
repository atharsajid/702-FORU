import '../../../../core/error/error_handler.dart';
import '../entities/app_notification.dart';

abstract class NotificationsRepository {
  Future<Result<List<AppNotification>>> getNotifications();
  Future<Result<int>> getUnreadCount();
  Future<Result<void>> markAsRead(String id);
  Future<Result<void>> markAllAsRead();
  Future<Result<void>> clearAll();
  Future<Result<void>> push(AppNotification notification);
}
