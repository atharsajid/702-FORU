import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/result_extensions.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../catalog/domain/entities/business.dart';
import '../../../catalog/domain/entities/coupon.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../../domain/usecases/register_provider.dart';

/// Registers the account and creates the listing in one step.
final registerProviderAccountProvider = Provider<RegisterProviderAccount>(
  (ref) => RegisterProviderAccount(
    authRepository: ref.watch(authRepositoryProvider),
    catalogRepository: ref.watch(catalogRepositoryProvider),
  ),
);

/// The signed-in provider's own listing (null for visitors / missing data).
final myBusinessProvider = FutureProvider<Business?>((ref) async {
  final businessId = ref.watch(currentUserProvider)?.businessId;
  if (businessId == null) return null;
  final result = await ref.watch(getBusinessByIdProvider)(businessId);
  return result.valueOrNull;
});

/// Coupons belonging to the provider's listing.
final myCouponsProvider = FutureProvider<List<Coupon>>((ref) async {
  final business = await ref.watch(myBusinessProvider.future);
  if (business == null) return const [];
  final result = await ref.watch(getCouponsForBusinessProvider)(business.id);
  return result.orThrow();
});

/// Aggregate stats shown on the dashboard.
class ProviderSummary {
  const ProviderSummary({
    required this.coupons,
    required this.redemptions,
    required this.reviews,
    required this.rating,
    required this.commissionOwed,
    required this.flatFee,
  });

  final int coupons;
  final int redemptions;
  final int reviews;
  final double rating;

  /// 12% commission model estimate (per the client's agreement).
  final double commissionOwed;

  /// Flat monthly service fee option.
  final double flatFee;

  static const double commissionRate = 0.12;
  static const double monthlyFlatFee = 149.0;

  /// Assumed average ticket used to estimate commission until real order data
  /// exists.
  static const double averageTicket = 42.0;
}

final providerSummaryProvider = FutureProvider<ProviderSummary>((ref) async {
  final business = await ref.watch(myBusinessProvider.future);
  if (business == null) {
    return const ProviderSummary(
      coupons: 0,
      redemptions: 0,
      reviews: 0,
      rating: 0,
      commissionOwed: 0,
      flatFee: ProviderSummary.monthlyFlatFee,
    );
  }

  final coupons = await ref.watch(myCouponsProvider.future);
  final reviews = await ref.watch(reviewsProvider(business.id).future);

  final redemptions = coupons.fold<int>(
    0,
    (sum, coupon) => sum + coupon.redemptionCount,
  );

  final gross = redemptions * ProviderSummary.averageTicket;

  return ProviderSummary(
    coupons: coupons.length,
    redemptions: redemptions,
    reviews: reviews.length,
    rating: business.rating,
    commissionOwed: gross * ProviderSummary.commissionRate,
    flatFee: ProviderSummary.monthlyFlatFee,
  );
});
