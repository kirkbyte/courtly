import 'package:courtly_api/courtly_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/di.dart';
import '../../domain/pricing.dart';
import '../../domain/slot_availability.dart';

part 'slot_grid_notifier.g.dart';

class SlotGridState {
  const SlotGridState({
    required this.club,
    required this.court,
    required this.day,
    required this.slots,
    this.selected,
    this.durationHours = 1,
  });

  final Club club;
  final Court court;
  final DateTime day;
  final List<TimeSlot> slots;
  final TimeSlot? selected;
  final int durationHours;

  double? get totalPrice => selected == null
      ? null
      : calculatePrice(
          pricePerHour: court.pricePerHour,
          durationHours: durationHours,
        );

  bool canFitDuration(int hours) =>
      selected != null &&
      canFit(slot: selected!, durationHours: hours, daySlots: slots);

  SlotGridState copyWith({
    DateTime? day,
    List<TimeSlot>? slots,
    TimeSlot? selected,
    int? durationHours,
  }) =>
      SlotGridState(
        club: club,
        court: court,
        day: day ?? this.day,
        slots: slots ?? this.slots,
        selected: selected ?? this.selected,
        durationHours: durationHours ?? this.durationHours,
      );
}

@riverpod
class SlotGridNotifier extends _$SlotGridNotifier {
  @override
  Future<SlotGridState> build(String clubId, String courtId) =>
      _load(DateTime.now());

  Future<SlotGridState> _load(DateTime day) async {
    final clubsRepo = ref.read(clubsRepositoryProvider);
    final bookingsRepo = ref.read(bookingsRepositoryProvider);
    final club = await clubsRepo.getClub(clubId);
    final courts = await clubsRepo.getCourts(clubId);
    final court = courts.firstWhere((c) => c.id == courtId);
    final occupancy = await bookingsRepo.getCourtOccupancy(courtId, day);
    return SlotGridState(
      club: club,
      court: court,
      day: DateTime(day.year, day.month, day.day),
      slots: buildDaySlots(
        club: club,
        day: day,
        occupancy: occupancy,
        now: DateTime.now(),
      ),
    );
  }

  Future<void> selectDay(DateTime day) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load(day));
  }

  void selectSlot(TimeSlot slot) {
    final current = state.value;
    if (current == null || !slot.isAvailable) return;
    // Reset duration if the current one no longer fits at the new start.
    var next = current.copyWith(selected: slot);
    if (!next.canFitDuration(next.durationHours)) {
      next = next.copyWith(durationHours: 1);
    }
    state = AsyncData(next);
  }

  void setDuration(int hours) {
    final current = state.value;
    if (current == null || !current.canFitDuration(hours)) return;
    state = AsyncData(current.copyWith(durationHours: hours));
  }

  Future<Booking> confirm() async {
    final current = state.requireValue;
    final booking = await ref.read(bookingsRepositoryProvider).createBooking(
          club: current.club,
          court: current.court,
          start: current.selected!.start,
          durationHours: current.durationHours,
          price: current.totalPrice!,
        );
    ref.invalidateSelf();
    return booking;
  }

  void retry() => ref.invalidateSelf();
}
