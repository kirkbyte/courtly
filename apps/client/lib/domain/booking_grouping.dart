import 'package:courtly_api/courtly_api.dart';

/// Splits bookings into upcoming-active vs history (past or cancelled).
({List<Booking> active, List<Booking> history}) splitBookings(
  List<Booking> all,
  DateTime now,
) {
  final active = <Booking>[];
  final history = <Booking>[];
  for (final booking in all) {
    final isUpcoming =
        booking.status == BookingStatus.active && booking.end.isAfter(now);
    (isUpcoming ? active : history).add(booking);
  }
  active.sort((a, b) => a.start.compareTo(b.start));
  history.sort((a, b) => b.start.compareTo(a.start));
  return (active: active, history: history);
}

/// Groups bookings by local calendar day, preserving input order.
Map<DateTime, List<Booking>> groupByLocalDay(List<Booking> bookings) {
  final grouped = <DateTime, List<Booking>>{};
  for (final booking in bookings) {
    final day =
        DateTime(booking.start.year, booking.start.month, booking.start.day);
    grouped.putIfAbsent(day, () => []).add(booking);
  }
  return grouped;
}
