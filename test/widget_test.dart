// Unit + widget tests for the pure logic and shared components.
//
// These deliberately avoid Hive so they run without any platform channels:
// formatting, validation, result/error mapping and a couple of shared widgets.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signature/signature.dart';

import 'package:for_you/core/config/pricing.dart';
import 'package:for_you/core/error/error_handler.dart';
import 'package:for_you/core/error/exceptions.dart';
import 'package:for_you/core/error/failures.dart';
import 'package:for_you/core/utils/formatters.dart';
import 'package:for_you/core/storage/local_seed.dart';
import 'package:for_you/core/utils/image_url.dart';
import 'package:for_you/core/utils/map_launcher.dart';
import 'package:for_you/core/utils/validators.dart';
import 'package:for_you/features/attractions/domain/entities/attraction.dart';
import 'package:for_you/features/attractions/presentation/providers/attraction_providers.dart';
import 'package:for_you/features/attractions/presentation/screens/attraction_detail_screen.dart';
import 'package:for_you/features/attractions/presentation/screens/free_things_screen.dart';
import 'package:for_you/features/auth/domain/entities/app_user.dart';
import 'package:for_you/features/auth/presentation/providers/business_signup_draft.dart';
import 'package:for_you/features/auth/presentation/screens/how_it_works_screen.dart';
import 'package:for_you/features/auth/presentation/screens/login_screen.dart';
import 'package:for_you/features/auth/presentation/screens/signup_ads_screen.dart';
import 'package:for_you/features/auth/presentation/screens/signup_enrollment_screen.dart';
import 'package:for_you/features/auth/presentation/screens/signup_plan_screen.dart';
import 'package:for_you/features/catalog/domain/entities/business.dart';
import 'package:for_you/features/catalog/domain/entities/category.dart';
import 'package:for_you/features/catalog/domain/entities/coupon.dart';
import 'package:for_you/features/catalog/domain/entities/coupon_quota.dart';
import 'package:for_you/features/catalog/domain/entities/review.dart';
import 'package:for_you/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:for_you/features/catalog/presentation/screens/business_screen.dart';
import 'package:for_you/features/catalog/presentation/screens/category_screen.dart';
import 'package:for_you/features/catalog/presentation/widgets/coupon_access_sheet.dart';
import 'package:for_you/features/auth/presentation/providers/auth_providers.dart';
import 'package:for_you/features/offers/presentation/screens/spotlight_info_screen.dart';
import 'package:for_you/features/offers/domain/entities/featured_spotlight.dart';
import 'package:for_you/features/offers/domain/entities/offer.dart';
import 'package:for_you/shared/widgets/app_button.dart';
import 'package:for_you/shared/widgets/category_sphere.dart';
import 'package:for_you/shared/widgets/map_preview_card.dart';
import 'package:for_you/shared/widgets/promo_banners.dart';
import 'package:for_you/shared/widgets/app_network_image.dart';

void main() {
  group('Validators', () {
    test('rejects empty and malformed emails', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('not-an-email'), isNotNull);
      expect(Validators.email('user@example.com'), isNull);
    });

    test('enforces a minimum password length', () {
      expect(Validators.password('123'), 'Password must be at least 6 characters');
      expect(Validators.password('123456'), isNull);
    });

    test('confirmPassword compares against the original', () {
      expect(Validators.confirmPassword('abc123', 'abc123'), isNull);
      expect(Validators.confirmPassword('abc123', 'xyz789'), isNotNull);
    });

    test('optionalPhone allows an empty value but validates a real one', () {
      expect(Validators.optionalPhone(''), isNull);
      expect(Validators.optionalPhone('not a phone'), isNotNull);
      expect(Validators.optionalPhone('+1 702 555 0100'), isNull);
    });
  });

  group('AppFormatters', () {
    test('formats ratings without trailing zeros', () {
      expect(AppFormatters.rating(4.0), '4');
      expect(AppFormatters.rating(4.85), '4.9');
    });

    test('compacts large numbers', () {
      expect(AppFormatters.compact(950), '950');
      expect(AppFormatters.compact(1200), '1.2k');
      expect(AppFormatters.compact(15400), '15k');
      expect(AppFormatters.compact(2100000), '2.1M');
    });

    test('formats relative time', () {
      final now = DateTime.now();
      expect(AppFormatters.relative(now), 'just now');
      expect(AppFormatters.relative(now.subtract(const Duration(hours: 3))), '3h ago');
      expect(AppFormatters.relative(now.subtract(const Duration(days: 2))), '2d ago');
    });

    test('formats time and date', () {
      final morning = DateTime(2026, 10, 1, 9, 5);
      expect(AppFormatters.time(morning), '9:05 AM');
      expect(AppFormatters.date(morning), 'Oct 1, 2026');

      final evening = DateTime(2026, 10, 1, 16, 17);
      expect(AppFormatters.time(evening), '4:17 PM');
    });

    test('title-cases text', () {
      expect(AppFormatters.titleCase('arts & culture'), 'Arts & Culture');
    });
  });

  group('AppUser', () {
    final user = AppUser(
      id: 'u-1',
      fullName: 'Demo Visitor',
      email: 'demo@702foru.com',
      role: UserRole.user,
      passwordHash: AppUser.encodePassword('demo123'),
      createdAt: DateTime(2026, 1, 1),
    );

    test('hashes passwords reversibly for the local mock only', () {
      expect(user.matchesPassword('demo123'), isTrue);
      expect(user.matchesPassword('wrong'), isFalse);
    });

    test('derives initials from the name', () {
      expect(user.initials, 'DV');
      expect(
        user.copyWith(fullName: 'Josie').initials,
        'J',
      );
    });

    test('round-trips through a map', () {
      final restored = AppUser.fromMap(user.toMap());
      expect(restored.id, user.id);
      expect(restored.email, user.email);
      expect(restored.role, UserRole.user);
      expect(restored.marketingOptIn, isFalse);
    });

    test('compares structurally, not by id only', () {
      // Riverpod's `select` compares selected values with `==`, so an id-only
      // comparison would hide profile edits (e.g. the marketing toggle).
      expect(user.copyWith(marketingOptIn: true), isNot(user));
      expect(user.copyWith(fullName: 'Someone Else'), isNot(user));
      expect(user.copyWith(), user);
    });

    test('parses provider role safely', () {
      expect(UserRole.fromName('provider'), UserRole.provider);
      expect(UserRole.fromName('nonsense'), UserRole.user);
      expect(UserRole.provider.isProvider, isTrue);
    });
  });

  group('AppErrorHandler', () {
    test('maps exceptions to failures', () {
      expect(
        AppErrorHandler.toFailure(const ValidationException('bad input')),
        isA<ValidationFailure>(),
      );
      expect(
        AppErrorHandler.toFailure(const LocalStorageException()),
        isA<StorageFailure>(),
      );
      expect(
        AppErrorHandler.toFailure(const AuthException('nope')),
        isA<AuthFailure>(),
      );
      expect(
        AppErrorHandler.toFailure(StateError('unknown')),
        isA<UnexpectedFailure>(),
      );
    });

    test('passes existing failures straight through', () {
      const failure = NotFoundFailure('gone');
      expect(AppErrorHandler.toFailure(failure), same(failure));
    });

    test('guard captures thrown errors into a Result', () async {
      final success = await AppErrorHandler.guard(() async => 42);
      expect(success.valueOrNull, 42);

      final failure = await AppErrorHandler.guard<int>(
        () async => throw const ValidationException('nope'),
      );
      expect(failure.isFailure, isTrue);
      expect(failure.failureOrNull, isA<ValidationFailure>());
    });
  });

  group('AppButton', () {
    testWidgets('renders its label and fires onPressed', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Sign In / Sign Up',
              onPressed: () => tapped++,
            ),
          ),
        ),
      );

      expect(find.text('Sign In / Sign Up'), findsOneWidget);
      await tester.tap(find.byType(AppButton));
      expect(tapped, 1);
    });

    testWidgets('shows a spinner and blocks taps while loading', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Sign In',
              isLoading: true,
              onPressed: () => tapped++,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Sign In'), findsNothing);

      await tester.tap(find.byType(AppButton));
      expect(tapped, 0);
    });
  });

  group('Routing', () {
    test('every route the app pushes is registered in AppRouter', () {
      final registered = RegExp(r'case AppRoutes\.([A-Za-z]+):')
          .allMatches(
            File('lib/core/router/app_router.dart').readAsStringSync(),
          )
          .map((match) => match.group(1)!)
          .toSet();

      final referenced = <String>{};
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        if (entity.path.endsWith('app_router.dart')) continue;
        for (final match in RegExp(r'AppRoutes\.([A-Za-z]+)')
            .allMatches(entity.readAsStringSync())) {
          referenced.add(match.group(1)!);
        }
      }

      expect(
        referenced.difference(registered),
        isEmpty,
        reason: 'Unregistered routes fall through to the "Not found" screen.',
      );
    });
  });

  group('ImageUrl', () {
    const pexels =
        'https://images.pexels.com/photos/1674049/pexels-photo-1674049.jpeg';

    test('asks a resize-capable CDN for a compressed, right-sized file', () {
      final uri = Uri.parse(ImageUrl.optimized(pexels, width: 400, height: 250));

      expect(uri.host, 'images.pexels.com');
      expect(uri.path, '/photos/1674049/pexels-photo-1674049.jpeg');
      expect(uri.queryParameters, containsPair('auto', 'compress'));
      expect(uri.queryParameters['w'], '400');
      expect(uri.queryParameters['h'], '250');
    });

    test('omits the dimensions it was not given', () {
      final uri = Uri.parse(ImageUrl.optimized(pexels, width: 400));

      expect(uri.queryParameters['w'], '400');
      expect(uri.queryParameters.containsKey('h'), isFalse);
    });

    test('leaves hosts it does not understand untouched', () {
      const other = 'https://cdn.example.com/a/photo.jpg';
      expect(ImageUrl.optimized(other, width: 400), other);
    });

    test('keeps query parameters the url already carried', () {
      final uri = Uri.parse(ImageUrl.optimized('$pexels?foo=bar', width: 400));

      expect(uri.queryParameters['foo'], 'bar');
      expect(uri.queryParameters['w'], '400');
    });

    test('returns input it cannot use unchanged', () {
      expect(ImageUrl.optimized(''), '');
      expect(ImageUrl.optimized('   '), '');
      expect(ImageUrl.optimized('not-a-url'), 'not-a-url');
    });
  });

  group('AppNetworkImage', () {
    testWidgets('shows a broken-image placeholder when there is no url', (
      tester,
    ) async {
      // The empty-url path must never reach for the network.
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppNetworkImage(url: '   ', width: 64, height: 64),
          ),
        ),
      );

      expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
    });
  });

  group('MapLauncher', () {
    test('builds a Google Maps link for the exact coordinates', () {
      final uri = MapLauncher.uriFor(latitude: 36.1126, longitude: -115.1767);

      expect(uri.host, 'www.google.com');
      expect(uri.path, '/maps/search/');
      expect(uri.queryParameters['api'], '1');
      expect(uri.queryParameters['query'], '36.1126,-115.1767');
    });
  });

  group('Attraction', () {
    test('round-trips through a map', () {
      final original = LocalSeed.attractions.first;
      final restored = Attraction.fromMap(original.toMap());

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.latitude, original.latitude);
      expect(restored.longitude, original.longitude);
      expect(restored.goodToKnow, original.goodToKnow);
      expect(restored.lastVerifiedAt, original.lastVerifiedAt);
    });

    test('every seeded attraction has a photo, copy and real location', () {
      final ids = <String>{};

      for (final attraction in LocalSeed.attractions) {
        final label = attraction.id;
        expect(ids.add(label), isTrue, reason: 'duplicate id $label');
        expect(attraction.name.trim(), isNotEmpty, reason: label);
        expect(attraction.imageUrl, startsWith('https://'), reason: label);
        expect(attraction.description.length, greaterThan(80), reason: label);
        expect(attraction.address, isNotEmpty, reason: label);
        expect(attraction.hoursLabel, isNotEmpty, reason: label);
        expect(
          attraction.latitude,
          inInclusiveRange(35.0, 37.0),
          reason: label,
        );
        expect(
          attraction.longitude,
          inInclusiveRange(-116.5, -114.0),
          reason: label,
        );
        expect(attraction.isActive, isTrue, reason: label);
        expect(
          attraction.lastVerifiedAt.isAfter(DateTime(2025, 12, 31)),
          isTrue,
          reason: label,
        );
      }

      expect(ids.length, greaterThanOrEqualTo(6));
    });

    test('retired free listings are no longer part of the catalogue', () {
      final ids = LocalSeed.attractions.map((a) => a.id).toSet();

      for (final retired in LocalSeed.retiredBusinessIds) {
        expect(ids, isNot(contains(retired)));
      }
    });
  });

  group('Free Things screens', () {
    testWidgets('lists every attraction as its own card', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            attractionsProvider.overrideWith(
              (ref) async => LocalSeed.attractions,
            ),
          ],
          child: const MaterialApp(home: FreeThingsScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.byType(AttractionCard),
        findsNWidgets(LocalSeed.attractions.length),
      );
      expect(
        find.text(LocalSeed.attractions.first.name),
        findsOneWidget,
      );
    });

    testWidgets('detail page shows copy, address and the map action', (
      tester,
    ) async {
      final attraction = LocalSeed.attractions.first;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            attractionByIdProvider(attraction.id)
                .overrideWith((ref) async => attraction),
          ],
          child: MaterialApp(
            home: AttractionDetailScreen(attractionId: attraction.id),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text(attraction.tagline), findsOneWidget);
      // Shown once in the address row and once inside the map preview.
      expect(find.text(attraction.address), findsNWidgets(2));
      expect(find.text('Open in Maps'), findsOneWidget);
      expect(find.text('Plan your visit'), findsOneWidget);
    });
  });

  group('Featured in Vegas banner', () {
    testWidgets('fits a narrow phone without overflowing', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: FeaturedInVegasBanner(
                title: 'Skyline Heli Tours',
                subtitle: '15% off Strip tours this month',
                imageUrl: 'https://example.com/heli.jpg',
                categoryLabel: 'Unique Experiences',
                rating: 4.9,
                reviewCount: 512,
                hasVideo: true,
                onPressed: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.text('FEATURED IN VEGAS'), findsOneWidget);
      expect(find.text('Skyline Heli Tours'), findsOneWidget);
      expect(find.text('View details'), findsOneWidget);
    });
  });

  group('Featured in Vegas', () {
    const offer = Offer(
      id: 'o-featured',
      title: 'Skyline Heli Tours',
      subtitle: 'Featured in Vegas',
      imageUrl: 'https://example.com/heli.jpg',
      ctaLabel: 'View details',
      businessId: 'skyline-heli-tours',
      isFeatured: true,
    );

    test('keeps the featured flag when persisted', () {
      expect(Offer.fromMap(offer.toMap()).isFeatured, isTrue);
      expect(const Offer(id: 'x', title: 'x', subtitle: '', imageUrl: '').isFeatured, isFalse);
    });

    test('falls back to the offer when the business cannot be loaded', () {
      const spotlight = FeaturedSpotlight(offer: offer);

      expect(spotlight.title, 'Skyline Heli Tours');
      expect(spotlight.imageUrl, offer.imageUrl);
      expect(spotlight.businessId, 'skyline-heli-tours');
      expect(spotlight.rating, isNull);
      expect(spotlight.hasVideo, isFalse);
    });
  });

  group('Pricing', () {
    test('Basic Listing uses the confirmed trial and monthly price', () {
      expect(BusinessListingPricing.trialDays, 30);
      expect(BusinessListingPricing.monthlyPrice, 9.99);
      expect(BusinessListingPricing.monthlyLabel, r'$9.99 / month');
      expect(BusinessListingPricing.summary, contains(r'$9.99'));
      expect(
        BusinessListingPricing.trialEndFrom(DateTime(2026, 10, 1)),
        DateTime(2026, 10, 31),
      );
    });

    test('all three advertising placements are quote-only', () {
      expect(
        advertisingProducts.map((product) => product.id),
        containsAll(<String>['spotlight', 'video', 'premium-banner']),
      );
      for (final product in advertisingProducts) {
        expect(product.priceLabel, 'Request a quote',
            reason: product.id);
        expect(product.features, isNotEmpty, reason: product.id);
      }
    });

    test('consumer coupon passes match the confirmed prices', () {
      expect(ConsumerCouponPricing.freeCoupons, 10);
      expect(CouponPassType.oneTime.priceLabel, r'$1.99 one-time');
      expect(CouponPassType.monthly.priceLabel, r'$1.99 / month');
      expect(CouponPassType.yearly.priceLabel, r'$19.99 / year');
      expect(CouponPassType.oneTime.durationDays, isNull);
      expect(CouponPassType.monthly.durationDays, 30);
      expect(CouponPassType.yearly.durationDays, 365);
    });
  });

  group('CouponQuota', () {
    test('a free account gets ten coupons and is then blocked', () {
      var quota = const CouponQuota();

      for (var i = 0; i < ConsumerCouponPricing.freeCoupons; i++) {
        expect(quota.canRedeem, isTrue, reason: 'coupon ${i + 1}');
        quota = quota.consume();
      }

      expect(quota.remaining, 0);
      expect(quota.canRedeem, isFalse);
    });

    test('the one-time pass unlocks exactly one more coupon', () {
      final quota =
          const CouponQuota(used: ConsumerCouponPricing.freeCoupons)
              .withPass(CouponPassType.oneTime);

      expect(quota.canRedeem, isTrue);
      expect(quota.remaining, 1);
      expect(quota.consume().canRedeem, isFalse);
    });

    test('monthly and yearly passes lift the limit until they expire', () {
      final start = DateTime(2026, 10, 1);
      final monthly = const CouponQuota(used: 10)
          .withPass(CouponPassType.monthly, now: start);

      expect(monthly.hasUnlimitedAt(start), isTrue);
      expect(monthly.hasUnlimitedAt(start.add(const Duration(days: 29))), isTrue);
      expect(monthly.hasUnlimitedAt(start.add(const Duration(days: 31))), isFalse);

      final yearly = const CouponQuota(used: 10)
          .withPass(CouponPassType.yearly, now: start);
      expect(yearly.hasUnlimitedAt(start.add(const Duration(days: 364))), isTrue);
    });

    test('round-trips through a map', () {
      final quota = const CouponQuota(used: 4, bonusCredits: 1)
          .withPass(CouponPassType.yearly, now: DateTime(2026, 10, 1));
      final restored = CouponQuota.fromMap(quota.toMap());

      expect(restored.used, quota.used);
      expect(restored.bonusCredits, 1);
      expect(restored.unlimitedUntil, quota.unlimitedUntil);
    });
  });

  group('Business plans', () {
    test('persists the listing plan, add-ons and trial date', () {
      final business = Business(
        id: 'b-new',
        name: 'New Business',
        categoryId: 'food-drink',
        createdAt: DateTime(2026, 10, 1),
        legalName: 'New Business LLC',
        hours: 'Mon–Fri 9am–6pm',
        serviceArea: 'Summerlin',
        listingPlan: BusinessListingPricing.planId,
        advertisingAddOns: const ['spotlight'],
        trialEndsAt: DateTime(2026, 10, 31),
      );

      final restored = Business.fromMap(business.toMap());

      expect(restored.legalName, 'New Business LLC');
      expect(restored.hours, 'Mon–Fri 9am–6pm');
      expect(restored.serviceArea, 'Summerlin');
      expect(restored.listingPlan, 'basic');
      expect(restored.advertisingAddOns, ['spotlight']);
      expect(restored.trialEndsAt, DateTime(2026, 10, 31));
    });
  });

  group('Advertising page', () {
    testWidgets('shows the Basic price and all three placements', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: SpotlightInfoScreen()),
      );
      await tester.pump();

      expect(find.text('Spotlight placement'), findsOneWidget);
      expect(find.text('Video advertising'), findsOneWidget);
      expect(find.text('Premium banner'), findsOneWidget);
      expect(find.textContaining(r'$9.99'), findsWidgets);
      expect(find.textContaining('12%'), findsNothing);
      expect(find.textContaining('does not collect'), findsOneWidget);
    });

    testWidgets('fits a narrow phone without overflowing', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(home: SpotlightInfoScreen()),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  group('Business signup', () {
    testWidgets('step 1 shows the free trial and monthly price', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: SignupPlanScreen()),
      );
      await tester.pump();

      expect(find.text('Basic Listing'), findsOneWidget);
      expect(find.textContaining('FREE FOR 30 DAYS'), findsOneWidget);
      expect(find.textContaining(r'$9.99 / month'), findsWidgets);
      expect(find.text('Continue'), findsOneWidget);
    });
  });

  group('Coupon access', () {
    testWidgets('guests are offered a free account with 10 coupons', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isAuthenticatedProvider.overrideWithValue(false),
          ],
          child: const MaterialApp(
            home: Scaffold(body: CouponAllowanceBar()),
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('10 coupons included'), findsOneWidget);
      expect(find.text('Sign up'), findsOneWidget);
    });

    testWidgets('upgrade sheet offers the three confirmed passes', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showCouponUpgradeSheet(context),
                  child: const Text('open upgrade'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open upgrade'));
      await tester.pumpAndSettle();

      expect(find.text(r'$1.99 one-time'), findsOneWidget);
      expect(find.text(r'$1.99 / month'), findsOneWidget);
      expect(find.text(r'$19.99 / year'), findsOneWidget);
      expect(find.textContaining('no card is charged'), findsOneWidget);
    });
  });

  group('Business signup flow', () {
    testWidgets('advertising step toggles a placement on and off', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: SignupAdsScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Spotlight placement'), findsOneWidget);
      expect(find.text('Video advertising'), findsOneWidget);
      expect(find.text('Premium banner'), findsOneWidget);
      expect(find.text('Continue without ads'), findsOneWidget);

      await tester.tap(find.text('Spotlight placement'));
      await tester.pump();

      expect(find.text('Continue with 1 placement'), findsOneWidget);
      expect(find.textContaining('not added to your bill yet'), findsOneWidget);
    });

    testWidgets('enrollment refuses to open without business information', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: SignupEnrollmentScreen()),
        ),
      );
      await tester.pump();

      expect(
        find.text('Your business information is missing'),
        findsOneWidget,
      );
    });

    testWidgets('signature pad gates activation and can be cleared', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(420, 4000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            businessSignupDraftProvider
                .overrideWith(_FilledDraftController.new),
          ],
          child: const MaterialApp(home: SignupEnrollmentScreen()),
        ),
      );
      await tester.pump();

      final activate = find.widgetWithText(AppButton, 'Activate my listing');
      expect(tester.widget<AppButton>(activate).enabled, isFalse);
      expect(find.text('Sign here'), findsOneWidget);

      final boxes = find.byType(Checkbox);
      expect(boxes, findsNWidgets(4));
      for (var i = 0; i < 4; i++) {
        await tester.ensureVisible(boxes.at(i));
        await tester.tap(boxes.at(i));
        await tester.pump();
      }

      expect(
        tester.widget<AppButton>(activate).enabled,
        isFalse,
        reason: 'all acknowledgments without a signature must stay blocked',
      );

      await tester.ensureVisible(find.byType(Signature));
      await tester.drag(find.byType(Signature), const Offset(60, 30));
      await tester.pump();

      expect(find.text('Signature added'), findsOneWidget);
      expect(tester.widget<AppButton>(activate).enabled, isTrue);

      await tester.tap(find.text('Clear'));
      await tester.pump();

      expect(find.text('Sign here'), findsOneWidget);
      expect(tester.widget<AppButton>(activate).enabled, isFalse);

      // The user can sign again after clearing.
      await tester.drag(find.byType(Signature), const Offset(-40, 20));
      await tester.pump();
      expect(find.text('Signature added'), findsOneWidget);
      expect(tester.widget<AppButton>(activate).enabled, isTrue);
    });

    testWidgets('enrollment shows the trial, price and required agreements', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            businessSignupDraftProvider
                .overrideWith(_FilledDraftController.new),
          ],
          child: const MaterialApp(home: SignupEnrollmentScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Neon Bites'), findsOneWidget);
      expect(find.textContaining(r'$9.99 / month'), findsWidgets);
      expect(find.text('Spotlight placement'), findsOneWidget);
      expect(find.textContaining('I authorize recurring'), findsOneWidget);
      expect(find.textContaining('12%'), findsNothing);

      final activate = tester.widget<AppButton>(
        find.widgetWithText(AppButton, 'Activate my listing'),
      );
      expect(activate.enabled, isFalse);
    });
  });

  group('Final polish', () {
    test('every seeded offer has a working destination', () {
      for (final offer in LocalSeed.offers()) {
        expect(
          offer.hasTarget,
          isTrue,
          reason: '${offer.id} would land on a dead end',
        );
        expect(offer.ctaLabel, isNotEmpty, reason: offer.id);
      }
    });

    test('an offer route survives a map round-trip', () {
      final offer = LocalSeed.offers().firstWhere(
        (offer) => offer.route != null,
      );
      expect(Offer.fromMap(offer.toMap()).route, offer.route);
    });

    testWidgets('compact brand banner honours its height and is decorative', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              child: BrandBanner(),
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byType(BrandBanner)).height, 96);
      expect(tester.widget<InkWell>(find.byType(InkWell)).onTap, isNull);
    });

    testWidgets('brand banner is tappable only when it leads somewhere', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BrandBanner(),
          ),
        ),
      );

      await tester.tap(find.byType(BrandBanner));
      expect(taps, 1);
    });

    testWidgets('login has no placeholder social sign-in buttons', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LoginScreen())),
      );
      await tester.pump();

      expect(find.text('Google'), findsNothing);
      expect(find.text('Facebook'), findsNothing);
      expect(find.textContaining('available soon'), findsNothing);
      expect(find.text('Forgot password?'), findsOneWidget);
    });

    testWidgets('category spheres keep their grid tight on a desktop width', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1280, 900);
      addTearDown(tester.view.reset);

      final categories = [
        for (var i = 0; i < 6; i++)
          Category(
            id: 'category-$i',
            name: 'Category with a longer name $i',
            imageUrl: '',
            sortOrder: i,
          ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CategorySphereGrid(
                categories: categories,
                onCategoryTap: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      final grid = tester.widget<GridView>(find.byType(GridView));
      final delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, 5);
      expect(delegate.mainAxisExtent, lessThan(260));
    });

    testWidgets('business page shows contact actions and a map preview', (
      tester,
    ) async {
      final business = Business(
        id: 'burger-house',
        name: 'Burger House',
        categoryId: 'food-drink',
        rating: 4.4,
        reviewCount: 512,
        address: '77 Flavor Road, Las Vegas, NV',
        phone: '+1 702 111 2233',
        website: 'https://burgerhouse.com',
        description: 'The best burgers in town.',
        latitude: 36.1699,
        longitude: -115.1398,
        createdAt: DateTime(2026, 1, 1),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            businessByIdProvider(
              business.id,
            ).overrideWith((ref) async => business),
            couponsForBusinessProvider(
              business.id,
            ).overrideWith((ref) async => const <Coupon>[]),
            reviewsProvider(
              business.id,
            ).overrideWith((ref) async => const <Review>[]),
            isFavoriteProvider(business.id).overrideWithValue(false),
            currentUserProvider.overrideWithValue(null),
          ],
          child: MaterialApp(
            home: BusinessScreen(businessId: business.id),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);

      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.byType(MapPreviewCard),
        300,
        scrollable: scrollable,
      );
      expect(find.byType(MapPreviewCard), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Contact'),
        300,
        scrollable: scrollable,
      );
      await tester.pump();

      expect(find.text('Contact'), findsOneWidget);
      expect(find.text('+1 702 111 2233'), findsOneWidget);
      expect(find.text('burgerhouse.com'), findsOneWidget);
      expect(find.textContaining('coming soon'), findsNothing);
    });

    testWidgets('category business grid fits a desktop width', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1280, 900);
      addTearDown(tester.view.reset);

      final category = LocalSeed.categories[1];
      final businesses = [
        for (var i = 0; i < 4; i++)
          Business(
            id: 'business-$i',
            name: 'A business with a name long enough to wrap $i',
            categoryId: category.id,
            rating: 4.8,
            reviewCount: 1234,
            address: '1 Long Street, Las Vegas, NV',
            createdAt: DateTime(2026, 1, 1),
          ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            businessesByCategoryProvider(
              category.id,
            ).overrideWith((ref) async => businesses),
          ],
          child: MaterialApp(home: CategoryScreen(category: category)),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.text('Businesses in ${category.name}'), findsOneWidget);
    });
  });

  group('How it works', () {
    testWidgets('removes commission wording and explains direct payment', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: HowItWorksScreen()),
      );
      await tester.pump();

      expect(find.textContaining('10 coupons'), findsOneWidget);
      expect(find.textContaining('12%'), findsNothing);

      await tester.tap(find.text('For businesses'));
      await tester.pumpAndSettle();

      expect(find.text('Get paid directly'), findsOneWidget);
      expect(
        find.textContaining('does not collect customer payments'),
        findsOneWidget,
      );
    });
  });
}

class _FilledDraftController extends BusinessSignupDraftController {
  @override
  BusinessSignupDraft build() => const BusinessSignupDraft(
        legalName: 'Neon Bites LLC',
        businessName: 'Neon Bites',
        contactName: 'Josie S.',
        contactTitle: 'Owner',
        email: 'josie@example.com',
        phone: '+1 702 555 0100',
        address: '1 Fremont St, Las Vegas, NV',
        description: 'Late-night bites downtown.',
        hours: 'Daily 5pm–2am',
        serviceArea: 'Downtown Las Vegas',
        password: 'demo123',
        categoryId: 'food-drink',
        advertisingAddOns: {'spotlight'},
      );
}
