import '../../../../core/error/error_handler.dart';
import '../entities/offer.dart';

abstract class OffersRepository {
  Future<Result<List<Offer>>> getOffers();
  Future<Result<Offer>> getOfferById(String id);
  Future<Result<void>> saveOffer(Offer offer);
}
