import '../../../../core/error/error_handler.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/business.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/coupon.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/catalog_local_data_source.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl(this._local);

  final CatalogLocalDataSource _local;

  /// Every method funnels through [_guard] so callers always receive a
  /// [Result] – never a thrown exception.
  Future<Result<T>> _guard<T>(T Function() action) async =>
      AppErrorHandler.guard(() async => action());

  Future<Result<T>> _guardAsync<T>(Future<T> Function() action) async =>
      AppErrorHandler.guard(action);

  @override
  Future<Result<List<Category>>> getCategories() =>
      _guard(() => _local.getCategories());

  @override
  Future<Result<List<Business>>> getBusinesses() =>
      _guard(() => _local.getBusinesses());

  @override
  Future<Result<List<Business>>> getBusinessesByCategory(String categoryId) =>
      _guard(() => _local.getBusinessesByCategory(categoryId));

  @override
  Future<Result<List<Business>>> getSponsoredBusinesses() => _guard(
        () => _local
            .getBusinesses()
            .where((b) => b.isSponsored)
            .toList(growable: false),
      );

  @override
  Future<Result<Business>> getBusinessById(String businessId) async {
    try {
      final business = _local.getBusinessById(businessId);
      if (business == null) {
        return const Error(NotFoundFailure('This business is no longer listed.'));
      }
      return Success(business);
    } catch (error) {
      return Error(AppErrorHandler.toFailure(error));
    }
  }

  @override
  Future<Result<List<Business>>> searchBusinesses(String query) =>
      _guard(() => _local.searchBusinesses(query));

  @override
  Future<Result<List<Review>>> getReviews(String businessId) =>
      _guard(() => _local.getReviewsFor(businessId));

  @override
  Future<Result<Review>> addReview(Review review) async {
    try {
      if (review.comment.trim().isEmpty) {
        return const Error(ValidationFailure('Please write a short comment.'));
      }
      if (review.rating <= 0) {
        return const Error(ValidationFailure('Please choose a star rating.'));
      }
      await _local.addReview(review);
      return Success(review);
    } on AppException catch (error) {
      return Error(AppErrorHandler.toFailure(error));
    } catch (error) {
      return Error(AppErrorHandler.toFailure(error));
    }
  }

  @override
  Future<Result<List<Coupon>>> getCouponsForBusiness(String businessId) =>
      _guard(() => _local.getCouponsForBusiness(businessId));

  @override
  Future<Result<List<Coupon>>> getActiveCoupons() =>
      _guard(() => _local.getActiveCoupons());

  @override
  Future<Result<Coupon>> redeemCoupon(String couponId) async {
    try {
      final raw = _local.getActiveCoupons().where((c) => c.id == couponId);
      if (raw.isEmpty) {
        return const Error(NotFoundFailure('This coupon is no longer available.'));
      }
      await _local.incrementCouponRedemption(couponId);
      return Success(raw.first.copyWith(redemptionCount: raw.first.redemptionCount + 1));
    } on AppException catch (error) {
      return Error(AppErrorHandler.toFailure(error));
    } catch (error) {
      return Error(AppErrorHandler.toFailure(error));
    }
  }

  @override
  Future<Result<Coupon>> saveCoupon(Coupon coupon) async {
    try {
      if (coupon.title.trim().isEmpty) {
        return const Error(ValidationFailure('Give the coupon a title.'));
      }
      if (coupon.code.trim().isEmpty) {
        return const Error(ValidationFailure('Give the coupon a code.'));
      }
      await _local.upsertCoupon(coupon);
      return Success(coupon);
    } on AppException catch (error) {
      return Error(AppErrorHandler.toFailure(error));
    } catch (error) {
      return Error(AppErrorHandler.toFailure(error));
    }
  }

  @override
  Future<Result<List<String>>> getFavoriteIds(String userId) =>
      _guard(() => _local.getFavoriteIds(userId));

  @override
  Future<Result<List<Business>>> getFavoriteBusinesses(String userId) => _guard(
        () => _local
            .getFavoriteIds(userId)
            .map(_local.getBusinessById)
            .whereType<Business>()
            .toList(growable: false),
      );

  @override
  Future<Result<bool>> toggleFavorite(String userId, String businessId) =>
      _guardAsync(() => _local.toggleFavorite(userId, businessId));

  @override
  Future<Result<void>> saveBusiness(Business business) =>
      _guardAsync(() => _local.upsertBusiness(business));
}
