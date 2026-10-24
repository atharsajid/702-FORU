import '../../../../core/config/pricing.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../catalog/domain/entities/business.dart';
import '../../../catalog/domain/repositories/catalog_repository.dart';

/// What a provider registration produces.
class ProviderRegistration {
  const ProviderRegistration({required this.user, required this.business});

  final AppUser user;
  final Business business;
}

/// Registers a business account **and** creates its listing in one step.
///
/// This is an application-level use case: it is the only place allowed to
/// coordinate the auth and catalog domains, so neither domain depends on the
/// other.
class RegisterProviderAccount {
  const RegisterProviderAccount({
    required AuthRepository authRepository,
    required CatalogRepository catalogRepository,
  })  : _auth = authRepository,
        _catalog = catalogRepository;

  final AuthRepository _auth;
  final CatalogRepository _catalog;

  Future<Result<ProviderRegistration>> call({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String businessName,
    required String categoryId,
    required String address,
    String description = '',
    String legalName = '',
    String hours = '',
    String serviceArea = '',
    String website = '',
    List<String> advertisingAddOns = const [],
    bool marketingOptIn = false,
  }) async {
    // 1. Create the account.
    final signUp = await _auth.signUp(
      SignUpParams(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
        role: UserRole.provider,
        marketingOptIn: marketingOptIn,
      ),
    );

    final user = signUp.when(
      success: (value) => value,
      failure: (failure) => failure,
    );
    if (user is Failure) return Error(user);

    final account = user as AppUser;

    // 2. Create the business listing owned by that account.
    final now = DateTime.now();
    final businessId = 'b-${now.microsecondsSinceEpoch}';
    final business = Business(
      id: businessId,
      name: businessName.trim(),
      categoryId: categoryId,
      address: address.trim(),
      description: description.trim().isEmpty
          ? 'Newly listed on 702FORU. Discover more soon.'
          : description.trim(),
      trackingCode: _trackingCode(businessName, now),
      ownerId: account.id,
      website: website.trim(),
      legalName: legalName.trim(),
      hours: hours.trim(),
      serviceArea: serviceArea.trim(),
      listingPlan: BusinessListingPricing.planId,
      advertisingAddOns: List<String>.unmodifiable(advertisingAddOns),
      trialEndsAt: BusinessListingPricing.trialEndFrom(now),
      createdAt: now,
    );

    final saved = await _catalog.saveBusiness(business);
    if (saved.failureOrNull != null) {
      return Error(saved.failureOrNull!);
    }

    // 3. Link the listing back onto the account.
    final linked = await _auth.updateProfile(
      account.copyWith(businessId: businessId),
    );

    return linked.when(
      success: (updated) => Success(
        ProviderRegistration(user: updated, business: business),
      ),
      failure: (failure) => Error(failure),
    );
  }

  /// `702-4U-XXXX` style code used to attribute coupon redemptions.
  String _trackingCode(String businessName, DateTime now) {
    final letters = businessName
        .replaceAll(RegExp(r'[^A-Za-z]'), '')
        .toUpperCase()
        .padRight(4, 'X')
        .substring(0, 4);
    final suffix = (now.millisecondsSinceEpoch % 10000).toString().padLeft(4, '0');
    return '702-4U-$letters$suffix';
  }
}
