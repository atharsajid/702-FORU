import '../../../../core/error/error_handler.dart';
import '../entities/attraction.dart';
import '../repositories/attraction_repository.dart';

class GetAttractions {
  const GetAttractions(this._repository);
  final AttractionRepository _repository;

  Future<Result<List<Attraction>>> call() => _repository.getAttractions();
}

class GetAttractionById {
  const GetAttractionById(this._repository);
  final AttractionRepository _repository;

  Future<Result<Attraction>> call(String id) =>
      _repository.getAttractionById(id);
}
