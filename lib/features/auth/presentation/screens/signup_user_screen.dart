import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../providers/auth_providers.dart';

/// Visitor registration.
class SignUpUserScreen extends ConsumerStatefulWidget {
  const SignUpUserScreen({super.key});

  @override
  ConsumerState<SignUpUserScreen> createState() => _SignUpUserScreenState();
}

class _SignUpUserScreenState extends ConsumerState<SignUpUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _marketingOptIn = false;
  bool _acceptedTerms = false;
  bool _showTermsError = false;
  bool _isBusy = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    context.unfocus();
    final formValid = _formKey.currentState!.validate();
    setState(() => _showTermsError = !_acceptedTerms);
    if (!formValid || !_acceptedTerms) {
      if (!_acceptedTerms) {
        context.showSnack('Please accept the terms to continue.', isError: true);
      }
      return;
    }

    setState(() => _isBusy = true);
    final ok = await ref.read(authControllerProvider.notifier).signUp(
          SignUpParams(
            fullName: _name.text,
            email: _email.text,
            password: _password.text,
            phone: _phone.text,
            role: UserRole.user,
            marketingOptIn: _marketingOptIn,
          ),
        );
    if (!mounted) return;
    setState(() => _isBusy = false);

    if (ok) {
      context.showSnack('Welcome to 702FORU!');
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      final error = ref.read(authControllerProvider).error;
      context.showSnack(error?.message ?? 'Sign up failed', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Visitor sign up')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: context.pagePadding,
              vertical: AppSpacing.lg,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Create your account',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Free forever. No card required.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    AppTextField(
                      controller: _name,
                      label: 'Full name',
                      prefixIcon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.next,
                      isRequired: true,
                      autofillHints: const [AutofillHints.name],
                      validator: Validators.name,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _email,
                      label: 'Email',
                      hint: 'you@example.com',
                      prefixIcon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      isRequired: true,
                      autofillHints: const [AutofillHints.email],
                      validator: Validators.email,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _phone,
                      label: 'Phone (optional)',
                      hint: '+1 702 000 0000',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      validator: Validators.optionalPhone,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppPasswordField(
                      controller: _password,
                      label: 'Password',
                      textInputAction: TextInputAction.next,
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

                    const SizedBox(height: AppSpacing.lg),

                    _ConsentTile(
                      value: _marketingOptIn,
                      onChanged: (value) =>
                          setState(() => _marketingOptIn = value),
                      title: 'Send me promotional emails & texts',
                      subtitle:
                          'Exclusive 702FORU offers and event updates. Optional.',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _ConsentTile(
                      value: _acceptedTerms,
                      showError: _showTermsError,
                      onChanged: (value) =>
                          setState(() => _acceptedTerms = value),
                      title: 'I agree to the Terms & Conditions',
                      subtitle:
                          'You must accept the terms to create an account.',
                    ),

                    const SizedBox(height: AppSpacing.xl),
                    AppButton(
                      label: 'Create account',
                      size: AppButtonSize.large,
                      isLoading: _isBusy,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context)
                              .pushNamed(AppRoutes.login),
                          child: const Text(
                            'Sign in',
                            style: TextStyle(
                              color: AppColors.purple,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
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

/// Checkbox row used for marketing opt-in and terms acceptance.
class _ConsentTile extends StatelessWidget {
  const _ConsentTile({
    required this.value,
    required this.onChanged,
    required this.title,
    required this.subtitle,
    this.showError = false,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String title;
  final String subtitle;
  final bool showError;

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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                activeColor: AppColors.purple,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: showError ? AppColors.error : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
