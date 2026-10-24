import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/pricing.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/coupon_quota.dart';

/// The signed-in visitor's coupon allowance.
///
/// Guests (signed out) get an empty quota — they are prompted to create a free
/// account, which starts them on the 10 included coupons.
class CouponQuotaController extends AsyncNotifier<CouponQuota> {
  @override
  Future<CouponQuota> build() async {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return const CouponQuota();
    return ref.watch(couponQuotaLocalDataSourceProvider).read(userId);
  }

  /// Counts one coupon against the allowance after a successful redemption.
  Future<void> recordRedemption() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    state = AsyncData(
      await ref
          .read(couponQuotaLocalDataSourceProvider)
          .recordRedemption(userId),
    );
  }

  /// Activates a one-time, monthly or yearly coupon pass.
  Future<void> purchasePass(CouponPassType type) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    state = AsyncData(
      await ref.read(couponQuotaLocalDataSourceProvider).grantPass(
            userId,
            type,
          ),
    );
  }
}

final couponQuotaProvider =
    AsyncNotifierProvider<CouponQuotaController, CouponQuota>(
  CouponQuotaController.new,
);
