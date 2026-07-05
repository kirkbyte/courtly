import 'package:courtly_api/courtly_api.dart';

/// One bookable hour on a court's day grid.
class TimeSlot {
  const TimeSlot({required this.start, required this.isAvailable});

  final DateTime start;
  final bool isAvailable;
}

/// Builds the hourly grid for [day] within the club's opening hours.
/// A slot is unavailable if it overlaps an active booking in [occupancy]
/// or has already started relative to [now].
List<TimeSlot> buildDaySlots({
  required Club club,
  required DateTime day,
  required List<Booking> occupancy,
  required DateTime now,
}) {
  final active = occupancy.where((b) => b.status == BookingStatus.active);
  return [
    for (var hour = club.openHour; hour < club.closeHour; hour++)
      _slotFor(DateTime(day.year, day.month, day.day, hour), active, now),
  ];
}

TimeSlot _slotFor(DateTime start, Iterable<Booking> active, DateTime now) {
  final end = start.add(const Duration(hours: 1));
  final booked =
      active.any((b) => b.start.isBefore(end) && b.end.isAfter(start));
  return TimeSlot(start: start, isAvailable: !booked && start.isAfter(now));
}

/// Whether [durationHours] consecutive available slots exist starting at
/// [slot].
bool canFit({
  required TimeSlot slot,
  required int durationHours,
  required List<TimeSlot> daySlots,
}) {
  final startIndex = daySlots.indexWhere((s) => s.start == slot.start);
  if (startIndex < 0 || startIndex + durationHours > daySlots.length) {
    return false;
  }
  return daySlots
      .sublist(startIndex, startIndex + durationHours)
      .every((s) => s.isAvailable);
}
