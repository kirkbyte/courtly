import 'package:courtly_api/courtly_api.dart';
import 'package:test/test.dart';

void main() {
  final booking = Booking(
    id: 'b1',
    clubId: 'c1',
    clubName: 'Ace Arena',
    courtId: 'ct1',
    courtName: 'Court 1',
    start: DateTime(2026, 7, 10, 18),
    durationHours: 2,
    price: 60,
    status: BookingStatus.active,
  );

  test('Booking JSON round-trip preserves all fields', () {
    final restored = Booking.fromJson(booking.toJson());
    expect(restored, booking);
  });

  test('copyWith changes only status', () {
    final cancelled = booking.copyWith(status: BookingStatus.cancelled);
    expect(cancelled.status, BookingStatus.cancelled);
    expect(cancelled.id, booking.id);
    expect(cancelled.start, booking.start);
  });

  test('end is start plus duration', () {
    expect(booking.end, DateTime(2026, 7, 10, 20));
  });
}
