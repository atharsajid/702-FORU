import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../domain/entities/app_notification.dart';
import '../providers/notifications_providers.dart';

/// Inbox for offers, coupon unlocks, review replies and system messages.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsControllerProvider);
    final unread = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: () => ref
                  .read(notificationsControllerProvider.notifier)
                  .markAllAsRead(),
              child: const Text(
                'Mark all read',
                style: TextStyle(color: AppColors.white, fontSize: 12.5),
              ),
            ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: AsyncValueView<List<AppNotification>>(
        value: notifications,
        onRetry: () => ref.invalidate(notificationsControllerProvider),
        builder: (context, list) {
          if (list.isEmpty) {
            return const AppEmptyState(
              title: 'You are all caught up',
              message: 'Offers, coupon unlocks and replies will show up here.',
              icon: Icons.notifications_none_rounded,
            );
          }

          return RefreshIndicator(
            color: AppColors.purple,
            onRefresh: () async =>
                ref.invalidate(notificationsControllerProvider),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(
                context.pagePadding,
                AppSpacing.md,
                context.pagePadding,
                AppSpacing.xxxl,
              ),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) => _NotificationTile(
                notification: list[index],
                onTap: () => _open(context, ref, list[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  void _open(
    BuildContext context,
    WidgetRef ref,
    AppNotification notification,
  ) {
    ref
        .read(notificationsControllerProvider.notifier)
        .markAsRead(notification.id);

    if (notification.offerId != null) {
      Navigator.of(context).pushNamed(AppRoutes.offers);
      return;
    }
    if (notification.businessId != null) {
      Navigator.of(context).pushNamed(
        AppRoutes.business,
        arguments: notification.businessId,
      );
    }
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      color: notification.isRead
          ? AppColors.surface
          : AppColors.purple.withValues(alpha: 0.05),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIconTile(
            icon: _icon,
            color: _color,
            size: 40,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: notification.isRead
                              ? FontWeight.w600
                              : FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      AppFormatters.relative(notification.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  notification.body,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          if (!notification.isRead) ...[
            const SizedBox(width: AppSpacing.sm),
            Container(
              margin: const EdgeInsets.only(top: AppSpacing.xs),
              height: 8,
              width: 8,
              decoration: const BoxDecoration(
                color: AppColors.purple,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData get _icon => switch (notification.type) {
        NotificationType.offer => Icons.local_offer_outlined,
        NotificationType.coupon => Icons.confirmation_number_outlined,
        NotificationType.review => Icons.rate_review_outlined,
        NotificationType.business => Icons.storefront_outlined,
        NotificationType.system => Icons.campaign_outlined,
      };

  Color get _color => switch (notification.type) {
        NotificationType.offer => AppColors.purple,
        NotificationType.coupon => AppColors.success,
        NotificationType.review => AppColors.info,
        NotificationType.business => AppColors.navy,
        NotificationType.system => AppColors.warning,
      };
}
