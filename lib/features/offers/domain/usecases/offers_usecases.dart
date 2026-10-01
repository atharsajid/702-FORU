import '../../../../core/error/error_handler.dart';
import '../entities/offer.dart';
import '../repositories/offers_repository.dart';

class GetOffers {
  const GetOffers(this._repository);
  final OffersRepository _repository;

  Future<Result<List<Offer>>> call() => _repository.getOffers();
}

class GetOfferById {
  const GetOfferById(this._repository);
  final OffersRepository _repository;

  Future<Result<Offer>> call(String id) => _repository.getOfferById(id);
}
