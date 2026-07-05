import 'package:courtly_api/courtly_api.dart';
import 'package:courtly_client/domain/slot_availability.dart';
import 'package:flutter_test/flutter_test.dart';

Booking _booking(
  DateTime start,
  int hours, {
  BookingStatus status = BookingStatus.active,
}) =>
    Booking(
      id: 'b-${start.hour}',
      clubId: 'club-1',
      clubName: 'Ace Arena',
      courtId: 'court-1a',
      courtName: 'Court 1',
      start: start,
      durationHours: hours,
      price: 30,
      status: status,
    );

void main() {
  final club = Club(
    id: 'club-1',
    name: 'Ace Arena',
    address: '',
    rating: 4.8,
    openHour: 8,
    closeHour: 12,
    surfaces: const {Surface.hard},
    courtTypes: const {CourtType.tennis},
    hasIndoor: true,
    hasOutdoor: false,
  );
  final day = DateTime(2026, 7, 10);
  final beforeOpen = DateTime(2026, 7, 9, 23);

  test('builds one slot per hour within opening hours', () {
    final slots =
        buildDaySlots(club: club, day: day, occupancy: const [], now: beforeOpen);
    expect(slots.map((s) => s.start.hour).toList(), [8, 9, 10, 11]);
    expect(slots.every((s) => s.isAvailable), isTrue);
  });

  test('slots overlapped by an active booking are unavailable', () {
    final slots = buildDaySlots(
      club: club,
      day: day,
      occupancy: [_booking(day.add(const Duration(hours: 9)), 2)],
      now: beforeOpen,
    );
    expect(slots.map((s) => s.isAvailable).toList(), [true, false, false, true]);
  });

  test('cancelled bookings do not block slots', () {
    final slots = buildDaySlots(
      club: club,
      day: day,
      occupancy: [
        _booking(day.add(const Duration(hours: 9)), 2,
            status: BookingStatus.cancelled),
      ],
      now: beforeOpen,
    );
    expect(slots.every((s) => s.isAvailable), isTrue);
  });

  test('slots in the past are unavailable', () {
    final slots = buildDaySlots(
      club: club,
      day: day,
      occupancy: const [],
      now: DateTime(2026, 7, 10, 9, 30),
    );
    expect(slots.map((s) => s.isAvailable).toList(), [false, false, true, true]);
  });

  test('canFit requires consecutive available slots', () {
    final slots = buildDaySlots(
      club: club,
      day: day,
      occupancy: [_booking(day.add(const Duration(hours: 10)), 1)],
      now: beforeOpen,
    );
    final nine = slots.firstWhere((s) => s.start.hour == 9);
    expect(canFit(slot: nine, durationHours: 1, daySlots: slots), isTrue);
    expect(canFit(slot: nine, durationHours: 2, daySlots: slots), isFalse);
    final eleven = slots.firstWhere((s) => s.start.hour == 11);
    // 2 hours starting at 11 would run past closing (12).
    expect(canFit(slot: eleven, durationHours: 2, daySlots: slots), isFalse);
  });
}
