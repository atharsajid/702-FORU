import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_rating.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/review.dart';
import '../providers/catalog_providers.dart';

/// Lets a registered user rate and review a business.
class WriteReviewScreen extends ConsumerStatefulWidget {
  const WriteReviewScreen({super.key, required this.businessId});

  final String businessId;

  @override
  ConsumerState<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends ConsumerState<WriteReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _comment = TextEditingController();
  double _rating = 5;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider);
    if (user == null) {
      context.showSnack('Please sign in to leave a review.', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    final review = Review(
      id: 'r-${DateTime.now().microsecondsSinceEpoch}',
      businessId: widget.businessId,
      userId: user.id,
      userName: user.fullName,
      userAvatarUrl: user.avatarUrl,
      rating: _rating,
      comment: _comment.text.trim(),
      createdAt: DateTime.now(),
    );

    final result = await ref.read(submitReviewProvider)(review);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.when(
      success: (_) {
        ref.invalidate(reviewsProvider(widget.businessId));
        ref.invalidate(businessByIdProvider(widget.businessId));
        context.showSnack('Thanks! Your review is live.');
        Navigator.of(context).pop();
      },
      failure: (failure) =>
          context.showSnack(failure.message, isError: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Write a review')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(context.pagePadding),
            children: [
              AppCard(
                child: Column(
                  children: [
                    Text(
                      'How was your experience?',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppRatingPicker(
                      value: _rating,
                      onChanged: (value) => setState(() => _rating = value),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${_rating.toInt()} of 5 stars',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _comment,
                label: 'Your review',
                hint: 'Tell others what stood out…',
                maxLines: 5,
                isRequired: true,
                textInputAction: TextInputAction.newline,
                validator: (value) => (value == null || value.trim().length < 10)
                    ? 'Please write at least 10 characters'
                    : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Submit review',
                icon: Icons.send_rounded,
                isLoading: _isSubmitting,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Reviews are attached to your account and visible publicly.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
