import 'package:courtly_api/courtly_api.dart';
import 'package:test/test.dart';

void main() {
  late FakeBookingsApi api;
  final day = DateTime(2026, 7, 10);

  setUp(() => api = FakeBookingsApi(latency: Duration.zero));

  test('fetchCourtOccupancy returns seeded bookings for the court and day',
      () async {
    final occupancy = await api.fetchCourtOccupancy('court-1a', day);
    expect(occupancy, hasLength(2));
    expect(occupancy.every((b) => b.courtId == 'court-1a'), isTrue);
    expect(occupancy.map((b) => b.start.hour).toList(), [10, 18]);
  });

  test('createBooking returns a booking with a unique id and active status',
      () async {
    final club = Seed.clubs.first;
    final court = Seed.courts.first;
    final b1 = await api.createBooking(
      club: club,
      court: court,
      start: day.add(const Duration(hours: 12)),
      durationHours: 1,
      price: 30,
    );
    final b2 = await api.createBooking(
      club: club,
      court: court,
      start: day.add(const Duration(hours: 14)),
      durationHours: 2,
      price: 60,
    );
    expect(b1.id, isNot(b2.id));
    expect(b1.status, BookingStatus.active);
    expect(b2.durationHours, 2);
  });

  test('shouldFail makes calls throw ApiException', () {
    api.shouldFail = true;
    expect(
      () => api.fetchCourtOccupancy('court-1a', day),
      throwsA(isA<ApiException>()),
    );
  });
}
