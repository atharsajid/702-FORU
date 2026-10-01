import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/result_extensions.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../domain/entities/offer.dart';
import '../../domain/usecases/offers_usecases.dart';

final getOffersProvider = Provider<GetOffers>(
  (ref) => GetOffers(ref.watch(offersRepositoryProvider)),
);

final getOfferByIdProvider = Provider<GetOfferById>(
  (ref) => GetOfferById(ref.watch(offersRepositoryProvider)),
);

final offersProvider = FutureProvider<List<Offer>>((ref) async {
  final result = await ref.watch(getOffersProvider)();
  return result.orThrow();
});

/// The offer shown on the Home banner (first active offer).
final heroOfferProvider = FutureProvider<Offer?>((ref) async {
  final offers = await ref.watch(offersProvider.future);
  return offers.isEmpty ? null : offers.first;
});

final offerByIdProvider =
    FutureProvider.family<Offer, String>((ref, id) async {
  final result = await ref.watch(getOfferByIdProvider)(id);
  return result.orThrow();
});
