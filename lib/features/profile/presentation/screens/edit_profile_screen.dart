import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Profile editor for visitors and providers.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _avatarUrl;
  bool _marketingOptIn = false;
  bool _isBusy = false;
  bool _initialised = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _phone = TextEditingController();
    _avatarUrl = TextEditingController();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _avatarUrl.dispose();
    super.dispose();
  }

  /// Seed the controllers from the current user once, without rebuilding.
  void _hydrate() {
    if (_initialised) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    _name.text = user.fullName;
    _phone.text = user.phone;
    _avatarUrl.text = user.avatarUrl ?? '';
    _marketingOptIn = user.marketingOptIn;
    _initialised = true;
  }

  Future<void> _save() async {
    context.unfocus();
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isBusy = true);
    final ok = await ref.read(authControllerProvider.notifier).updateProfile(
          user.copyWith(
            fullName: _name.text.trim(),
            phone: _phone.text.trim(),
            avatarUrl: _avatarUrl.text.trim().isEmpty
                ? null
                : _avatarUrl.text.trim(),
            marketingOptIn: _marketingOptIn,
          ),
        );
    if (!mounted) return;
    setState(() => _isBusy = false);

    if (ok) {
      context.showSnack('Profile updated.');
      Navigator.of(context).pop();
    } else {
      final error = ref.read(authControllerProvider).error;
      context.showSnack(error?.message ?? 'Could not update profile',
          isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    _hydrate();
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit profile')),
        body: const AppEmptyState(
          title: 'Please sign in',
          message: 'You need an account to edit your profile.',
          icon: Icons.person_off_outlined,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Edit profile')),
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
                    Center(
                      child: Column(
                        children: [
                          AppAvatar(
                            imageUrl: _avatarUrl.text.trim().isEmpty
                                ? user.avatarUrl
                                : _avatarUrl.text.trim(),
                            initials: user.initials,
                            size: 84,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          AppTag(
                            label: user.role.label,
                            icon: user.role.isProvider
                                ? Icons.storefront_outlined
                                : Icons.person_outline,
                            color: AppColors.purple.withValues(alpha: 0.12),
                            textColor: AppColors.purple,
                            compact: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    AppTextField(
                      controller: _name,
                      label: 'Full name',
                      prefixIcon: Icons.person_outline_rounded,
                      isRequired: true,
                      textInputAction: TextInputAction.next,
                      validator: Validators.name,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _phone,
                      label: 'Phone',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      validator: Validators.optionalPhone,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _avatarUrl,
                      label: 'Profile photo URL (optional)',
                      hint: 'https://…',
                      prefixIcon: Icons.image_outlined,
                      keyboardType: TextInputType.url,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    AppCard(
                      padding: EdgeInsets.zero,
                      child: SwitchListTile(
                        value: _marketingOptIn,
                        activeColor: AppColors.purple,
                        onChanged: (value) =>
                            setState(() => _marketingOptIn = value),
                        title: const Text('Promotional emails & texts'),
                        subtitle: const Text('Exclusive offers and updates'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Email (${user.email}) cannot be changed in the local preview build.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),

                    const SizedBox(height: AppSpacing.xl),
                    AppButton(
                      label: 'Save changes',
                      size: AppButtonSize.large,
                      icon: Icons.save_outlined,
                      isLoading: _isBusy,
                      onPressed: _save,
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
