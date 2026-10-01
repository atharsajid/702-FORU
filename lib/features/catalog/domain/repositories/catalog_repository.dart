import '../../../../core/error/error_handler.dart';
import '../entities/business.dart';
import '../entities/category.dart';
import '../entities/coupon.dart';
import '../entities/review.dart';

/// Contract the presentation layer depends on. The Hive implementation can be
/// swapped for a REST/Firebase one later without touching any UI code.
abstract class CatalogRepository {
  Future<Result<List<Category>>> getCategories();
  Future<Result<List<Business>>> getBusinesses();
  Future<Result<List<Business>>> getBusinessesByCategory(String categoryId);
  Future<Result<List<Business>>> getSponsoredBusinesses();
  Future<Result<Business>> getBusinessById(String businessId);
  Future<Result<List<Business>>> searchBusinesses(String query);

  Future<Result<List<Review>>> getReviews(String businessId);
  Future<Result<Review>> addReview(Review review);

  Future<Result<List<Coupon>>> getCouponsForBusiness(String businessId);
  Future<Result<List<Coupon>>> getActiveCoupons();
  Future<Result<Coupon>> redeemCoupon(String couponId);
  Future<Result<Coupon>> saveCoupon(Coupon coupon);

  Future<Result<List<String>>> getFavoriteIds(String userId);
  Future<Result<List<Business>>> getFavoriteBusinesses(String userId);
  Future<Result<bool>> toggleFavorite(String userId, String businessId);

  Future<Result<void>> saveBusiness(Business business);
}
