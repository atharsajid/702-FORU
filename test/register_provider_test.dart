import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:for_you/core/config/pricing.dart';
import 'package:for_you/core/storage/hive_service.dart';
import 'package:for_you/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:for_you/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:for_you/features/auth/domain/entities/app_user.dart';
import 'package:for_you/features/catalog/data/datasources/catalog_local_data_source.dart';
import 'package:for_you/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:for_you/features/provider/domain/usecases/register_provider.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('702foru_register');
    Hive.init(tempDir.path);
    for (final box in [
      HiveBoxes.users,
      HiveBoxes.businesses,
      HiveBoxes.reviews,
      HiveBoxes.session,
    ]) {
      await Hive.openBox<dynamic>(box);
    }
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('enrollment creates a Basic Listing with trial and add-ons', () async {
    final auth = AuthRepositoryImpl(const AuthLocalDataSource());
    final catalog = CatalogRepositoryImpl(const CatalogLocalDataSource());
    final register = RegisterProviderAccount(
      authRepository: auth,
      catalogRepository: catalog,
    );

    final result = await register(
      fullName: 'Josie S.',
      email: 'josie@neonbites.com',
      password: 'demo123',
      phone: '+1 702 555 0100',
      businessName: 'Neon Bites',
      categoryId: 'food-drink',
      address: '1 Fremont St, Las Vegas, NV',
      description: 'Late-night bites downtown.',
      legalName: 'Neon Bites LLC',
      hours: 'Daily 5pm–2am',
      serviceArea: 'Downtown Las Vegas',
      website: 'https://neonbites.com',
      advertisingAddOns: const ['spotlight'],
    );

    final registration = result.when(
      success: (value) => value,
      failure: (failure) => throw failure,
    );

    expect(registration.user.role, UserRole.provider);
    expect(registration.user.businessId, registration.business.id);

    final listing = registration.business;
    expect(listing.listingPlan, BusinessListingPricing.planId);
    expect(listing.legalName, 'Neon Bites LLC');
    expect(listing.hours, 'Daily 5pm–2am');
    expect(listing.serviceArea, 'Downtown Las Vegas');
    expect(listing.website, 'https://neonbites.com');
    expect(listing.advertisingAddOns, ['spotlight']);
    expect(
      listing.trialEndsAt!.difference(listing.createdAt).inDays,
      BusinessListingPricing.trialDays,
    );

    final stored = await catalog.getBusinessById(listing.id);
    final persisted = stored.when(
      success: (value) => value,
      failure: (failure) => throw failure,
    );

    expect(persisted.name, 'Neon Bites');
    expect(persisted.listingPlan, 'basic');
    expect(
      persisted.trialEndsAt!.millisecondsSinceEpoch,
      listing.trialEndsAt!.millisecondsSinceEpoch,
    );
    expect(persisted.advertisingAddOns, ['spotlight']);
  });
}
