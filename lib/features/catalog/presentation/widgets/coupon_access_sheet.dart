import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/pricing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/coupon_quota_providers.dart';

/// Shown to a signed-out visitor who taps Redeem.
Future<void> showGuestCouponSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const Center(
            child: AppIconTile(
              icon: Icons.confirmation_number_outlined,
              size: 56,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Your first ${ConsumerCouponPricing.freeCoupons} coupons are free',
            textAlign: TextAlign.center,
            style: Theme.of(sheetContext).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Create a free 702FORU account to unlock '
            '${ConsumerCouponPricing.freeCoupons} coupons, save favourites and '
            'leave reviews. No card required.',
            textAlign: TextAlign.center,
            style: Theme.of(sheetContext).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: 'Create a free account',
            icon: Icons.person_add_alt_1_rounded,
            onPressed: () {
              Navigator.of(sheetContext).pop();
              Navigator.of(context).pushNamed(AppRoutes.signUpUser);
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'I already have an account',
            variant: AppButtonVariant.ghost,
            onPressed: () {
              Navigator.of(sheetContext).pop();
              Navigator.of(context).pushNamed(AppRoutes.login);
            },
          ),
        ],
      ),
    ),
  );
}

/// Shown when a free account has used all of its included coupons.
Future<void> showCouponUpgradeSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (_) => const _CouponUpgradeSheet(),
  );
}

class _CouponUpgradeSheet extends ConsumerStatefulWidget {
  const _CouponUpgradeSheet();

  @override
  ConsumerState<_CouponUpgradeSheet> createState() =>
      _CouponUpgradeSheetState();
}

class _CouponUpgradeSheetState extends ConsumerState<_CouponUpgradeSheet> {
  CouponPassType _selected = CouponPassType.monthly;
  bool _isBusy = false;

  Future<void> _activate() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _isBusy = true);

    await ref.read(couponQuotaProvider.notifier).purchasePass(_selected);

    if (!mounted) return;
    setState(() => _isBusy = false);
    navigator.pop();
    messenger.showSnackBar(
      SnackBar(content: Text('${_selected.label} activated. Enjoy your coupons!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quota = ref.watch(couponQuotaProvider).valueOrNull;
    final used = quota?.used ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const Center(
            child: AppIconTile(icon: Icons.workspace_premium_outlined, size: 56),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'You have used all ${ConsumerCouponPricing.freeCoupons} free coupons',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Keep saving on Vegas. Pick the option that suits you — '
            '${AppFormatters.compact(used)} coupons redeemed so far.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xl),
          for (final type in CouponPassType.values) ...[
            _PassOption(
              type: type,
              selected: _selected == type,
              onTap: () => setState(() => _selected = type),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Activate ${_selected.label}',
            icon: Icons.lock_open_rounded,
            size: AppButtonSize.large,
            isLoading: _isBusy,
            onPressed: _isBusy ? null : _activate,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Demo checkout — no card is charged in this build. '
            'Secure payment will be connected before launch.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _PassOption extends StatelessWidget {
  const _PassOption({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final CouponPassType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      border: Border.all(
        color: selected ? AppColors.purple : AppColors.greyLight,
        width: selected ? 1.6 : 1,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            selected
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_off_rounded,
            size: 20,
            color: selected ? AppColors.purple : AppColors.grey,
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
                        type.label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      type.priceLabel,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(type.detail, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact coupon balance shown above a business's coupon list.
class CouponAllowanceBar extends ConsumerWidget {
  const CouponAllowanceBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    if (!isAuthenticated) {
      return AppCard(
        color: AppColors.purple.withValues(alpha: 0.06),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            const Icon(Icons.card_giftcard_rounded,
                size: 18, color: AppColors.purple),
            const SizedBox(width: AppSpacing.sm),
            const Expanded(
              child: Text(
                'Free account: 10 coupons included',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.signUpUser),
              child: const Text('Sign up'),
            ),
          ],
        ),
      );
    }

    final quota = ref.watch(couponQuotaProvider).valueOrNull;
    if (quota == null) return const SizedBox.shrink();

    if (quota.hasUnlimited) {
      return AppCard(
        color: AppColors.purple.withValues(alpha: 0.06),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            const Icon(Icons.workspace_premium_rounded,
                size: 18, color: AppColors.purple),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                quota.unlimitedUntil == null
                    ? 'Unlimited coupons active'
                    : 'Unlimited coupons until '
                        '${AppFormatters.date(quota.unlimitedUntil!)}',
                style:
                    const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    final total = quota.totalCredits;
    final used = (quota.used).clamp(0, total);
    final left = quota.remaining;
    final balanceLabel = quota.bonusCredits > 0
        ? '$left coupon${left == 1 ? '' : 's'} left'
        : '$left of $total free coupons left';

    return AppCard(
      color: left == 0
          ? AppColors.gold.withValues(alpha: 0.12)
          : AppColors.surfaceMuted,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                left == 0
                    ? Icons.lock_outline_rounded
                    : Icons.confirmation_number_outlined,
                size: 18,
                color: left == 0 ? AppColors.warning : AppColors.purple,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  left == 0 ? 'All free coupons used' : balanceLabel,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (left == 0)
                TextButton(
                  onPressed: () => showCouponUpgradeSheet(context),
                  child: const Text('Get more'),
                ),
            ],
          ),
          if (left > 0) ...[
            const SizedBox(height: AppSpacing.xs),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : used / total,
                minHeight: 5,
                backgroundColor: AppColors.greyLight,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.purple),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
