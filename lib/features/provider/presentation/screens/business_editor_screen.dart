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
import '../../../catalog/domain/entities/business.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../providers/provider_providers.dart';

/// Lets a provider edit everything on their listing page.
class BusinessEditorScreen extends ConsumerStatefulWidget {
  const BusinessEditorScreen({super.key});

  @override
  ConsumerState<BusinessEditorScreen> createState() =>
      _BusinessEditorScreenState();
}

class _BusinessEditorScreenState extends ConsumerState<BusinessEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _website = TextEditingController();
  final _logoUrl = TextEditingController();
  final _coverUrl = TextEditingController();
  final _videoUrl = TextEditingController();
  final _services = TextEditingController();

  Business? _source;
  bool _isBusy = false;
  bool _hydrated = false;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _address.dispose();
    _phone.dispose();
    _website.dispose();
    _logoUrl.dispose();
    _coverUrl.dispose();
    _videoUrl.dispose();
    _services.dispose();
    super.dispose();
  }

  void _hydrate(Business business) {
    if (_hydrated) return;
    _source = business;
    _name.text = business.name;
    _description.text = business.description;
    _address.text = business.address;
    _phone.text = business.phone;
    _website.text = business.website;
    _logoUrl.text = business.logoUrl ?? '';
    _coverUrl.text = business.coverUrl ?? '';
    _videoUrl.text = business.videoUrl ?? '';
    _services.text = business.services.join(', ');
    _hydrated = true;
  }

  Future<void> _save() async {
    context.unfocus();
    if (!_formKey.currentState!.validate()) return;

    final business = _source;
    if (business == null) return;

    setState(() => _isBusy = true);

    final services = _services.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList(growable: false);

    final updated = business.copyWith(
      name: _name.text.trim(),
      description: _description.text.trim(),
      address: _address.text.trim(),
      phone: _phone.text.trim(),
      website: _website.text.trim(),
      logoUrl: _logoUrl.text.trim().isEmpty ? null : _logoUrl.text.trim(),
      coverUrl: _coverUrl.text.trim().isEmpty ? null : _coverUrl.text.trim(),
      videoUrl: _videoUrl.text.trim().isEmpty ? null : _videoUrl.text.trim(),
      services: services,
    );

    final result = await ref.read(saveBusinessProvider)(updated);

    if (!mounted) return;
    setState(() => _isBusy = false);

    result.when(
      success: (_) {
        ref.invalidate(myBusinessProvider);
        ref.invalidate(businessByIdProvider(business.id));
        context.showSnack('Listing updated.');
        Navigator.of(context).pop();
      },
      failure: (failure) =>
          context.showSnack(failure.message, isError: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final business = ref.watch(myBusinessProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Edit listing')),
      body: AsyncValueView<Business?>(
        value: business,
        onRetry: () => ref.invalidate(myBusinessProvider),
        builder: (context, listing) {
          if (listing == null) {
            return const AppEmptyState(
              title: 'No listing found',
              message: 'Create a business listing to edit it here.',
              icon: Icons.storefront_outlined,
            );
          }
          _hydrate(listing);

          return SafeArea(
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
                        // Live preview of the listing header.
                        AppCard(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                                child: AppNetworkImage(
                                  url: _coverUrl.text.trim().isEmpty
                                      ? listing.coverUrl
                                      : _coverUrl.text.trim(),
                                  width: 64,
                                  height: 64,
                                  placeholderIcon: Icons.storefront_outlined,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _name.text.isEmpty
                                          ? listing.name
                                          : _name.text,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Tracking code: ${listing.trackingCode}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),
                        AppTextField(
                          controller: _name,
                          label: 'Business name',
                          isRequired: true,
                          textInputAction: TextInputAction.next,
                          validator: (value) => Validators.minLength(
                            value,
                            2,
                            field: 'Business name',
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          controller: _description,
                          label: 'About your business',
                          maxLines: 4,
                          textInputAction: TextInputAction.newline,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          controller: _address,
                          label: 'Address',
                          prefixIcon: Icons.location_on_outlined,
                          textInputAction: TextInputAction.next,
                          validator: (value) =>
                              Validators.minLength(value, 5, field: 'Address'),
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
                          controller: _website,
                          label: 'Website',
                          prefixIcon: Icons.language_outlined,
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          controller: _services,
                          label: 'Services',
                          hint: 'Dine-in, Delivery, Catering',
                          helperText: 'Separate each service with a comma',
                          textInputAction: TextInputAction.next,
                        ),

                        const SizedBox(height: AppSpacing.xl),
                        AppCard(
                          color: AppColors.purple.withValues(alpha: 0.05),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Logo, video & photos',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Your promo video is shown instead of the logo when provided. '
                                'Add a 702FORU backlink so viewers can find us.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          controller: _logoUrl,
                          label: 'Logo image URL',
                          prefixIcon: Icons.image_outlined,
                          keyboardType: TextInputType.url,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          controller: _coverUrl,
                          label: 'Cover image URL',
                          prefixIcon: Icons.photo_outlined,
                          keyboardType: TextInputType.url,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          controller: _videoUrl,
                          label: 'Promo video URL (optional)',
                          prefixIcon: Icons.play_circle_outline_rounded,
                          keyboardType: TextInputType.url,
                        ),

                        const SizedBox(height: AppSpacing.xl),
                        AppButton(
                          label: 'Save listing',
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
          );
        },
      ),
    );
  }
}
