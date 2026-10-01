import 'package:flutter/material.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_card.dart';

/// First step of registration: who are you?
class SignUpRoleScreen extends StatelessWidget {
  const SignUpRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: context.pagePadding, vertical: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: ClipRRect(borderRadius: BorderRadius.circular(AppRadius.lg), child: Image.asset('assets/logo.png', height: 78)),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('How will you use 702FORU?', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Pick the account type that fits you. You can add a business listing later.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xxl),

              _RoleCard(
                icon: Icons.person_outline_rounded,
                title: 'I am a visitor',
                description: 'Explore Vegas, save favourites, use coupons and leave reviews.',
                benefits: const ['Save and bookmark businesses', 'Redeem exclusive coupon codes', 'Leave reviews for any business'],
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.signUpUser),
              ),

              const SizedBox(height: AppSpacing.lg),

              _RoleCard(
                icon: Icons.storefront_outlined,
                title: 'I am a business',
                description: 'Create your free listing and reach thousands of locals and visitors.',
                benefits: const ['Your own Airbnb-style listing page', 'Coupons with a 702-4U tracking code', 'Choice of commission or flat billing'],
                highlighted: true,
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.signUpProvider),
              ),

              const SizedBox(height: AppSpacing.xl),
              Center(
                child: TextButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed(AppRoutes.howItWorks),
                  icon: const Icon(Icons.help_outline_rounded, size: 18),
                  label: const Text('How it works'),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already registered? ', style: Theme.of(context).textTheme.bodyMedium),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.login),
                    child: const Text(
                      'Sign in',
                      style: TextStyle(color: AppColors.purple, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.benefits,
    required this.onTap,
    this.highlighted = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final List<String> benefits;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      border: highlighted ? Border.all(color: AppColors.purple, width: 1.6) : null,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppIconTile(icon: icon, size: 46),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(title, style: Theme.of(context).textTheme.headlineSmall)),
              const Icon(Icons.arrow_forward, color: AppColors.purple),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          for (final benefit in benefits)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(benefit, style: const TextStyle(fontSize: 13))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
