import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/config/pricing.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/hive_service.dart';
import '../../domain/entities/coupon_quota.dart';

/// Persists each visitor's coupon allowance (`userId -> CouponQuota`).
class CouponQuotaLocalDataSource {
  const CouponQuotaLocalDataSource();

  Box<dynamic> get _box => HiveService.box(HiveBoxes.couponQuota);

  CouponQuota read(String userId) {
    try {
      final raw = _box.get(userId);
      if (raw is Map) {
        return CouponQuota.fromMap(Map<String, dynamic>.from(raw));
      }
      return const CouponQuota();
    } catch (_) {
      throw const LocalStorageException('Could not read your coupon balance.');
    }
  }

  /// Counts one redeemed coupon against the account.
  Future<CouponQuota> recordRedemption(String userId) =>
      _update(userId, (quota) => quota.consume());

  /// Adds a purchased pass to the account.
  Future<CouponQuota> grantPass(String userId, CouponPassType type) =>
      _update(userId, (quota) => quota.withPass(type));

  Future<void> reset(String userId) async {
    try {
      await _box.delete(userId);
    } catch (_) {
      throw const LocalStorageException('Could not reset your coupons.');
    }
  }

  Future<CouponQuota> _update(
    String userId,
    CouponQuota Function(CouponQuota) change,
  ) async {
    try {
      final updated = change(read(userId));
      await _box.put(userId, updated.toMap());
      return updated;
    } catch (_) {
      throw const LocalStorageException('Could not update your coupons.');
    }
  }
}
