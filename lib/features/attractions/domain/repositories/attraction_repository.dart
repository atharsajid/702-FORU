import '../../../../core/error/error_handler.dart';
import '../entities/attraction.dart';

/// Read/write access to the free-attractions catalogue.
abstract class AttractionRepository {
  Future<Result<List<Attraction>>> getAttractions();

  Future<Result<Attraction>> getAttractionById(String id);
}
