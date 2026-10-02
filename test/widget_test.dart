// Unit + widget tests for the pure logic and shared components.
//
// These deliberately avoid Hive so they run without any platform channels:
// formatting, validation, result/error mapping and a couple of shared widgets.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:for_you/core/error/error_handler.dart';
import 'package:for_you/core/error/exceptions.dart';
import 'package:for_you/core/error/failures.dart';
import 'package:for_you/core/utils/formatters.dart';
import 'package:for_you/core/utils/image_url.dart';
import 'package:for_you/core/utils/validators.dart';
import 'package:for_you/features/auth/domain/entities/app_user.dart';
import 'package:for_you/shared/widgets/app_button.dart';
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
}
