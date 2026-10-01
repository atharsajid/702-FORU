import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
import '../../../provider/presentation/providers/provider_providers.dart';
import '../providers/auth_providers.dart';

/// How a provider chooses to be billed.
enum BillingModel { commission, flatFee }

/// Business registration: creates the account *and* the listing.
class SignUpProviderScreen extends ConsumerStatefulWidget {
  const SignUpProviderScreen({super.key});

  @override
  ConsumerState<SignUpProviderScreen> createState() =>
      _SignUpProviderScreenState();
}

class _SignUpProviderScreenState extends ConsumerState<SignUpProviderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ownerName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _businessName = TextEditingController();
  final _address = TextEditingController();
  final _description = TextEditingController();

  String? _categoryId;
  BillingModel _billing = BillingModel.commission;
  bool _acceptedTerms = false;
  bool _showTermsError = false;
  bool _isBusy = false;

  @override
  void dispose() {
    _ownerName.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _businessName.dispose();
    _address.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    context.unfocus();
    final formValid = _formKey.currentState!.validate();

    if (_categoryId == null) {
      context.showSnack('Please choose a category.', isError: true);
      return;
    }
    setState(() => _showTermsError = !_acceptedTerms);
    if (!formValid || !_acceptedTerms) {
      if (!_acceptedTerms) {
        context.showSnack(
          'Please accept the provider agreement to continue.',
          isError: true,
        );
      }
      return;
    }

    setState(() => _isBusy = true);

    final result = await ref.read(registerProviderAccountProvider)(
      fullName: _ownerName.text,
      email: _email.text,
      password: _password.text,
      phone: _phone.text,
      businessName: _businessName.text,
      categoryId: _categoryId!,
      address: _address.text,
      description: _description.text,
      marketingOptIn: true,
    );

    if (!mounted) return;
    setState(() => _isBusy = false);

    result.when(
      success: (registration) {
        // Keep the session in sync with the newly linked listing.
        ref.read(authControllerProvider.notifier).setUser(registration.user);
        ref.invalidate(myBusinessProvider);
        ref.invalidate(myCouponsProvider);
        context.showSnack('Your business is live on 702FORU!');
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
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Business sign up')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: context.pagePadding,
              vertical: AppSpacing.lg,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'List your business',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Your listing follows the same layout as every 702FORU business.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),

                    // ── Business details ──────────────────────────────────
                    const SizedBox(height: AppSpacing.xl),
                    const _FormSectionLabel('Business details'),
                    AppTextField(
                      controller: _businessName,
                      label: 'Business name',
                      prefixIcon: Icons.storefront_outlined,
                      textInputAction: TextInputAction.next,
                      isRequired: true,
                      validator: (value) =>
                          Validators.minLength(value, 2, field: 'Business name'),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // ── Category picker ───────────────────────────────────
                    AsyncValueView<List<Category>>(
                      value: categories,
                      loading: const AppLoading(label: 'Loading categories…'),
                      onRetry: () => ref.invalidate(categoriesProvider),
                      builder: (context, list) => DropdownButtonFormField<String>(
                        value: _categoryId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Category *',
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
                      label: 'Address',
                      hint: '123 Main St, Las Vegas, NV',
                      prefixIcon: Icons.location_on_outlined,
                      textInputAction: TextInputAction.next,
                      isRequired: true,
                      validator: (value) =>
                          Validators.minLength(value, 5, field: 'Address'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _description,
                      label: 'Short description',
                      hint: 'What makes your business special?',
                      maxLines: 3,
                      textInputAction: TextInputAction.newline,
                    ),

                    // ── Account details ───────────────────────────────────
                    const SizedBox(height: AppSpacing.xl),
                    const _FormSectionLabel('Your account'),
                    AppTextField(
                      controller: _ownerName,
                      label: 'Your full name',
                      prefixIcon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.next,
                      isRequired: true,
                      validator: Validators.name,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _email,
                      label: 'Business email',
                      prefixIcon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      isRequired: true,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _phone,
                      label: 'Phone',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      isRequired: true,
                      validator: Validators.phone,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppPasswordField(
                      controller: _password,
                      label: 'Password',
                      isRequired: true,
                      validator: Validators.password,
                    ),

                    // ── Billing model ─────────────────────────────────────
                    const SizedBox(height: AppSpacing.xl),
                    const _FormSectionLabel('How would you like to be billed?'),
                    _BillingOption(
                      title: 'Run payments through 702FORU',
                      description:
                          'We process the sale and take a 12% commission. Coupon usage is tracked with your 702-4U code and billed monthly.',
                      selected: _billing == BillingModel.commission,
                      onTap: () =>
                          setState(() => _billing = BillingModel.commission),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _BillingOption(
                      title: 'Flat monthly service fee',
                      description:
                          'Keep your own payment processing. We charge a flat \$149/month for the listing and coupon tracking.',
                      selected: _billing == BillingModel.flatFee,
                      onTap: () =>
                          setState(() => _billing = BillingModel.flatFee),
                    ),

                    // ── Agreement ─────────────────────────────────────────
                    const SizedBox(height: AppSpacing.lg),
                    AppCard(
                      color: AppColors.purple.withValues(alpha: 0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                height: 26,
                                width: 26,
                                child: Checkbox(
                                  value: _acceptedTerms,
                                  onChanged: (value) => setState(() {
                                    _acceptedTerms = value ?? false;
                                    _showTermsError = false;
                                  }),
                                  activeColor: AppColors.purple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  'I accept the 702FORU provider agreement',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: _showTermsError
                                        ? AppColors.error
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Your business will be reviewed and can be removed at any time. '
                            'Commission is calculated on sales attributed to your 702-4U tracking code.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),
                    AppButton(
                      label: 'Create my listing',
                      size: AppButtonSize.large,
                      icon: Icons.storefront_outlined,
                      isLoading: _isBusy,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Center(
                      child: AppButton(
                        label: 'How it works',
                        variant: AppButtonVariant.ghost,
                        size: AppButtonSize.small,
                        isFullWidth: false,
                        onPressed: () => Navigator.of(context)
                            .pushNamed(AppRoutes.howItWorks),
                      ),
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

class _BillingOption extends StatelessWidget {
  const _BillingOption({
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      border: selected
          ? Border.all(color: AppColors.purple, width: 1.6)
          : Border.all(color: AppColors.greyLight),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            selected
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_off_rounded,
            color: selected ? AppColors.purple : AppColors.grey,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
