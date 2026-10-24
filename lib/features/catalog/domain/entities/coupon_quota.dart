import '../../../../core/config/pricing.dart';
import '../../../../core/utils/json_utils.dart';

/// How many coupons a visitor may still redeem.
///
/// Free accounts include [CouponQuota.freeLimit] coupons. Paid passes either
/// add a single credit (one-time) or lift the limit for a period
/// (monthly / yearly).
class CouponQuota {
  const CouponQuota({
    this.used = 0,
    this.bonusCredits = 0,
    this.unlimitedUntil,
  });

  /// Coupons already redeemed by this account.
  final int used;

  /// Extra single-use credits bought with the one-time pass.
  final int bonusCredits;

  /// End of a monthly/yearly unlimited pass (null when no pass is active).
  final DateTime? unlimitedUntil;

  static const int freeLimit = ConsumerCouponPricing.freeCoupons;

  bool hasUnlimitedAt(DateTime now) {
    final until = unlimitedUntil;
    return until != null && until.isAfter(now);
  }

  bool get hasUnlimited => hasUnlimitedAt(DateTime.now());

  /// Free coupons plus any one-time credits.
  int get totalCredits => freeLimit + bonusCredits;

  /// Coupons left, or [totalCredits] while a subscription is active.
  int get remaining {
    if (hasUnlimited) return totalCredits;
    final left = totalCredits - used;
    return left < 0 ? 0 : left;
  }

  bool get canRedeem => hasUnlimited || used < totalCredits;

  CouponQuota consume() => copyWith(used: used + 1);

  /// Applies a purchased pass and returns the updated quota.
  CouponQuota withPass(CouponPassType type, {DateTime? now}) {
    final at = now ?? DateTime.now();
    final days = type.durationDays;
    if (days == null) {
      return copyWith(bonusCredits: bonusCredits + 1);
    }
    final base = hasUnlimitedAt(at) ? unlimitedUntil! : at;
    return copyWith(unlimitedUntil: base.add(Duration(days: days)));
  }

  CouponQuota copyWith({
    int? used,
    int? bonusCredits,
    DateTime? unlimitedUntil,
  }) {
    return CouponQuota(
      used: used ?? this.used,
      bonusCredits: bonusCredits ?? this.bonusCredits,
      unlimitedUntil: unlimitedUntil ?? this.unlimitedUntil,
    );
  }

  Map<String, dynamic> toMap() => {
        'used': used,
        'bonusCredits': bonusCredits,
        'unlimitedUntil': unlimitedUntil?.millisecondsSinceEpoch,
      };

  factory CouponQuota.fromMap(Map<String, dynamic> map) => CouponQuota(
        used: Json.toInt(map['used']),
        bonusCredits: Json.toInt(map['bonusCredits']),
        unlimitedUntil: Json.nullableDateTime(map['unlimitedUntil']),
      );

  @override
  bool operator ==(Object other) =>
      other is CouponQuota &&
      other.used == used &&
      other.bonusCredits == bonusCredits &&
      other.unlimitedUntil == unlimitedUntil;

  @override
  int get hashCode => Object.hash(used, bonusCredits, unlimitedUntil);
}
