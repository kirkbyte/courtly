import 'package:courtly_api/courtly_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/bookings_local_datasource.dart';
import '../data/bookings_repository.dart';
import '../data/clubs_repository.dart';
import '../data/session_local_datasource.dart';
import '../data/settings_local_datasource.dart';

part 'di.g.dart';

/// Overridden with a real instance in main() before runApp.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override in main()'),
);

/// Typed as the fake on purpose: dev tooling and tests flip `shouldFail`.
@Riverpod(keepAlive: true)
FakeClubsApi clubsApi(Ref ref) => FakeClubsApi();

@Riverpod(keepAlive: true)
FakeBookingsApi bookingsApi(Ref ref) => FakeBookingsApi();

@Riverpod(keepAlive: true)
ClubsRepository clubsRepository(Ref ref) =>
    ClubsRepository(ref.watch(clubsApiProvider));

@Riverpod(keepAlive: true)
BookingsRepository bookingsRepository(Ref ref) => BookingsRepository(
      ref.watch(bookingsApiProvider),
      BookingsLocalDatasource(ref.watch(sharedPreferencesProvider)),
    );

@Riverpod(keepAlive: true)
SessionLocalDatasource sessionLocalDatasource(Ref ref) =>
    SessionLocalDatasource(ref.watch(sharedPreferencesProvider));

@Riverpod(keepAlive: true)
SettingsLocalDatasource settingsLocalDatasource(Ref ref) =>
    SettingsLocalDatasource(ref.watch(sharedPreferencesProvider));
