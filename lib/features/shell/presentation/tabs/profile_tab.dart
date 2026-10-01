import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../../../notifications/presentation/providers/notifications_providers.dart';

/// Account hub: summary card, shortcuts and sign-out.
class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final favoriteCount = ref.watch(favoritesControllerProvider).valueOrNull?.length ?? 0;
    final unread = ref.watch(unreadNotificationCountProvider);

    if (user == null) return const _GuestProfile();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          context.pagePadding,
          AppSpacing.md,
          context.pagePadding,
          AppSpacing.xxxl,
        ),
        children: [
          // ── Account summary ──────────────────────────────────────────
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                AppAvatar(
                  imageUrl: user.avatarUrl,
                  initials: user.initials,
                  size: 58,
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppTag(
                        label: user.role.label,
                        icon: user.role.isProvider
                            ? Icons.storefront_outlined
                            : Icons.person_outline,
                        color: AppColors.purple.withValues(alpha: 0.12),
                        textColor: AppColors.purple,
                        compact: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── Provider shortcut ────────────────────────────────────────
          if (user.role.isProvider) ...[
            AppCard(
              onTap: () => Navigator.of(context)
                  .pushNamed(AppRoutes.providerDashboard),
              gradient: AppColors.brandGradient,
              child: Row(
                children: [
                  const Icon(Icons.dashboard_customize_outlined,
                      color: AppColors.white),
                  const SizedBox(width: AppSpacing.md),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Provider Dashboard',
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Manage your listing, coupons and billing',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward, color: AppColors.white),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // ── Shortcuts ────────────────────────────────────────────────
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _MenuRow(
                  icon: Icons.bookmark_border_rounded,
                  title: 'Saved businesses',
                  trailingText: '$favoriteCount',
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.favorites),
                ),
                const Divider(height: 1, indent: 60),
                _MenuRow(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  trailingText: unread > 0 ? '$unread new' : null,
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.notifications),
                ),
                const Divider(height: 1, indent: 60),
                _MenuRow(
                  icon: Icons.local_offer_outlined,
                  title: 'Exclusive offers',
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.offers),
                ),
                const Divider(height: 1, indent: 60),
                _MenuRow(
                  icon: Icons.person_outline_rounded,
                  title: 'Edit profile',
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.editProfile),
                ),
                const Divider(height: 1, indent: 60),
                _MenuRow(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.settings),
                ),
                const Divider(height: 1, indent: 60),
                _MenuRow(
                  icon: Icons.info_outline_rounded,
                  title: 'About 702FORU',
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.about),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          AppButton(
            label: 'Sign out',
            variant: AppButtonVariant.outline,
            icon: Icons.logout_rounded,
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) {
                context.showSnack('You have been signed out.');
              }
            },
          ),
        ],
      ),
    );
  }
}

/// Shown to guests – explains the value of registering.
class _GuestProfile extends StatelessWidget {
  const _GuestProfile();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 84,
                width: 84,
                decoration: BoxDecoration(
                  color: AppColors.purple.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  size: 40,
                  color: AppColors.purple,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Join 702FORU',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Save favourites, redeem exclusive coupons and leave reviews for the businesses you love.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppButton(
                label: 'Sign In / Sign Up',
                icon: Icons.login_rounded,
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.login),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: 'How it works',
                variant: AppButtonVariant.ghost,
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.howItWorks),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailingText,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            AppIconTile(icon: icon, size: 36),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText!,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
            const SizedBox(width: AppSpacing.sm),
            const Icon(Icons.chevron_right, color: AppColors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}
