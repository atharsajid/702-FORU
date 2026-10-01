import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/result_extensions.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/business.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/coupon.dart';
import '../../domain/entities/review.dart';
import '../../domain/usecases/catalog_usecases.dart';

// ── Use cases ────────────────────────────────────────────────────────────
final getCategoriesProvider = Provider<GetCategories>(
  (ref) => GetCategories(ref.watch(catalogRepositoryProvider)),
);

final getBusinessesByCategoryProvider = Provider<GetBusinessesByCategory>(
  (ref) => GetBusinessesByCategory(ref.watch(catalogRepositoryProvider)),
);

final getBusinessByIdProvider = Provider<GetBusinessById>(
  (ref) => GetBusinessById(ref.watch(catalogRepositoryProvider)),
);

final searchBusinessesProvider = Provider<SearchBusinesses>(
  (ref) => SearchBusinesses(ref.watch(catalogRepositoryProvider)),
);

final getReviewsProvider = Provider<GetReviews>(
  (ref) => GetReviews(ref.watch(catalogRepositoryProvider)),
);

final submitReviewProvider = Provider<SubmitReview>(
  (ref) => SubmitReview(ref.watch(catalogRepositoryProvider)),
);

final getCouponsForBusinessProvider = Provider<GetCouponsForBusiness>(
  (ref) => GetCouponsForBusiness(ref.watch(catalogRepositoryProvider)),
);

final redeemCouponProvider = Provider<RedeemCoupon>(
  (ref) => RedeemCoupon(ref.watch(catalogRepositoryProvider)),
);

final saveCouponProvider = Provider<SaveCoupon>(
  (ref) => SaveCoupon(ref.watch(catalogRepositoryProvider)),
);

final toggleFavoriteProvider = Provider<ToggleFavorite>(
  (ref) => ToggleFavorite(ref.watch(catalogRepositoryProvider)),
);

final getFavoriteIdsProvider = Provider<GetFavoriteIds>(
  (ref) => GetFavoriteIds(ref.watch(catalogRepositoryProvider)),
);

final getFavoriteBusinessesProvider = Provider<GetFavoriteBusinesses>(
  (ref) => GetFavoriteBusinesses(ref.watch(catalogRepositoryProvider)),
);

final saveBusinessProvider = Provider<SaveBusiness>(
  (ref) => SaveBusiness(ref.watch(catalogRepositoryProvider)),
);

// ── Read models ──────────────────────────────────────────────────────────
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final result = await ref.watch(getCategoriesProvider)();
  return result.orThrow();
});

/// Categories that should be highlighted on the Home grid.
final featuredCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final all = await ref.watch(categoriesProvider.future);
  return all.where((c) => c.isFeatured).toList(growable: false);
});

final businessesByCategoryProvider =
    FutureProvider.family<List<Business>, String>((ref, categoryId) async {
  final result = await ref.watch(getBusinessesByCategoryProvider)(categoryId);
  return result.orThrow();
});

final businessByIdProvider =
    FutureProvider.family<Business, String>((ref, businessId) async {
  final result = await ref.watch(getBusinessByIdProvider)(businessId);
  return result.orThrow();
});

final sponsoredBusinessesProvider = FutureProvider<List<Business>>((ref) async {
  final all = (await ref.watch(catalogRepositoryProvider).getBusinesses()).orThrow();
  return all.where((b) => b.isSponsored).toList(growable: false);
});

final reviewsProvider =
    FutureProvider.family<List<Review>, String>((ref, businessId) async {
  final result = await ref.watch(getReviewsProvider)(businessId);
  return result.orThrow();
});

final couponsForBusinessProvider =
    FutureProvider.family<List<Coupon>, String>((ref, businessId) async {
  final result = await ref.watch(getCouponsForBusinessProvider)(businessId);
  return result.orThrow();
});

final activeCouponsProvider = FutureProvider<List<Coupon>>((ref) async {
  final result =
      await ref.watch(catalogRepositoryProvider).getActiveCoupons();
  return result.orThrow();
});

/// Search results for a query (empty query → empty list, no Hive scan).
final searchResultsProvider =
    FutureProvider.family<List<Business>, String>((ref, query) async {
  if (query.trim().isEmpty) return const [];
  final result = await ref.watch(searchBusinessesProvider)(query);
  return result.orThrow();
});

// ── Favourites ───────────────────────────────────────────────────────────
/// Keeps the signed-in user's saved business ids in memory and reactive.
class FavoritesController extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return const [];
    final result = await ref.watch(getFavoriteIdsProvider)(userId);
    return result.orThrow();
  }

  Future<void> toggle(String businessId) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    state = await AsyncValue.guard(() async {
      await ref.read(toggleFavoriteProvider)(
        userId: userId,
        businessId: businessId,
      );
      final result = await ref.read(getFavoriteIdsProvider)(userId);
      return result.orThrow();
    });
  }
}

final favoritesControllerProvider =
    AsyncNotifierProvider<FavoritesController, List<String>>(
  FavoritesController.new,
);

/// Whether a specific business is saved (false while loading).
final isFavoriteProvider = Provider.family<bool, String>((ref, businessId) {
  final ids = ref.watch(favoritesControllerProvider).valueOrNull;
  return ids?.contains(businessId) ?? false;
});

final favoriteBusinessesProvider = FutureProvider<List<Business>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const [];
  // Re-read whenever the id set changes.
  await ref.watch(favoritesControllerProvider.future);
  final result = await ref.watch(getFavoriteBusinessesProvider)(userId);
  return result.orThrow();
});
