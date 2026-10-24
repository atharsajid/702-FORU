import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:for_you/core/config/pricing.dart';
import 'package:for_you/core/storage/hive_service.dart';
import 'package:for_you/features/catalog/data/datasources/coupon_quota_local_data_source.dart';

void main() {
  late Directory tempDir;
  const source = CouponQuotaLocalDataSource();

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('702foru_coupon_quota');
    Hive.init(tempDir.path);
    await Hive.openBox<dynamic>(HiveBoxes.couponQuota);
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('counts ten free redemptions and then blocks the eleventh', () async {
    for (var i = 0; i < ConsumerCouponPricing.freeCoupons; i++) {
      final quota = await source.recordRedemption('u-free');
      expect(quota.canRedeem, i < ConsumerCouponPricing.freeCoupons - 1);
    }

    final stored = source.read('u-free');
    expect(stored.used, ConsumerCouponPricing.freeCoupons);
    expect(stored.canRedeem, isFalse);
  });

  test('monthly pass is persisted and lifts the limit', () async {
    final quota = await source.grantPass('u-monthly', CouponPassType.monthly);

    expect(quota.hasUnlimited, isTrue);
    expect(quota.canRedeem, isTrue);
    expect(source.read('u-monthly').hasUnlimited, isTrue);
    expect(source.read('u-monthly').unlimitedUntil, isNotNull);
  });

  test('one-time pass unlocks exactly one extra coupon', () async {
    for (var i = 0; i < ConsumerCouponPricing.freeCoupons; i++) {
      await source.recordRedemption('u-one-time');
    }
    expect(source.read('u-one-time').canRedeem, isFalse);

    final granted = await source.grantPass('u-one-time', CouponPassType.oneTime);
    expect(granted.canRedeem, isTrue);
    expect(granted.remaining, 1);

    final after = await source.recordRedemption('u-one-time');
    expect(after.canRedeem, isFalse);
  });
}
