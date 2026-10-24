import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/pricing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../catalog/domain/entities/category.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../providers/business_signup_draft.dart';
import '../widgets/signup_step_header.dart';

/// Business signup step 2 — the business information from the enrollment form.
class SignUpProviderScreen extends ConsumerStatefulWidget {
  const SignUpProviderScreen({super.key});

  @override
  ConsumerState<SignUpProviderScreen> createState() =>
      _SignUpProviderScreenState();
}

class _SignUpProviderScreenState extends ConsumerState<SignUpProviderScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _legalName;
  late final TextEditingController _businessName;
  late final TextEditingController _contactName;
  late final TextEditingController _contactTitle;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _website;
  late final TextEditingController _address;
  late final TextEditingController _serviceArea;
  late final TextEditingController _hours;
  late final TextEditingController _description;
  late final TextEditingController _password;
  late final TextEditingController _confirm;

  String? _categoryId;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(businessSignupDraftProvider);
    _legalName = TextEditingController(text: draft.legalName);
    _businessName = TextEditingController(text: draft.businessName);
    _contactName = TextEditingController(text: draft.contactName);
    _contactTitle = TextEditingController(text: draft.contactTitle);
    _email = TextEditingController(text: draft.email);
    _phone = TextEditingController(text: draft.phone);
    _website = TextEditingController(text: draft.website);
    _address = TextEditingController(text: draft.address);
    _serviceArea = TextEditingController(text: draft.serviceArea);
    _hours = TextEditingController(text: draft.hours);
    _description = TextEditingController(text: draft.description);
    _password = TextEditingController(text: draft.password);
    _confirm = TextEditingController(text: draft.password);
    _categoryId = draft.categoryId;
  }

  @override
  void dispose() {
    for (final controller in [
      _legalName,
      _businessName,
      _contactName,
      _contactTitle,
      _email,
      _phone,
      _website,
      _address,
      _serviceArea,
      _hours,
      _description,
      _password,
      _confirm,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _continue() {
    context.unfocus();
    final valid = _formKey.currentState!.validate();
    if (_categoryId == null) {
      context.showSnack('Please choose a category.', isError: true);
      return;
    }
    if (!valid) return;

    final draft = ref.read(businessSignupDraftProvider).copyWith(
          legalName: _legalName.text.trim(),
          businessName: _businessName.text.trim(),
          contactName: _contactName.text.trim(),
          contactTitle: _contactTitle.text.trim(),
          email: _email.text.trim(),
          phone: _phone.text.trim(),
          website: _website.text.trim(),
          address: _address.text.trim(),
          serviceArea: _serviceArea.text.trim(),
          hours: _hours.text.trim(),
          description: _description.text.trim(),
          password: _password.text,
          categoryId: _categoryId,
        );
    ref.read(businessSignupDraftProvider.notifier).saveBusinessInfo(draft);
    Navigator.of(context).pushNamed(AppRoutes.signUpProviderAds);
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Business information')),
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SignupStepHeader(
                      step: 2,
                      total: 4,
                      title: 'Tell us about your business',
                      subtitle:
                          'This is what customers will see on your listing. '
                          'You can edit it later from your dashboard.',
                      stepLabels: [
                        'Plan',
                        'Business',
                        'Advertising',
                        'Agreement',
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    AppCard(
                      color: AppColors.purple.withValues(alpha: 0.05),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.storefront_outlined,
                              size: 18, color: AppColors.purple),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              '${BusinessListingPricing.planName} · '
                              '${BusinessListingPricing.summary}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Business details ────────────────────────────────
                    const SizedBox(height: AppSpacing.xl),
                    const _FormSectionLabel('Business details'),
                    AppTextField(
                      controller: _legalName,
                      label: 'Legal business name',
                      prefixIcon: Icons.badge_outlined,
                      textInputAction: TextInputAction.next,
                      isRequired: true,
                      validator: (value) => Validators.minLength(
                        value,
                        2,
                        field: 'Legal business name',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _businessName,
                      label: 'Public business name',
                      hint: 'The name customers will see',
                      prefixIcon: Icons.storefront_outlined,
                      textInputAction: TextInputAction.next,
                      isRequired: true,
                      validator: (value) => Validators.minLength(
                        value,
                        2,
                        field: 'Public business name',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AsyncValueView<List<Category>>(
                      value: categories,
                      loading: const AppLoading(label: 'Loading categories…'),
                      onRetry: () => ref.invalidate(categoriesProvider),
                      builder: (context, list) => DropdownButtonFormField<String>(
                        initialValue: _categoryId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Business category *',
                          prefixIcon: Icon(Icons.category_outlined, size: 20),
                        ),
                        hint: const Text('Choose a category'),
                        items: [
                          for (final category in list)
                            DropdownMenuItem(
                              value: category.id,
                              child: Text(
                                category.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: (value) =>
                            setState(() => _categoryId = value),
                        validator: (value) => value == null
                            ? 'Please choose a category'
                            : null,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _address,
                      label: 'Business address',
                      hint: '123 Main St, Las Vegas, NV',
                      prefixIcon: Icons.location_on_outlined,
                      textInputAction: TextInputAction.next,
                      isRequired: true,
                      validator: (value) =>
                          Validators.minLength(value, 5, field: 'Address'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _serviceArea,
                      label: 'Listing location / service area',
                      hint: 'e.g. Summerlin and the west valley',
                      prefixIcon: Icons.map_outlined,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _hours,
                      label: 'Hours of operation',
                      hint: 'Mon–Fri 9am–6pm',
                      prefixIcon: Icons.schedule_outlined,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _description,
                      label: 'Short business description',
                      hint: 'What makes your business special?',
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _website,
                      label: 'Website / social media URL',
                      hint: 'https://…',
                      prefixIcon: Icons.language_outlined,
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.next,
                    ),

                    // ── Contact ─────────────────────────────────────────
                    const SizedBox(height: AppSpacing.xl),
                    const _FormSectionLabel('Authorized contact'),
                    AppTextField(
                      controller: _contactName,
                      label: 'Contact name',
                      prefixIcon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.next,
                      isRequired: true,
                      validator: Validators.name,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _contactTitle,
                      label: 'Title',
                      hint: 'Owner, manager, …',
                      prefixIcon: Icons.work_outline_rounded,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _phone,
                      label: 'Business phone',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      isRequired: true,
                      validator: Validators.phone,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _email,
                      label: 'Email address',
                      hint: 'you@business.com',
                      prefixIcon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      isRequired: true,
                      validator: Validators.email,
                    ),

                    // ── Account ─────────────────────────────────────────
                    const SizedBox(height: AppSpacing.xl),
                    const _FormSectionLabel('Your account'),
                    AppPasswordField(
                      controller: _password,
                      label: 'Password',
                      isRequired: true,
                      validator: Validators.password,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppPasswordField(
                      controller: _confirm,
                      label: 'Confirm password',
                      isRequired: true,
                      validator: (value) =>
                          Validators.confirmPassword(value, _password.text),
                    ),

                    const SizedBox(height: AppSpacing.xl),
                    AppButton(
                      label: 'Continue to advertising',
                      size: AppButtonSize.large,
                      trailingIcon: Icons.arrow_forward_rounded,
                      onPressed: _continue,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppButton(
                      label: 'Back to plan',
                      variant: AppButtonVariant.ghost,
                      size: AppButtonSize.small,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FormSectionLabel extends StatelessWidget {
  const _FormSectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
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
