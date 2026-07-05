import 'package:courtly_core/courtly_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/slot_availability.dart';
import '../catalog/filters_sheet.dart';
import 'confirm_booking_sheet.dart';
import 'slot_grid_notifier.dart';

class SlotGridScreen extends ConsumerWidget {
  const SlotGridScreen({
    super.key,
    required this.clubId,
    required this.courtId,
  });

  final String clubId;
  final String courtId;

  Future<void> _confirm(
    BuildContext context,
    WidgetRef ref,
    SlotGridState state,
  ) async {
    final confirmed = await showConfirmBookingSheet(context, state);
    if (confirmed != true || !context.mounted) return;
    await ref.read(slotGridProvider(clubId, courtId).notifier).confirm();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.bookingCreated)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final provider = slotGridProvider(clubId, courtId);
    final gridState = ref.watch(provider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.slotGridTitle)),
      body: switch (gridState) {
        AsyncData(:final value) => _Body(
            state: value,
            onDay: (d) => ref.read(provider.notifier).selectDay(d),
            onSlot: (s) => ref.read(provider.notifier).selectSlot(s),
            onDuration: (h) => ref.read(provider.notifier).setDuration(h),
            onConfirm: () => _confirm(context, ref, value),
          ),
        AsyncError() => AppErrorView(
            onRetry: () => ref.read(provider.notifier).retry(),
          ),
        _ => const AppListSkeleton(itemHeight: 56),
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.state,
    required this.onDay,
    required this.onSlot,
    required this.onDuration,
    required this.onConfirm,
  });

  final SlotGridState state;
  final ValueChanged<DateTime> onDay;
  final ValueChanged<TimeSlot> onSlot;
  final ValueChanged<int> onDuration;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final today = DateTime.now();
    final days = [
      for (var i = 0; i < 7; i++)
        DateTime(today.year, today.month, today.day + i),
    ];
    final hasAvailable = state.slots.any((s) => s.isAvailable);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l,
            0,
            AppSpacing.l,
            AppSpacing.m,
          ),
          child: _DayPicker(days: days, selected: state.day, onDay: onDay),
        ),
        Expanded(
          child: !hasAvailable
              ? AppEmptyView(message: l10n.slotGridEmpty, icon: Icons.event_busy)
              : GridView.count(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.l,
                    0,
                    AppSpacing.l,
                    AppSpacing.m,
                  ),
                  crossAxisCount: 4,
                  mainAxisSpacing: AppSpacing.s,
                  crossAxisSpacing: AppSpacing.s,
                  childAspectRatio: 1.8,
                  children: [
                    for (final slot in state.slots)
                      _SlotCell(
                        slot: slot,
                        isSelected: slot.start == state.selected?.start,
                        onTap: slot.isAvailable ? () => onSlot(slot) : null,
                      ),
                  ],
                ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: colors.outline)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      for (final hours in [1, 2]) ...[
                        Opacity(
                          opacity: state.selected == null ||
                                  state.canFitDuration(hours)
                              ? 1
                              : 0.4,
                          child: AppChoiceChip(
                            label: l10n.durationHours(hours),
                            selected: state.durationHours == hours,
                            onTap: () => onDuration(hours),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.m - AppSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.total,
                        style: context.appTextStyles.bodySecondary,
                      ),
                      Text(
                        state.totalPrice == null
                            ? '—'
                            : '\$${state.totalPrice!.toStringAsFixed(0)}',
                        style: context.appTextStyles.price,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.m - AppSpacing.xs),
                  FilledButton(
                    onPressed: state.selected == null ? null : onConfirm,
                    child: Text(l10n.confirmBookingButton),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Segmented 7-day picker from the design: surfaceAlt pill, primary segment
/// for the selected day.
class _DayPicker extends StatelessWidget {
  const _DayPicker({
    required this.days,
    required this.selected,
    required this.onDay,
  });

  final List<DateTime> days;
  final DateTime selected;
  final ValueChanged<DateTime> onDay;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final locale = Localizations.localeOf(context).toString();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.m + AppSpacing.xs),
      ),
      child: Row(
        children: [
          for (final day in days)
            Expanded(
              child: _DaySegment(
                day: day,
                isSelected: day == selected,
                dowLabel: DateFormat.E(locale).format(day),
                onTap: () => onDay(day),
              ),
            ),
        ],
      ),
    );
  }
}

class _DaySegment extends StatelessWidget {
  const _DaySegment({
    required this.day,
    required this.isSelected,
    required this.dowLabel,
    required this.onTap,
  });

  final DateTime day;
  final bool isSelected;
  final String dowLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final foreground = isSelected ? colors.onPrimary : colors.textSecondary;
    return Material(
      color: isSelected ? colors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.m),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.m),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
          child: Column(
            children: [
              Text(
                dowLabel,
                style:
                    context.appTextStyles.label.copyWith(color: foreground),
              ),
              const SizedBox(height: AppSpacing.xs / 2),
              Text(
                '${day.day}',
                style: context.appTextStyles.label.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlotCell extends StatelessWidget {
  const _SlotCell({
    required this.slot,
    required this.isSelected,
    this.onTap,
  });

  final TimeSlot slot;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final unavailable = !slot.isAvailable;
    final background = unavailable
        ? colors.surfaceAlt
        : isSelected
            ? colors.primary
            : colors.surface;
    final textColor = unavailable
        ? colors.textSecondary
        : isSelected
            ? colors.onPrimary
            : colors.textPrimary;
    return Material(
      color: background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.s),
        side: unavailable || isSelected
            ? BorderSide.none
            : BorderSide(color: colors.outline),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.s),
        onTap: onTap,
        child: Center(
          child: Text(
            '${slot.start.hour.toString().padLeft(2, '0')}:00',
            style: context.appTextStyles.bodySecondary.copyWith(
              fontWeight: unavailable ? FontWeight.w400 : FontWeight.w500,
              color: textColor,
              decoration: unavailable ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
      ),
    );
  }
}
