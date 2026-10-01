import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/hive_service.dart';
import '../../domain/entities/offer.dart';

class OffersLocalDataSource {
  const OffersLocalDataSource();

  Box<dynamic> get _box => HiveService.box(HiveBoxes.offers);

  List<Offer> getOffers() {
    try {
      return _box.values
          .whereType<Map>()
          .map((e) => Offer.fromMap(Map<String, dynamic>.from(e)))
          .where((o) => o.isActive && !o.isExpired)
          .toList(growable: false);
    } catch (_) {
      throw const LocalStorageException('Could not load offers.');
    }
  }

  Offer? getOfferById(String id) {
    final raw = _box.get(id);
    if (raw is Map) return Offer.fromMap(Map<String, dynamic>.from(raw));
    return null;
  }

  Future<void> upsert(Offer offer) async {
    try {
      await _box.put(offer.id, offer.toMap());
    } catch (_) {
      throw const LocalStorageException();
    }
  }
}
