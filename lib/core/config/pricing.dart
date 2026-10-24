import 'package:flutter/material.dart';

/// Pricing that is shown to businesses and visitors.
///
/// Everything money-related lives here so a confirmed number from the client
/// only has to change once. The Basic Listing amounts come from the signed
/// `702ForU_Pricing.docx` enrollment form; advertising placements are still
/// awaiting final confirmation, so they are quoted rather than priced.
class BusinessListingPricing {
  const BusinessListingPricing._();

  static const String planId = 'basic';
  static const String planName = 'Basic Listing';
  static const int trialDays = 30;
  static const double monthlyPrice = 9.99;

  /// e.g. `$9.99 / month`
  static const String monthlyLabel = r'$9.99 / month';

  /// e.g. `Free for 30 days`
  static const String trialLabel = 'Free for 30 days';

  /// One-line summary used on cards and receipts.
  static const String summary =
      r'Free for 30 days, then $9.99/month unless cancelled';

  /// Advertising placements are quoted until the client confirms final prices.
  static const String confirmationNote =
      'Prices are subject to final confirmation.';

  static DateTime trialEndFrom(DateTime start) =>
      start.add(const Duration(days: trialDays));
}

/// One paid placement a business can add on top of the Basic Listing.
class AdvertisingProduct {
  const AdvertisingProduct({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.icon,
    required this.features,
    this.priceLabel = 'Request a quote',
  });

  final String id;
  final String name;
  final String tagline;
  final String description;
  final IconData icon;
  final List<String> features;

  /// Deliberately not a number until the client confirms ad pricing.
  final String priceLabel;
}

/// The three advertising options requested by the client.
const List<AdvertisingProduct> advertisingProducts = [
  AdvertisingProduct(
    id: 'spotlight',
    name: 'Spotlight placement',
    tagline: 'Be the featured card at the top of a category.',
    description:
        'Your business sits above the standard listings in its category, with '
        'the Spotlight badge and a rotating home-screen slot.',
    icon: Icons.workspace_premium_outlined,
    features: [
      'Top placement on one category page',
      'Spotlight badge on your listing',
      'Rotation on the home screen',
    ],
  ),
  AdvertisingProduct(
    id: 'video',
    name: 'Video advertising',
    tagline: 'Show your business in motion.',
    description:
        'A short promo video on your listing and in the video rail, with a '
        'backlink to your 702FORU page.',
    icon: Icons.play_circle_outline_rounded,
    features: [
      'Promo video on your listing page',
      'Featured in the video placements',
      'Tap-through to your full listing',
    ],
  ),
  AdvertisingProduct(
    id: 'premium-banner',
    name: 'Premium banner',
    tagline: 'Own the top of the screen.',
    description:
        'A premium banner at the top of the home or category screens, built '
        'from your own artwork and offer.',
    icon: Icons.view_carousel_outlined,
    features: [
      'Top banner placement',
      'Your artwork and offer copy',
      'Direct link to your listing',
    ],
  ),
];

/// Consumer coupon allowances and paid upgrades.
class ConsumerCouponPricing {
  const ConsumerCouponPricing._();

  /// Coupons included with every free account.
  static const int freeCoupons = 10;

  static const double oneTimePrice = 1.99;
  static const double monthlyPrice = 1.99;
  static const double yearlyPrice = 19.99;
}

/// What happens when a visitor spends a coupon.
enum CouponPassType {
  oneTime,
  monthly,
  yearly;

  String get label => switch (this) {
        CouponPassType.oneTime => 'Single coupon',
        CouponPassType.monthly => 'Monthly unlimited',
        CouponPassType.yearly => 'Yearly unlimited',
      };

  String get priceLabel => switch (this) {
        CouponPassType.oneTime => r'$1.99 one-time',
        CouponPassType.monthly => r'$1.99 / month',
        CouponPassType.yearly => r'$19.99 / year',
      };

  String get detail => switch (this) {
        CouponPassType.oneTime => 'Unlocks one more coupon redemption.',
        CouponPassType.monthly => 'Unlimited coupons for 30 days.',
        CouponPassType.yearly => 'Unlimited coupons for 12 months — best value.',
      };

  bool get isSubscription =>
      this == CouponPassType.monthly || this == CouponPassType.yearly;

  int? get durationDays => switch (this) {
        CouponPassType.oneTime => null,
        CouponPassType.monthly => 30,
        CouponPassType.yearly => 365,
      };
}
