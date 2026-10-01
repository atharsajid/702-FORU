import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../features/notifications/presentation/providers/notifications_providers.dart';

/// Bell icon with an animated unread badge, wired to the notifications
/// provider so it is always in sync.
class NotificationBell extends ConsumerWidget {
  const NotificationBell({
    super.key,
    required this.onTap,
    this.color = AppColors.textPrimary,
    this.icon = Icons.notifications_none_rounded,
  });

  final VoidCallback onTap;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadNotificationCountProvider);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onTap,
          tooltip: 'Notifications',
          icon: Icon(icon, color: color, size: 24),
        ),
        if (unread > 0)
          Positioned(
            right: 6,
            top: 6,
            child: IgnorePointer(
              child: AnimatedScale(
                duration: AppDurations.fast,
                curve: Curves.easeOutBack,
                scale: 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  constraints: const BoxConstraints(minWidth: 18),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(color: AppColors.white, width: 1.4),
                  ),
                  child: Text(
                    unread > 99 ? '99+' : '$unread',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
