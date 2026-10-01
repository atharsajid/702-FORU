import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/result_extensions.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/usecases/notifications_usecases.dart';

final getNotificationsProvider = Provider<GetNotifications>(
  (ref) => GetNotifications(ref.watch(notificationsRepositoryProvider)),
);

final markNotificationReadProvider = Provider<MarkNotificationRead>(
  (ref) => MarkNotificationRead(ref.watch(notificationsRepositoryProvider)),
);

final markAllNotificationsReadProvider = Provider<MarkAllNotificationsRead>(
  (ref) => MarkAllNotificationsRead(ref.watch(notificationsRepositoryProvider)),
);

final clearNotificationsProvider = Provider<ClearNotifications>(
  (ref) => ClearNotifications(ref.watch(notificationsRepositoryProvider)),
);

/// Owns the notification list; the badge count derives from it.
class NotificationsController extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() async {
    final result = await ref.watch(getNotificationsProvider)();
    return result.orThrow();
  }

  Future<void> markAsRead(String id) async {
    final current = state.valueOrNull;
    if (current == null) return;

    // Optimistic update so the list reacts instantly.
    state = AsyncData([
      for (final notification in current)
        if (notification.id == id)
          notification.copyWith(isRead: true)
        else
          notification,
    ]);

    await ref.read(markNotificationReadProvider)(id);
  }

  Future<void> markAllAsRead() async {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData([
      for (final notification in current) notification.copyWith(isRead: true),
    ]);

    await ref.read(markAllNotificationsReadProvider)();
  }

  Future<void> clearAll() async {
    state = const AsyncData([]);
    await ref.read(clearNotificationsProvider)();
  }
}

final notificationsControllerProvider =
    AsyncNotifierProvider<NotificationsController, List<AppNotification>>(
  NotificationsController.new,
);

/// Drives the bell badge.
final unreadNotificationCountProvider = Provider<int>((ref) {
  final list = ref.watch(notificationsControllerProvider).valueOrNull;
  if (list == null) return 0;
  return list.where((n) => !n.isRead).length;
});

final hasUnreadNotificationsProvider = Provider<bool>(
  (ref) => ref.watch(unreadNotificationCountProvider) > 0,
);
