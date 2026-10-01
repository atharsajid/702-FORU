import '../../../../core/error/error_handler.dart';
import '../entities/business.dart';
import '../entities/category.dart';
import '../entities/coupon.dart';
import '../entities/review.dart';
import '../repositories/catalog_repository.dart';

/// Use cases keep the presentation layer free of repository plumbing and give
/// each screen intent a name.
class GetCategories {
  const GetCategories(this._repository);
  final CatalogRepository _repository;

  Future<Result<List<Category>>> call() => _repository.getCategories();
}

class GetBusinessesByCategory {
  const GetBusinessesByCategory(this._repository);
  final CatalogRepository _repository;

  Future<Result<List<Business>>> call(String categoryId) =>
      _repository.getBusinessesByCategory(categoryId);
}

class GetBusinessById {
  const GetBusinessById(this._repository);
  final CatalogRepository _repository;

  Future<Result<Business>> call(String businessId) =>
      _repository.getBusinessById(businessId);
}

class SearchBusinesses {
  const SearchBusinesses(this._repository);
  final CatalogRepository _repository;

  Future<Result<List<Business>>> call(String query) =>
      _repository.searchBusinesses(query);
}

class GetReviews {
  const GetReviews(this._repository);
  final CatalogRepository _repository;

  Future<Result<List<Review>>> call(String businessId) =>
      _repository.getReviews(businessId);
}

class SubmitReview {
  const SubmitReview(this._repository);
  final CatalogRepository _repository;

  Future<Result<Review>> call(Review review) => _repository.addReview(review);
}

class GetCouponsForBusiness {
  const GetCouponsForBusiness(this._repository);
  final CatalogRepository _repository;

  Future<Result<List<Coupon>>> call(String businessId) =>
      _repository.getCouponsForBusiness(businessId);
}

class RedeemCoupon {
  const RedeemCoupon(this._repository);
  final CatalogRepository _repository;

  Future<Result<Coupon>> call(String couponId) =>
      _repository.redeemCoupon(couponId);
}

class SaveCoupon {
  const SaveCoupon(this._repository);
  final CatalogRepository _repository;

  Future<Result<Coupon>> call(Coupon coupon) => _repository.saveCoupon(coupon);
}

class ToggleFavorite {
  const ToggleFavorite(this._repository);
  final CatalogRepository _repository;

  Future<Result<bool>> call({
    required String userId,
    required String businessId,
  }) =>
      _repository.toggleFavorite(userId, businessId);
}

class GetFavoriteIds {
  const GetFavoriteIds(this._repository);
  final CatalogRepository _repository;

  Future<Result<List<String>>> call(String userId) =>
      _repository.getFavoriteIds(userId);
}

class GetFavoriteBusinesses {
  const GetFavoriteBusinesses(this._repository);
  final CatalogRepository _repository;

  Future<Result<List<Business>>> call(String userId) =>
      _repository.getFavoriteBusinesses(userId);
}

class SaveBusiness {
  const SaveBusiness(this._repository);
  final CatalogRepository _repository;

  Future<Result<void>> call(Business business) =>
      _repository.saveBusiness(business);
}
