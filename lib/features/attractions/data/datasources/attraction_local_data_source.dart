import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/hive_service.dart';
import '../../domain/entities/attraction.dart';

/// Reads and writes the free-attractions catalogue in Hive.
class AttractionLocalDataSource {
  const AttractionLocalDataSource();

  Box<dynamic> get _box => HiveService.box(HiveBoxes.attractions);

  List<Attraction> getAttractions() {
    try {
      return _box.values
          .whereType<Map>()
          .map((e) => Attraction.fromMap(Map<String, dynamic>.from(e)))
          .where((a) => a.isActive)
          .toList(growable: false)
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    } catch (_) {
      throw const LocalStorageException('Could not load free things to do.');
    }
  }

  Attraction? getAttractionById(String id) {
    final raw = _box.get(id);
    if (raw is Map) return Attraction.fromMap(Map<String, dynamic>.from(raw));
    return null;
  }

  Future<void> upsert(Attraction attraction) async {
    try {
      await _box.put(attraction.id, attraction.toMap());
    } catch (_) {
      throw const LocalStorageException();
    }
  }
}
