import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/attractions/data/datasources/attraction_local_data_source.dart';
import '../../features/attractions/data/repositories/attraction_repository_impl.dart';
import '../../features/attractions/domain/repositories/attraction_repository.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/catalog/data/datasources/catalog_local_data_source.dart';
import '../../features/catalog/data/datasources/coupon_quota_local_data_source.dart';
import '../../features/catalog/data/repositories/catalog_repository_impl.dart';
import '../../features/catalog/domain/repositories/catalog_repository.dart';
import '../../features/notifications/data/datasources/notifications_local_data_source.dart';
import '../../features/notifications/data/repositories/notifications_repository_impl.dart';
import '../../features/notifications/domain/repositories/notifications_repository.dart';
import '../../features/offers/data/datasources/offers_local_data_source.dart';
import '../../features/offers/data/repositories/offers_repository_impl.dart';
import '../../features/offers/domain/repositories/offers_repository.dart';

// ── Data sources ─────────────────────────────────────────────────────────
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>(
  (ref) => const AuthLocalDataSource(),
);

final catalogLocalDataSourceProvider = Provider<CatalogLocalDataSource>(
  (ref) => const CatalogLocalDataSource(),
);

final couponQuotaLocalDataSourceProvider =
    Provider<CouponQuotaLocalDataSource>(
  (ref) => const CouponQuotaLocalDataSource(),
);

final offersLocalDataSourceProvider = Provider<OffersLocalDataSource>(
  (ref) => const OffersLocalDataSource(),
);

final attractionLocalDataSourceProvider = Provider<AttractionLocalDataSource>(
  (ref) => const AttractionLocalDataSource(),
);

final notificationsLocalDataSourceProvider =
    Provider<NotificationsLocalDataSource>(
  (ref) => const NotificationsLocalDataSource(),
);

// ── Repositories ─────────────────────────────────────────────────────────
//
// Swapping Hive for a REST/Firebase implementation later means changing only
// these four lines – no screen or provider needs to know.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(authLocalDataSourceProvider)),
);

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => CatalogRepositoryImpl(ref.watch(catalogLocalDataSourceProvider)),
);

final offersRepositoryProvider = Provider<OffersRepository>(
  (ref) => OffersRepositoryImpl(ref.watch(offersLocalDataSourceProvider)),
);

final attractionRepositoryProvider = Provider<AttractionRepository>(
  (ref) => AttractionRepositoryImpl(ref.watch(attractionLocalDataSourceProvider)),
);

final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => NotificationsRepositoryImpl(
    ref.watch(notificationsLocalDataSourceProvider),
  ),
);
