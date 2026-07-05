import 'package:courtly_api/courtly_api.dart';
import 'package:courtly_client/domain/booking_grouping.dart';
import 'package:flutter_test/flutter_test.dart';

Booking _b(
  String id,
  DateTime start, {
  BookingStatus status = BookingStatus.active,
}) =>
    Booking(
      id: id,
      clubId: 'c',
      clubName: 'C',
      courtId: 'ct',
      courtName: 'Ct',
      start: start,
      durationHours: 1,
      price: 10,
      status: status,
    );

void main() {
  final now = DateTime(2026, 7, 10, 12);

  test('splitBookings: future active go to active, sorted ascending', () {
    final result = splitBookings([
      _b('late', DateTime(2026, 7, 12, 10)),
      _b('soon', DateTime(2026, 7, 10, 15)),
    ], now);
    expect(result.active.map((b) => b.id).toList(), ['soon', 'late']);
    expect(result.history, isEmpty);
  });

  test('splitBookings: past and cancelled go to history, sorted descending',
      () {
    final result = splitBookings([
      _b('past', DateTime(2026, 7, 9, 10)),
      _b('cancelled', DateTime(2026, 7, 11, 10),
          status: BookingStatus.cancelled),
    ], now);
    expect(result.active, isEmpty);
    expect(result.history.map((b) => b.id).toList(), ['cancelled', 'past']);
  });

  test('groupByLocalDay groups by calendar day', () {
    final grouped = groupByLocalDay([
      _b('a', DateTime(2026, 7, 10, 9)),
      _b('b', DateTime(2026, 7, 10, 20)),
      _b('c', DateTime(2026, 7, 11, 9)),
    ]);
    expect(grouped.keys.toList(), [DateTime(2026, 7, 10), DateTime(2026, 7, 11)]);
    expect(
      grouped[DateTime(2026, 7, 10)]!.map((b) => b.id).toList(),
      ['a', 'b'],
    );
  });
}
