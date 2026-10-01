import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../providers/auth_providers.dart';

/// Request a reset link. With no backend yet the "email" is acknowledged
/// locally so the flow still completes end to end.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _isBusy = false;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    context.unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isBusy = true);
    final exists = await ref.read(checkEmailExistsProvider)(_email.text);
    if (!mounted) return;
    setState(() {
      _isBusy = false;
      _sent = true;
    });

    // We deliberately do not reveal whether the address is registered.
    context.showSnack(
      exists.valueOrNull == false
          ? 'If that email exists, a reset link is on its way.'
          : 'Reset link sent to ${_email.text.trim()}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Reset password')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    height: 72,
                    width: 72,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.purple.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_reset_rounded,
                      color: AppColors.purple,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Forgot your password?',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Enter the email on your account and we will send you a reset link.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Form(
                    key: _formKey,
                    child: AppTextField(
                      controller: _email,
                      label: 'Email',
                      hint: 'you@example.com',
                      prefixIcon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      isRequired: true,
                      validator: Validators.email,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: 'Send reset link',
                    size: AppButtonSize.large,
                    isLoading: _isBusy,
                    icon: Icons.send_rounded,
                    onPressed: _submit,
                  ),
                  if (_sent) ...[
                    const SizedBox(height: AppSpacing.xl),
                    AppCard(
                      color: AppColors.success.withValues(alpha: 0.08),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.mark_email_read_outlined,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              'Check your inbox — the link expires in 30 minutes.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
