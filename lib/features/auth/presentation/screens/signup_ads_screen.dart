import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/pricing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../providers/business_signup_draft.dart';
import '../widgets/signup_step_header.dart';

/// Business signup step 3 — optional advertising placements.
class SignupAdsScreen extends ConsumerWidget {
  const SignupAdsScreen({super.key});

  void _continue(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.signUpProviderEnrollment);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(businessSignupDraftProvider);
    final controller = ref.read(businessSignupDraftProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Advertising')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: context.pagePadding,
              vertical: AppSpacing.lg,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SignupStepHeader(
                    step: 3,
                    total: 4,
                    title: 'Add more visibility',
                    subtitle:
                        'Optional. Select any placements you are interested in '
                        'and we will confirm pricing before anything is '
                        'charged.',
                    stepLabels: [
                      'Plan',
                      'Business',
                      'Advertising',
                      'Agreement',
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  for (final product in advertisingProducts) ...[
                    _AddOnCard(
                      product: product,
                      selected: draft.advertisingAddOns.contains(product.id),
                      onTap: () => controller.toggleAddOn(product.id),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.request_quote_outlined,
                            size: 18, color: AppColors.warning),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Advertising pricing is pending final '
                            'confirmation. Selecting a placement sends a quote '
                            'request — it is not added to your bill yet.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: draft.advertisingAddOns.isEmpty
                        ? 'Continue without ads'
                        : 'Continue with '
                            '${draft.advertisingAddOns.length} '
                            'placement${draft.advertisingAddOns.length == 1 ? '' : 's'}',
                    size: AppButtonSize.large,
                    trailingIcon: Icons.arrow_forward_rounded,
                    onPressed: () => _continue(context),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    label: 'Skip for now',
                    variant: AppButtonVariant.ghost,
                    size: AppButtonSize.small,
                    onPressed: () => _continue(context),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'You can add or remove placements later from your '
                    'provider dashboard.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddOnCard extends StatelessWidget {
  const _AddOnCard({
    required this.product,
    required this.selected,
    required this.onTap,
  });

  final AdvertisingProduct product;
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
          Checkbox(
            value: selected,
            onChanged: (_) => onTap(),
            activeColor: AppColors.purple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(product.icon, size: 18, color: AppColors.purple),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  product.tagline,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  product.priceLabel,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.purple,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
