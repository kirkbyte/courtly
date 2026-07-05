import 'dart:math';

import 'models.dart';
import 'seed.dart';

abstract interface class BookingsApi {
  /// Bookings by other users for [courtId] on [day] — drives slot
  /// availability.
  Future<List<Booking>> fetchCourtOccupancy(String courtId, DateTime day);

  Future<Booking> createBooking({
    required Club club,
    required Court court,
    required DateTime start,
    required int durationHours,
    required double price,
  });

  Future<void> cancelBooking(String id);
}

/// Simulates the network round-trip only. The user's own bookings are owned
/// and persisted by BookingsRepository + BookingsLocalDatasource in the app;
/// with a real backend the server would own that list instead.
class FakeBookingsApi implements BookingsApi {
  FakeBookingsApi({Duration? latency}) : _fixedLatency = latency;

  final Duration? _fixedLatency;
  final _random = Random(7);
  var _nextId = 1;

  bool shouldFail = false;

  Future<T> _respond<T>(T Function() body) async {
    await Future<void>.delayed(
      _fixedLatency ?? Duration(milliseconds: 300 + _random.nextInt(500)),
    );
    if (shouldFail) throw const ApiException('Simulated network failure');
    return body();
  }

  @override
  Future<List<Booking>> fetchCourtOccupancy(String courtId, DateTime day) =>
      _respond(
        () => Seed.occupancy(day).where((b) => b.courtId == courtId).toList(),
      );

  @override
  Future<Booking> createBooking({
    required Club club,
    required Court court,
    required DateTime start,
    required int durationHours,
    required double price,
  }) =>
      _respond(
        () => Booking(
          id: 'user-${_nextId++}',
          clubId: club.id,
          clubName: club.name,
          courtId: court.id,
          courtName: court.name,
          start: start,
          durationHours: durationHours,
          price: price,
          status: BookingStatus.active,
        ),
      );

  @override
  Future<void> cancelBooking(String id) => _respond(() {});
}
