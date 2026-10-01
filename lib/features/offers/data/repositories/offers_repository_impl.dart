import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/offer.dart';
import '../../domain/repositories/offers_repository.dart';
import '../datasources/offers_local_data_source.dart';

class OffersRepositoryImpl implements OffersRepository {
  OffersRepositoryImpl(this._local);

  final OffersLocalDataSource _local;

  @override
  Future<Result<List<Offer>>> getOffers() =>
      AppErrorHandler.guard(() async => _local.getOffers());

  @override
  Future<Result<Offer>> getOfferById(String id) async {
    try {
      final offer = _local.getOfferById(id);
      if (offer == null) {
        return const Error(NotFoundFailure('That offer has ended.'));
      }
      return Success(offer);
    } catch (error) {
      return Error(AppErrorHandler.toFailure(error));
    }
  }

  @override
  Future<Result<void>> saveOffer(Offer offer) =>
      AppErrorHandler.guard(() => _local.upsert(offer));
}
