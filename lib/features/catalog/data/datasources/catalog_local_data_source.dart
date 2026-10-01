import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/hive_service.dart';
import '../../domain/entities/business.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/coupon.dart';
import '../../domain/entities/review.dart';

/// Reads/writes catalogue data in Hive.
///
/// Throws [LocalStorageException] on failure; the repository translates that
/// into a domain `Failure`.
class CatalogLocalDataSource {
  const CatalogLocalDataSource();

  Box<dynamic> get _categories => HiveService.box(HiveBoxes.categories);
  Box<dynamic> get _businesses => HiveService.box(HiveBoxes.businesses);
  Box<dynamic> get _reviews => HiveService.box(HiveBoxes.reviews);
  Box<dynamic> get _coupons => HiveService.box(HiveBoxes.coupons);
  Box<dynamic> get _favorites => HiveService.box(HiveBoxes.favorites);

  // ── Categories ─────────────────────────────────────────────────────────
  List<Category> getCategories() {
    try {
      final items = _categories.values
          .whereType<Map>()
          .map((e) => Category.fromMap(Map<String, dynamic>.from(e)))
          .where((c) => c.isActive)
          .toList()
        ..sort((a, b) {
          if (a.isFeatured != b.isFeatured) return a.isFeatured ? -1 : 1;
          return a.sortOrder.compareTo(b.sortOrder);
        });
      return items;
    } catch (_) {
      throw const LocalStorageException('Could not load categories.');
    }
  }

  Category? getCategoryById(String id) {
    final raw = _categories.get(id);
    if (raw is Map) return Category.fromMap(Map<String, dynamic>.from(raw));
    return null;
  }

  Future<void> upsertCategory(Category category) =>
      _write(() => _categories.put(category.id, category.toMap()));

  // ── Businesses ─────────────────────────────────────────────────────────
  List<Business> getBusinesses() => _allBusinesses();

  List<Business> getBusinessesByCategory(String categoryId) => _allBusinesses()
      .where((b) => b.categoryId == categoryId)
      .toList(growable: false);

  Business? getBusinessById(String id) {
    final raw = _businesses.get(id);
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      // Attach the live rating so review edits are reflected immediately.
      final reviews = getReviewsFor(id);
      final business = Business.fromMap(map);
      if (reviews.isEmpty) return business;
      final avg = reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
      return business.copyWith(
        rating: avg,
        reviewCount: business.reviewCount + reviews.length,
      );
    }
    return null;
  }

  List<Business> searchBusinesses(String query) {
    final term = query.trim().toLowerCase();
    if (term.isEmpty) return const [];
    return _allBusinesses().where((b) {
      return b.name.toLowerCase().contains(term) ||
          b.description.toLowerCase().contains(term) ||
          b.address.toLowerCase().contains(term) ||
          b.services.any((s) => s.toLowerCase().contains(term)) ||
          b.categoryId.toLowerCase().contains(term);
    }).toList(growable: false);
  }

  Future<void> upsertBusiness(Business business) =>
      _write(() => _businesses.put(business.id, business.toMap()));

  Future<void> deleteBusiness(String id) => _write(() => _businesses.delete(id));

  // ── Reviews ────────────────────────────────────────────────────────────
  List<Review> getReviewsFor(String businessId) {
    try {
      return _reviews.values
          .whereType<Map>()
          .map((e) => Review.fromMap(Map<String, dynamic>.from(e)))
          .where((r) => r.businessId == businessId)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      throw const LocalStorageException('Could not load reviews.');
    }
  }

  Future<void> addReview(Review review) =>
      _write(() => _reviews.put(review.id, review.toMap()));

  // ── Coupons ────────────────────────────────────────────────────────────
  List<Coupon> getCouponsForBusiness(String businessId) => _allCoupons()
      .where((c) => c.businessId == businessId)
      .toList(growable: false);

  List<Coupon> getActiveCoupons() =>
      _allCoupons().where((c) => c.isRedeemable).toList(growable: false);

  Future<void> upsertCoupon(Coupon coupon) =>
      _write(() => _coupons.put(coupon.id, coupon.toMap()));

  Future<void> incrementCouponRedemption(String couponId) => _write(() async {
        final raw = _coupons.get(couponId);
        if (raw is! Map) {
          throw const RecordNotFoundException('Coupon not found.');
        }
        final coupon = Coupon.fromMap(Map<String, dynamic>.from(raw));
        await _coupons.put(
          couponId,
          coupon.copyWith(redemptionCount: coupon.redemptionCount + 1).toMap(),
        );
      });

  // ── Favourites ─────────────────────────────────────────────────────────
  /// Favourites are stored as `userId -> List<businessId>`.
  List<String> getFavoriteIds(String userId) {
    final raw = _favorites.get(userId);
    if (raw is List) return raw.map((e) => e.toString()).toList(growable: false);
    return const [];
  }

  bool isFavorite(String userId, String businessId) =>
      getFavoriteIds(userId).contains(businessId);

  Future<bool> toggleFavorite(String userId, String businessId) =>
      _write(() async {
        final current = getFavoriteIds(userId).toList();
        final nowFavorite = !current.remove(businessId);
        if (nowFavorite) current.add(businessId);
        await _favorites.put(userId, current);
        return nowFavorite;
      });

  // ── Internals ──────────────────────────────────────────────────────────
  List<Business> _allBusinesses() {
    try {
      return _businesses.values
          .whereType<Map>()
          .map((e) => Business.fromMap(Map<String, dynamic>.from(e)))
          .toList()
        ..sort((a, b) {
          if (a.isSponsored != b.isSponsored) return a.isSponsored ? -1 : 1;
          return b.rating.compareTo(a.rating);
        });
    } catch (_) {
      throw const LocalStorageException('Could not load businesses.');
    }
  }

  List<Coupon> _allCoupons() {
    try {
      return _coupons.values
          .whereType<Map>()
          .map((e) => Coupon.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      throw const LocalStorageException('Could not load coupons.');
    }
  }

  /// Runs a Hive write, converting any failure into a [LocalStorageException].
  Future<T> _write<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on RecordNotFoundException {
      rethrow;
    } catch (_) {
      throw const LocalStorageException();
    }
  }
}
