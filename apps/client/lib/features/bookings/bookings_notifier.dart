import 'package:courtly_api/courtly_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/di.dart';
import '../../domain/booking_grouping.dart';

part 'bookings_notifier.g.dart';

typedef BookingsState = ({List<Booking> active, List<Booking> history});

@riverpod
class BookingsNotifier extends _$BookingsNotifier {
  @override
  Future<BookingsState> build() async {
    final all = await ref.watch(bookingsRepositoryProvider).getMyBookings();
    return splitBookings(all, DateTime.now());
  }

  Future<void> cancel(String id) async {
    await ref.read(bookingsRepositoryProvider).cancelBooking(id);
    ref.invalidateSelf();
    await future;
  }

  Future<void> clearAll() async {
    await ref.read(bookingsRepositoryProvider).clearAll();
    ref.invalidateSelf();
  }

  void retry() => ref.invalidateSelf();
}
