import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signature/signature.dart';

import '../../../../core/config/pricing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../provider/presentation/providers/provider_providers.dart';
import '../providers/auth_providers.dart';
import '../providers/business_signup_draft.dart';
import '../widgets/signup_step_header.dart';

/// Business signup step 4 — the enrollment agreement from
/// `702ForU_Pricing.docx`, followed by listing activation.
class SignupEnrollmentScreen extends ConsumerStatefulWidget {
  const SignupEnrollmentScreen({super.key});

  @override
  ConsumerState<SignupEnrollmentScreen> createState() =>
      _SignupEnrollmentScreenState();
}

class _SignupEnrollmentScreenState
    extends ConsumerState<SignupEnrollmentScreen> {
  late final SignatureController _signaturePad;
  late final TextEditingController _title;
  final DateTime _today = DateTime.now();

  final List<bool> _acknowledged = List<bool>.filled(4, false);
  bool _isBusy = false;
  bool _hasSignature = false;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(businessSignupDraftProvider);
    _title = TextEditingController(text: draft.contactTitle);
    _signaturePad = SignatureController(
      penColor: Colors.black,
      penStrokeWidth: 2.6,
      strokeCap: StrokeCap.round,
      strokeJoin: StrokeJoin.round,
    )..addListener(_syncSignatureState);
  }

  @override
  void dispose() {
    _signaturePad
      ..removeListener(_syncSignatureState)
      ..dispose();
    _title.dispose();
    super.dispose();
  }

  bool get _allAcknowledged => _acknowledged.every((value) => value);

  /// The pad notifies on every point; only rebuild when the empty/filled
  /// state actually changes.
  void _syncSignatureState() {
    final hasSignature = _signaturePad.isNotEmpty;
    if (hasSignature == _hasSignature || !mounted) return;
    setState(() => _hasSignature = hasSignature);
  }

  Future<void> _activate() async {
    final draft = ref.read(businessSignupDraftProvider);
    if (!draft.hasBusinessInfo) {
      context.showSnack(
        'Please complete your business information first.',
        isError: true,
      );
      return;
    }
    if (!_allAcknowledged) {
      context.showSnack(
        'Please tick all four acknowledgments to continue.',
        isError: true,
      );
      return;
    }
    if (_signaturePad.isEmpty) {
      context.showSnack('Please sign the enrollment form.', isError: true);
      return;
    }

    context.unfocus();
    setState(() => _isBusy = true);

    final result = await ref.read(registerProviderAccountProvider)(
      fullName: draft.contactName,
      email: draft.email,
      password: draft.password,
      phone: draft.phone,
      businessName: draft.businessName,
      categoryId: draft.categoryId!,
      address: draft.address,
      description: draft.description,
      legalName: draft.legalName,
      hours: draft.hours,
      serviceArea: draft.serviceArea,
      website: draft.website,
      advertisingAddOns: draft.advertisingAddOns.toList(growable: false),
      marketingOptIn: true,
    );

    if (!mounted) return;
    setState(() => _isBusy = false);

    result.when(
      success: (registration) {
        ref.read(authControllerProvider.notifier).setUser(registration.user);
        ref.read(businessSignupDraftProvider.notifier).reset();
        ref.invalidate(myBusinessProvider);
        ref.invalidate(myCouponsProvider);
        ref.invalidate(providerSummaryProvider);
        context.showSnack('Your listing is active — welcome to 702FORU!');
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.providerDashboard,
          (route) => route.isFirst,
        );
      },
      failure: (failure) =>
          context.showSnack(failure.message, isError: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(businessSignupDraftProvider);
    final trialEnd = BusinessListingPricing.trialEndFrom(_today);
    final addOns = advertisingProducts
        .where((product) => draft.advertisingAddOns.contains(product.id))
        .toList(growable: false);

    if (!draft.hasBusinessInfo) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Enrollment')),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(context.pagePadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.assignment_outlined,
                    size: 44, color: AppColors.purple),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Your business information is missing',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Go back and complete the business information step before '
                  'signing the enrollment form.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Enter business information',
                  onPressed: () => Navigator.of(context)
                      .pushReplacementNamed(AppRoutes.signUpProviderBusiness),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Enrollment')),
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
                    step: 4,
                    total: 4,
                    title: 'Review and sign',
                    subtitle:
                        'This is the enrollment form for the Basic Listing. '
                        'Nothing is charged today.',
                    stepLabels: [
                      'Plan',
                      'Business',
                      'Advertising',
                      'Agreement',
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Summary ─────────────────────────────────────────
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const AppIconTile(
                              icon: Icons.storefront_outlined,
                              size: 40,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    draft.businessName,
                                    style:
                                        Theme.of(context).textTheme.headlineSmall,
                                  ),
                                  Text(
                                    BusinessListingPricing.planName,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: AppSpacing.xl),
                        _SummaryRow(
                          label: 'Trial starts',
                          value: AppFormatters.date(_today),
                        ),
                        _SummaryRow(
                          label: 'Trial ends',
                          value: AppFormatters.date(trialEnd),
                        ),
                        _SummaryRow(
                          label: 'After the trial',
                          value: BusinessListingPricing.monthlyLabel,
                        ),
                        _SummaryRow(
                          label: 'Today',
                          value: r'$0.00',
                        ),
                        if (addOns.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Requested placements (quoted separately)',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.xs,
                            children: [
                              for (final product in addOns)
                                AppTag(
                                  label: product.name,
                                  icon: Icons.campaign_outlined,
                                  iconColor: AppColors.purple,
                                  bordered: true,
                                  compact: true,
                                ),
                            ],
                          ),
                        ],
                        const SizedBox(height: AppSpacing.md),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            'Final pricing is subject to confirmation. The '
                            'figures above follow the current enrollment form.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Terms ───────────────────────────────────────────
                  const _SectionLabel('Free trial & monthly billing'),
                  Text(
                    'The Basic Listing is free for ${BusinessListingPricing.trialDays} '
                    'days beginning on the date 702FORU activates the listing. '
                    'Unless cancelled before the trial ends, the listing '
                    'converts to ${BusinessListingPricing.monthlyLabel} plus any '
                    'applicable taxes, billed in advance and recurring monthly '
                    'until cancelled. You may cancel at any time using the '
                    'cancellation method supplied by 702FORU or by contacting '
                    'the billing contact in your enrollment confirmation. '
                    'Cancellation stops future renewals; any already-paid '
                    'period is not refunded except as required by law.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.credit_card_outlined,
                            size: 18, color: AppColors.info),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'A valid payment method is required to start the '
                            'free trial. Payment details are entered through '
                            "702FORU's secure checkout — never by email or "
                            'text. Secure checkout is being connected for '
                            'launch; no card is charged in this build.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),
                  const _SectionLabel('Business responsibilities'),
                  Text(
                    'You confirm you are authorized to enroll the business and '
                    'that the information, images, logos, offers and links you '
                    'provide are accurate and that you have permission to use '
                    'them. You grant 702FORU permission to display and format '
                    'the submitted business information within 702FORU for '
                    'listing and promotional purposes while your listing is '
                    'active. You are responsible for your products, services, '
                    'prices, licenses, customer service and any payments made '
                    'directly to you. 702FORU does not collect customer '
                    'payments or sales commissions under this listing plan. '
                    '702FORU may correct formatting, reject misleading or '
                    'unlawful content, or suspend a listing for material '
                    'policy violations. Listing placement and visibility are '
                    'not guaranteed.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: AppSpacing.xl),
                  const _SectionLabel('Required acknowledgments'),
                  _Acknowledgement(
                    value: _acknowledged[0],
                    onChanged: (value) =>
                        setState(() => _acknowledged[0] = value),
                    text:
                        'I understand the listing is free for ${BusinessListingPricing.trialDays} '
                        'days and then costs ${BusinessListingPricing.monthlyLabel} '
                        'unless I cancel before the trial ends.',
                  ),
                  _Acknowledgement(
                    value: _acknowledged[1],
                    onChanged: (value) =>
                        setState(() => _acknowledged[1] = value),
                    text:
                        'I authorize recurring monthly charges to the payment '
                        'method I enter through the secure checkout.',
                  ),
                  _Acknowledgement(
                    value: _acknowledged[2],
                    onChanged: (value) =>
                        setState(() => _acknowledged[2] = value),
                    text:
                        'I understand premium advertising and Spotlight '
                        'placements are not included in the Basic Listing.',
                  ),
                  _Acknowledgement(
                    value: _acknowledged[3],
                    onChanged: (value) =>
                        setState(() => _acknowledged[3] = value),
                    text: 'I have read and agree to the terms on this '
                        'enrollment form.',
                  ),

                  const SizedBox(height: AppSpacing.xl),
                  const _SectionLabel('Signature'),
                  Text(
                    draft.contactName.isEmpty
                        ? 'Authorized representative'
                        : 'Authorized representative: ${draft.contactName}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _title,
                    label: 'Title',
                    hint: 'Owner, manager, …',
                    prefixIcon: Icons.work_outline_rounded,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ── Signature pad ────────────────────────────────
                  Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: _hasSignature
                            ? AppColors.purple
                            : AppColors.greyLight,
                        width: _hasSignature ? 1.4 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            AppSpacing.xs,
                            AppSpacing.sm,
                            0,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _hasSignature
                                    ? Icons.check_circle_outline_rounded
                                    : Icons.edit_outlined,
                                size: 15,
                                color: _hasSignature
                                    ? AppColors.success
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  _hasSignature
                                      ? 'Signature added'
                                      : 'Sign in the box below',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: _hasSignature
                                        ? AppColors.success
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              TextButton.icon(
                                onPressed:
                                    _hasSignature ? _signaturePad.clear : null,
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.purple,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                  ),
                                  minimumSize: const Size(0, 34),
                                ),
                                icon: const Icon(Icons.refresh_rounded,
                                    size: 16),
                                label: const Text('Clear'),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 170,
                          width: double.infinity,
                          child: Signature(
                            controller: _signaturePad,
                            backgroundColor: AppColors.white,
                            placeholder: Center(
                              child: Text(
                                'Sign here',
                                style: TextStyle(
                                  color: AppColors.grey.withValues(alpha: 0.7),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.greyLight),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event_outlined,
                            size: 18, color: AppColors.purple),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Date signed: ${AppFormatters.date(_today)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: 'Activate my listing',
                    icon: Icons.check_circle_outline_rounded,
                    size: AppButtonSize.large,
                    isLoading: _isBusy,
                    enabled: _allAcknowledged && _hasSignature && !_isBusy,
                    onPressed: _activate,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Activation starts your ${BusinessListingPricing.trialDays}-day '
                    'trial. You can cancel any time before it ends.',
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

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
          color: AppColors.purple,
        ),
      ),
    );
  }
}

class _Acknowledgement extends StatelessWidget {
  const _Acknowledgement({
    required this.value,
    required this.onChanged,
    required this.text,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String text;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 26,
              width: 26,
              child: Checkbox(
                value: value,
                onChanged: (next) => onChanged(next ?? false),
                activeColor: AppColors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 12.5, height: 1.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
