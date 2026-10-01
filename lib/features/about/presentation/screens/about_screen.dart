import 'package:flutter/material.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';

/// "About 702FORU" – reached by tapping the logo/video on Home.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const List<({IconData icon, String text})> _features = [
    (
      icon: Icons.auto_awesome_outlined,
      text: 'Smart recommendations for restaurants and services.'
    ),
    (icon: Icons.location_on_outlined, text: 'Location-based suggestions.'),
    (icon: Icons.person_pin_outlined, text: 'Personalized user experience.'),
    (icon: Icons.trending_up_outlined, text: 'Real-time updates and trends.'),
    (icon: Icons.security_outlined, text: 'Enhanced safety and data accuracy.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('About 702FORU')),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: context.pagePadding,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero ─────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: AppColors.navyGradient,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(16),
                    child: Image.asset('assets/logo.png', height: 108)),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Discover. Connect. Experience.',
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.85),
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            _Heading('What is 702FORU?'),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '702FORU is an innovative platform designed to assist both locals '
              'and visitors in discovering top-notch restaurants, hairdressers, '
              'handymen, and more, offering valuable information on quality '
              'services and deals.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            _Heading('Why AI integration?'),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Collaborating with a trusted AI development company significantly '
              'enhances 702FORU\u2019s functionality, providing users with a '
              'seamless and personalized experience while ensuring the platform '
              'stays up to date with the latest technological advancements.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            _Heading('Key improvements with AI'),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Column(
                children: [
                  for (final feature in _features)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          AppIconTile(icon: feature.icon, size: 38),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              feature.text,
                              style: const TextStyle(fontSize: 14.5, height: 1.35),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            AppButton(
              label: 'Create a free account',
              size: AppButtonSize.large,
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.signUpRole),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: 'How it works',
              variant: AppButtonVariant.outline,
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.howItWorks),
            ),

            const SizedBox(height: AppSpacing.xxl),
            Center(
              child: Text(
                '© ${DateTime.now().year} 702FORU • All rights reserved',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: Theme.of(context).textTheme.headlineLarge);
}
