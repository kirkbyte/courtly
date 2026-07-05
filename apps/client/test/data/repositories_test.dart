import 'package:courtly_api/courtly_api.dart';
import 'package:courtly_client/data/bookings_local_datasource.dart';
import 'package:courtly_client/data/bookings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BookingsRepository repo;
  final day = DateTime(2026, 7, 10);
  final club = Seed.clubs.first; // club-1
  final court = Seed.courts.first; // court-1a, $30/hour

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repo = BookingsRepository(
      FakeBookingsApi(latency: Duration.zero),
      BookingsLocalDatasource(prefs),
    );
  });

  test('createBooking persists to local store', () async {
    await repo.createBooking(
      club: club,
      court: court,
      start: day.add(const Duration(hours: 12)),
      durationHours: 1,
      price: 30,
    );
    final mine = await repo.getMyBookings();
    expect(mine, hasLength(1));
    expect(mine.single.status, BookingStatus.active);
  });

  test('cancelBooking marks the local booking cancelled', () async {
    final booking = await repo.createBooking(
      club: club,
      court: court,
      start: day.add(const Duration(hours: 12)),
      durationHours: 1,
      price: 30,
    );
    await repo.cancelBooking(booking.id);
    final mine = await repo.getMyBookings();
    expect(mine.single.status, BookingStatus.cancelled);
  });

  test('getCourtOccupancy merges seed occupancy with my active bookings',
      () async {
    await repo.createBooking(
      club: club,
      court: court,
      start: day.add(const Duration(hours: 12)),
      durationHours: 1,
      price: 30,
    );
    final occupancy = await repo.getCourtOccupancy(court.id, day);
    // 2 seeded (10:00, 18:00) + 1 mine (12:00).
    expect(occupancy.map((b) => b.start.hour).toSet(), {10, 12, 18});
  });
}
