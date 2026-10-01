import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/storage/local_seed.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../providers/auth_providers.dart';

/// Email / password sign in with social options and demo shortcuts.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isBusy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    context.unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isBusy = true);
    final ok = await ref.read(authControllerProvider.notifier).signIn(
          email: _email.text,
          password: _password.text,
        );
    if (!mounted) return;
    setState(() => _isBusy = false);

    if (ok) {
      context.showSnack('Welcome back!');
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      final error = ref.read(authControllerProvider).error;
      context.showSnack(error?.message ?? 'Sign in failed', isError: true);
    }
  }

  void _useDemo({
    required String email,
    required String password,
  }) {
    setState(() {
      _email.text = email;
      _password.text = password;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Sign In')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.pagePadding,
                  vertical: AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(child: Image.asset('assets/logo.png', height: 84)),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Welcome back',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Sign in to save favourites, redeem coupons and leave reviews.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
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
                          AppPasswordField(
                            controller: _password,
                            label: 'Password',
                            isRequired: true,
                            autofillHints: const [AutofillHints.password],
                            validator: Validators.password,
                            onSubmitted: (_) => _submit(),
                          ),
                        ],
                      ),
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.of(context)
                            .pushNamed(AppRoutes.forgotPassword),
                        child: const Text('Forgot password?'),
                      ),
                    ),

                    AppButton(
                      label: 'Sign In',
                      size: AppButtonSize.large,
                      isLoading: _isBusy,
                      onPressed: _submit,
                    ),

                    const SizedBox(height: AppSpacing.xl),
                    const AppOrDivider(),
                    const SizedBox(height: AppSpacing.lg),

                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'Google',
                            icon: Icons.g_mobiledata_rounded,
                            variant: AppButtonVariant.outline,
                            onPressed: () => context.showSnack(
                              'Google sign-in arrives with the backend.',
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: AppButton(
                            label: 'Facebook',
                            icon: Icons.facebook_outlined,
                            variant: AppButtonVariant.outline,
                            onPressed: () => context.showSnack(
                              'Facebook sign-in arrives with the backend.',
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // ── Demo accounts (local-only build) ────────────────
                    AppCard(
                      color: AppColors.purple.withValues(alpha: 0.06),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppTag(
                            label: 'DEMO ACCOUNTS',
                            color: AppColors.purple,
                            textColor: AppColors.white,
                            compact: true,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'No backend yet — tap a demo account to sign in instantly.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _DemoButton(
                            label: 'Visitor',
                            email: LocalSeed.demoUserEmail,
                            onTap: () => _useDemo(
                              email: LocalSeed.demoUserEmail,
                              password: LocalSeed.demoUserPassword,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          _DemoButton(
                            label: 'Business provider',
                            email: LocalSeed.demoProviderEmail,
                            onTap: () => _useDemo(
                              email: LocalSeed.demoProviderEmail,
                              password: LocalSeed.demoProviderPassword,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Haven't an account? ",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context)
                              .pushNamed(AppRoutes.signUpRole),
                          child: const Text(
                            'Sign up now',
                            style: TextStyle(
                              color: AppColors.purple,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.sm),
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

class _DemoButton extends StatelessWidget {
  const _DemoButton({
    required this.label,
    required this.email,
    required this.onTap,
  });

  final String label;
  final String email;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            const Icon(Icons.bolt_rounded, size: 18, color: AppColors.purple),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.grey),
          ],
        ),
      ),
    );
  }
}
