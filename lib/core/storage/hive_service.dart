import 'package:hive_flutter/hive_flutter.dart';

/// All Hive box names used by the app. Keeping them in one place avoids typos
/// and makes a future schema migration easy to reason about.
class HiveBoxes {
  const HiveBoxes._();

  /// Current session (logged-in user id, first-run flags).
  static const String session = 'session';

  /// Registered accounts (users + providers).
  static const String users = 'users';

  /// Category catalogue.
  static const String categories = 'categories';

  /// Businesses.
  static const String businesses = 'businesses';

  /// Reviews keyed by id.
  static const String reviews = 'reviews';

  /// Coupons keyed by id.
  static const String coupons = 'coupons';

  /// Exclusive offers shown on the Home banner / Offers screen.
  static const String offers = 'offers';

  /// Notifications keyed by id.
  static const String notifications = 'notifications';

  /// Saved/bookmarked business ids for the signed-in user.
  static const String favorites = 'favorites';

  static const List<String> all = [
    session,
    users,
    categories,
    businesses,
    reviews,
    coupons,
    offers,
    notifications,
    favorites,
  ];
}

/// Keys inside the `session` box.
class HiveKeys {
  const HiveKeys._();

  static const String currentUserId = 'current_user_id';
  static const String seedVersion = 'seed_version';
  static const String onboardingSeen = 'onboarding_seen';
}

/// Boots Hive and exposes typed box access.
class HiveService {
  const HiveService._();

  static bool _initialised = false;

  /// Must be awaited in `main()` before `runApp`.
  static Future<void> init() async {
    if (_initialised) return;
    await Hive.initFlutter();
    for (final name in HiveBoxes.all) {
      await Hive.openBox<dynamic>(name);
    }
    _initialised = true;
  }

  static bool get isReady => _initialised;

  static Box<dynamic> box(String name) {
    if (!Hive.isBoxOpen(name)) {
      throw StateError(
        'Hive box "$name" is not open. Did you forget to await HiveService.init()?',
      );
    }
    return Hive.box<dynamic>(name);
  }

  static Box<dynamic> get session => box(HiveBoxes.session);

  /// Wipes every box – used by "Sign out & clear data" and tests.
  static Future<void> clearAll() async {
    for (final name in HiveBoxes.all) {
      await box(name).clear();
    }
  }

  static Future<void> close() => Hive.close();
}
