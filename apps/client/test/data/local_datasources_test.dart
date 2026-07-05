import 'package:courtly_api/courtly_api.dart';
import 'package:courtly_client/data/bookings_local_datasource.dart';
import 'package:courtly_client/data/session_local_datasource.dart';
import 'package:courtly_client/data/settings_local_datasource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  test('session round-trip and clear', () async {
    final ds = SessionLocalDatasource(prefs);
    expect(ds.readUserName(), isNull);
    await ds.saveUserName('Alex Morgan');
    expect(ds.readUserName(), 'Alex Morgan');
    await ds.clear();
    expect(ds.readUserName(), isNull);
  });

  test('settings round-trip with defaults', () async {
    final ds = SettingsLocalDatasource(prefs);
    expect(ds.readThemeMode(), ThemeMode.system);
    await ds.saveThemeMode(ThemeMode.dark);
    expect(ds.readThemeMode(), ThemeMode.dark);
    expect(ds.readLocaleCode(), isNull);
    await ds.saveLocaleCode('ru');
    expect(ds.readLocaleCode(), 'ru');
    expect(ds.readNotifications(), isTrue);
    await ds.saveNotifications(false);
    expect(ds.readNotifications(), isFalse);
  });

  test('bookings survive a re-read (restart simulation)', () async {
    final booking = Booking(
      id: 'b1',
      clubId: 'c1',
      clubName: 'Ace',
      courtId: 'ct1',
      courtName: 'Court 1',
      start: DateTime(2026, 7, 10, 18),
      durationHours: 1,
      price: 30,
      status: BookingStatus.active,
    );
    await BookingsLocalDatasource(prefs).saveBookings([booking]);
    final reread = BookingsLocalDatasource(prefs).readBookings();
    expect(reread, [booking]);
  });
}
