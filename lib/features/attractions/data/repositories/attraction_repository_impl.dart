import '../../../../core/error/error_handler.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/attraction.dart';
import '../../domain/repositories/attraction_repository.dart';
import '../datasources/attraction_local_data_source.dart';

class AttractionRepositoryImpl implements AttractionRepository {
  AttractionRepositoryImpl(this._local);

  final AttractionLocalDataSource _local;

  @override
  Future<Result<List<Attraction>>> getAttractions() =>
      AppErrorHandler.guard(() async => _local.getAttractions());

  @override
  Future<Result<Attraction>> getAttractionById(String id) async {
    try {
      final attraction = _local.getAttractionById(id);
      if (attraction == null || !attraction.isActive) {
        return const Error(
          NotFoundFailure('This free spot is no longer listed.'),
        );
      }
      return Success(attraction);
    } on AppException catch (error) {
      return Error(AppErrorHandler.toFailure(error));
    } catch (error) {
      return Error(AppErrorHandler.toFailure(error));
    }
  }
}
