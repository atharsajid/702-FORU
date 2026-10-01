import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../catalog/domain/entities/business.dart';
import '../../../catalog/domain/entities/coupon.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../providers/provider_providers.dart';

/// Create and monitor coupons; redemptions drive monthly billing.
class ProviderCouponsScreen extends ConsumerWidget {
  const ProviderCouponsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final business = ref.watch(myBusinessProvider);
    final coupons = ref.watch(myCouponsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Coupons')),
      floatingActionButton: business.valueOrNull == null
          ? null
          : FloatingActionButton.extended(
              backgroundColor: AppColors.purple,
              foregroundColor: AppColors.white,
              onPressed: () =>
                  _openCouponSheet(context, ref, business.valueOrNull!),
              icon: const Icon(Icons.add),
              label: const Text('New coupon'),
            ),
      body: AsyncValueView<List<Coupon>>(
        value: coupons,
        onRetry: () => ref.invalidate(myCouponsProvider),
        builder: (context, list) {
          if (list.isEmpty) {
            return const AppEmptyState(
              title: 'No coupons yet',
              message:
                  'Create your first coupon — each one carries your 702-4U tracking code.',
              icon: Icons.confirmation_number_outlined,
            );
          }

          final totalRedemptions = list.fold<int>(
            0,
            (sum, coupon) => sum + coupon.redemptionCount,
          );

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              context.pagePadding,
              AppSpacing.lg,
              context.pagePadding,
              // Room for the FAB.
              AppSpacing.huge * 2,
            ),
            children: [
              AppCard(
                color: AppColors.navy,
                child: Row(
                  children: [
                    const Icon(Icons.redeem_outlined,
                        color: AppColors.cyan, size: 22),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${AppFormatters.compact(totalRedemptions)} total redemptions',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Across ${list.length} active coupon${list.length == 1 ? '' : 's'}',
                            style: TextStyle(
                              color: AppColors.white.withValues(alpha: 0.75),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              for (final coupon in list) ...[
                _CouponRow(coupon: coupon),
                const SizedBox(height: AppSpacing.md),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _openCouponSheet(
    BuildContext context,
    WidgetRef ref,
    Business business,
  ) async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CouponSheet(business: business),
    );

    if (created == true) {
      ref.invalidate(myCouponsProvider);
      ref.invalidate(providerSummaryProvider);
    }
  }
}

class _CouponRow extends StatelessWidget {
  const _CouponRow({required this.coupon});

  final Coupon coupon;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  coupon.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              AppTag(
                label: coupon.isRedeemable ? 'ACTIVE' : 'EXPIRED',
                color: coupon.isRedeemable
                    ? AppColors.success.withValues(alpha: 0.14)
                    : AppColors.greyLight,
                textColor: coupon.isRedeemable
                    ? AppColors.success
                    : AppColors.greyDark,
                compact: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.purple.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  coupon.code,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    color: AppColors.purple,
                    fontSize: 13,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.redeem_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${AppFormatters.compact(coupon.redemptionCount)} used',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          if (coupon.discountPercent > 0) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${coupon.discountPercent.toStringAsFixed(0)}% off',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.purple,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Bottom sheet for creating a new coupon.
class _CouponSheet extends ConsumerStatefulWidget {
  const _CouponSheet({required this.business});

  final Business business;

  @override
  ConsumerState<_CouponSheet> createState() => _CouponSheetState();
}

class _CouponSheetState extends ConsumerState<_CouponSheet> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _code = TextEditingController();
  final _description = TextEditingController();
  final _discount = TextEditingController(text: '10');
  int _validDays = 30;
  bool _isBusy = false;

  @override
  void dispose() {
    _title.dispose();
    _code.dispose();
    _description.dispose();
    _discount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    context.unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isBusy = true);

    final suffix = widget.business.trackingCode.isEmpty
        ? '4U'
        : widget.business.trackingCode.split('-').last;

    final coupon = Coupon(
      id: 'c-${DateTime.now().microsecondsSinceEpoch}',
      businessId: widget.business.id,
      title: _title.text.trim(),
      code: _code.text.trim().toUpperCase(),
      description: _description.text.trim(),
      discountPercent: double.tryParse(_discount.text.trim()) ?? 0,
      expiresAt: DateTime.now().add(Duration(days: _validDays)),
      redemptionCount: 0,
    );

    final result = await ref.read(saveCouponProvider)(coupon);

    if (!mounted) return;
    setState(() => _isBusy = false);

    result.when(
      success: (_) {
        context.showSnack('Coupon created. Code: ${coupon.code} ($suffix)');
        Navigator.of(context).pop(true);
      },
      failure: (failure) =>
          context.showSnack(failure.message, isError: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.xl,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 42,
                  decoration: BoxDecoration(
                    color: AppColors.greyLight,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'New coupon',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Tracked under ${widget.business.trackingCode}.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _title,
                label: 'Offer title',
                hint: '20% off large pizzas',
                isRequired: true,
                validator: (value) =>
                    Validators.minLength(value, 3, field: 'Title'),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _code,
                label: 'Coupon code',
                hint: 'PIZZA20',
                isRequired: true,
                validator: (value) =>
                    Validators.minLength(value, 3, field: 'Code'),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _description,
                label: 'Short description (optional)',
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _discount,
                label: 'Discount % (0 for a freebie)',
                keyboardType: TextInputType.number,
                validator: (value) {
                  final parsed = double.tryParse(value?.trim() ?? '');
                  if (parsed == null) return 'Enter a number';
                  if (parsed < 0 || parsed > 100) return '0–100 only';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<int>(
                value: _validDays,
                decoration: const InputDecoration(labelText: 'Valid for'),
                items: const [
                  DropdownMenuItem(value: 7, child: Text('7 days')),
                  DropdownMenuItem(value: 30, child: Text('30 days')),
                  DropdownMenuItem(value: 90, child: Text('90 days')),
                ],
                onChanged: (value) =>
                    setState(() => _validDays = value ?? 30),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'Create coupon',
                isLoading: _isBusy,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
