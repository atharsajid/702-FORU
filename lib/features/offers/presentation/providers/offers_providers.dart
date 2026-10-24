import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/result_extensions.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../catalog/domain/entities/business.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../../domain/entities/featured_spotlight.dart';
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

/// The offer chosen for the Home banner. Uses the first active offer when
/// nothing is explicitly marked as featured, so the banner is never empty.
final heroOfferProvider = FutureProvider<Offer?>((ref) async {
  final offers = await ref.watch(offersProvider.future);
  if (offers.isEmpty) return null;
  for (final offer in offers) {
    if (offer.isFeatured) return offer;
  }
  return offers.first;
});

/// Resolves the featured offer plus the business it promotes, so the banner can
/// show the business's own photo, rating and detail-page link.
final featuredSpotlightProvider =
    FutureProvider<FeaturedSpotlight?>((ref) async {
  final offer = await ref.watch(heroOfferProvider.future);
  if (offer == null) return null;

  Business? business;
  final businessId = offer.businessId;
  if (businessId != null && businessId.isNotEmpty) {
    final result = await ref.watch(getBusinessByIdProvider)(businessId);
    business = result.valueOrNull;
  }

  return FeaturedSpotlight(offer: offer, business: business);
});

final offerByIdProvider =
    FutureProvider.family<Offer, String>((ref, id) async {
  final result = await ref.watch(getOfferByIdProvider)(id);
  return result.orThrow();
});
