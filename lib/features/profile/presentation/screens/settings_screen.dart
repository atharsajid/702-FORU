import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:for_you/features/offers/presentation/providers/offers_providers.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/storage/hive_service.dart';
import '../../../../core/storage/local_seed.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../../../notifications/presentation/providers/notifications_providers.dart';

/// App preferences and local data management.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isResetting = false;

  Future<void> _resetDemoData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset demo data?'),
        content: const Text(
          'This clears local data and restores the seeded categories, '
          'businesses and demo accounts. Your own accounts will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isResetting = true);
    await HiveService.clearAll();
    await LocalSeed.runIfNeeded();
    if (!mounted) return;
    setState(() => _isResetting = false);

    // Everything is Hive-backed, so invalidate the world.
    ref.invalidate(authControllerProvider);
    ref.invalidate(categoriesProvider);
    ref.invalidate(offersProvider);
    ref.invalidate(notificationsControllerProvider);
    ref.invalidate(favoritesControllerProvider);

    context.showSnack('Demo data restored.');
  }

  /// Persists the promotional-consent switch and reports failures instead of
  /// silently doing nothing.
  Future<void> _setMarketingOptIn(AppUser user, bool value) async {
    final saved = await ref
        .read(authControllerProvider.notifier)
        .updateProfile(user.copyWith(marketingOptIn: value));

    if (!mounted) return;

    if (!saved) {
      final failure = ref.read(authControllerProvider).error;
      context.showSnack(
        failure?.message ?? 'Could not save your preference. Please try again.',
        isError: true,
      );
      return;
    }

    context.showSnack(
      value
          ? 'You will receive exclusive offers.'
          : 'Promotional messages turned off.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          context.pagePadding,
          AppSpacing.lg,
          context.pagePadding,
          AppSpacing.xxxl,
        ),
        children: [
          _GroupLabel('Notifications'),
          AppCard(
            padding: EdgeInsets.zero,
            child: SwitchListTile(
              value: user?.marketingOptIn ?? false,
              activeColor: AppColors.purple,
              title: const Text('Promotional emails & texts'),
              subtitle: const Text('Exclusive offers and 702FORU updates'),
              onChanged: user == null
                  ? null
                  : (value) => _setMarketingOptIn(user, value),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),
          _GroupLabel('Content'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const AppIconTile(
                    icon: Icons.local_offer_outlined,
                    size: 36,
                  ),
                  title: const Text('Exclusive offers'),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.offers),
                ),
                const Divider(height: 1, indent: 60),
                ListTile(
                  leading: const AppIconTile(
                    icon: Icons.category_outlined,
                    size: 36,
                  ),
                  title: const Text('All categories'),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.allCategories),
                ),
                const Divider(height: 1, indent: 60),
                ListTile(
                  leading: const AppIconTile(
                    icon: Icons.info_outline_rounded,
                    size: 36,
                  ),
                  title: const Text('About 702FORU'),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.about),
                ),
                const Divider(height: 1, indent: 60),
                ListTile(
                  leading:
                      const AppIconTile(icon: Icons.help_outline_rounded, size: 36),
                  title: const Text('How it works'),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.howItWorks),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),
          _GroupLabel('Data'),
          AppCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: const AppIconTile(
                icon: Icons.restart_alt_rounded,
                color: AppColors.warning,
                size: 36,
              ),
              title: const Text('Reset demo data'),
              subtitle: const Text('Restore seeded content and demo accounts'),
              trailing: _isResetting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right, size: 20),
              onTap: _isResetting ? null : _resetDemoData,
            ),
          ),

          const SizedBox(height: AppSpacing.xl),
          if (user != null)
            AppButton(
              label: 'Sign out',
              variant: AppButtonVariant.outline,
              icon: Icons.logout_rounded,
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).signOut();
                if (context.mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  context.showSnack('Signed out.');
                }
              },
            ),

          const SizedBox(height: AppSpacing.xxl),
          Center(
            child: Text(
              '702FORU • v1.0.0 (local preview)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
