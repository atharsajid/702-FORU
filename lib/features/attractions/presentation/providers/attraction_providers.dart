import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/result_extensions.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../domain/entities/attraction.dart';
import '../../domain/usecases/attraction_usecases.dart';

final getAttractionsProvider = Provider<GetAttractions>(
  (ref) => GetAttractions(ref.watch(attractionRepositoryProvider)),
);

final getAttractionByIdProvider = Provider<GetAttractionById>(
  (ref) => GetAttractionById(ref.watch(attractionRepositoryProvider)),
);

/// Every active free attraction, ordered for display.
final attractionsProvider = FutureProvider<List<Attraction>>((ref) async {
  final result = await ref.watch(getAttractionsProvider)();
  return result.orThrow();
});

final attractionByIdProvider =
    FutureProvider.family<Attraction, String>((ref, id) async {
  final result = await ref.watch(getAttractionByIdProvider)(id);
  return result.orThrow();
});
