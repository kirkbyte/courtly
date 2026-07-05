import 'dart:convert';

import 'package:courtly_api/courtly_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's bookings so they survive app restarts (the fake API
/// is in-memory). With a real backend this becomes an offline cache.
class BookingsLocalDatasource {
  BookingsLocalDatasource(this._prefs);

  static const _keyBookings = 'bookings.list';

  final SharedPreferences _prefs;

  List<Booking> readBookings() {
    final raw = _prefs.getString(_keyBookings);
    if (raw == null) return const [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => Booking.fromJson((e as Map).cast<String, Object?>()))
        .toList();
  }

  Future<void> saveBookings(List<Booking> bookings) => _prefs.setString(
        _keyBookings,
        jsonEncode([for (final b in bookings) b.toJson()]),
      );
}
