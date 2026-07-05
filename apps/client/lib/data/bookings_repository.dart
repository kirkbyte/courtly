import 'package:courtly_api/courtly_api.dart';

import 'bookings_local_datasource.dart';

/// Owns the user's bookings: the API simulates the network round-trip,
/// the local datasource makes bookings survive app restarts.
class BookingsRepository {
  BookingsRepository(this._api, this._local);

  final BookingsApi _api;
  final BookingsLocalDatasource _local;

  Future<List<Booking>> getMyBookings() async => _local.readBookings();

  Future<List<Booking>> getCourtOccupancy(String courtId, DateTime day) async {
    final remote = await _api.fetchCourtOccupancy(courtId, day);
    final sameDay = DateTime(day.year, day.month, day.day);
    final mine = _local.readBookings().where(
          (b) =>
              b.courtId == courtId &&
              b.status == BookingStatus.active &&
              DateTime(b.start.year, b.start.month, b.start.day) == sameDay,
        );
    return [...remote, ...mine];
  }

  Future<Booking> createBooking({
    required Club club,
    required Court court,
    required DateTime start,
    required int durationHours,
    required double price,
  }) async {
    final booking = await _api.createBooking(
      club: club,
      court: court,
      start: start,
      durationHours: durationHours,
      price: price,
    );
    await _local.saveBookings([..._local.readBookings(), booking]);
    return booking;
  }

  Future<void> cancelBooking(String id) async {
    await _api.cancelBooking(id);
    final updated = [
      for (final b in _local.readBookings())
        if (b.id == id) b.copyWith(status: BookingStatus.cancelled) else b,
    ];
    await _local.saveBookings(updated);
  }

  /// Wipes the local booking store — used by account deletion.
  Future<void> clearAll() => _local.saveBookings(const []);
}
