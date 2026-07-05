import 'package:courtly_api/courtly_api.dart';
import 'package:courtly_core/courtly_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/booking_grouping.dart';
import 'bookings_notifier.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  var _historyTab = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bookings = ref.watch(bookingsProvider);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.l,
                AppSpacing.s,
                AppSpacing.l,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.bookingsTitle,
                      style: context.appTextStyles.headline),
                  const SizedBox(height: AppSpacing.m),
                  _SegmentedTabs(
                    historySelected: _historyTab,
                    onChanged: (history) =>
                        setState(() => _historyTab = history),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Expanded(
              child: switch (bookings) {
                AsyncData(:final value) => _BookingsList(
                    bookings: _historyTab ? value.history : value.active,
                    emptyMessage: _historyTab
                        ? l10n.bookingsEmptyHistory
                        : l10n.bookingsEmptyActive,
                    canCancel: !_historyTab,
                  ),
                AsyncError() => AppErrorView(
                    onRetry: () => ref.read(bookingsProvider.notifier).retry(),
                  ),
                _ => const AppListSkeleton(itemHeight: 120),
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Segmented-control style tabs from the design (surfaceAlt track, surface
/// pill for the selected segment).
class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({
    required this.historySelected,
    required this.onChanged,
  });

  final bool historySelected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: context.appColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.s + AppSpacing.xs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Segment(
            label: l10n.bookingsTabActive,
            selected: !historySelected,
            onTap: () => onChanged(false),
          ),
          const SizedBox(width: AppSpacing.xs),
          _Segment(
            label: l10n.bookingsTabHistory,
            selected: historySelected,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: selected ? colors.surface : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.s),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.s),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.l - AppSpacing.xs,
            vertical: AppSpacing.s,
          ),
          child: Text(
            label,
            style: context.appTextStyles.bodySecondary.copyWith(
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? colors.textPrimary : colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _BookingsList extends ConsumerWidget {
  const _BookingsList({
    required this.bookings,
    required this.emptyMessage,
    required this.canCancel,
  });

  final List<Booking> bookings;
  final String emptyMessage;
  final bool canCancel;

  Future<void> _confirmCancel(
    BuildContext context,
    WidgetRef ref,
    Booking booking,
  ) async {
    final l10n = context.l10n;
    final colors = context.appColors;
    final locale = Localizations.localeOf(context).toString();
    final when = DateFormat.MMMEd(locale).add_Hm().format(booking.start);
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l,
            0,
            AppSpacing.l,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.cancelConfirmTitle,
                style: sheetContext.appTextStyles.title,
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                l10n.cancelConfirmMessage(
                  booking.courtName,
                  booking.clubName,
                  when,
                ),
                style: sheetContext.appTextStyles.bodySecondary,
              ),
              const SizedBox(height: AppSpacing.l),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: colors.danger,
                  foregroundColor: colors.onPrimary,
                ),
                onPressed: () => Navigator.of(sheetContext).pop(true),
                child: Text(l10n.cancelConfirm),
              ),
              const SizedBox(height: AppSpacing.s),
              AppTonalButton(
                onPressed: () => Navigator.of(sheetContext).pop(false),
                child: Text(l10n.cancelKeep),
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed == true) {
      await ref.read(bookingsProvider.notifier).cancel(booking.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (bookings.isEmpty) {
      return AppEmptyView(message: emptyMessage, icon: Icons.event_note);
    }
    final locale = Localizations.localeOf(context).toString();
    final grouped = groupByLocalDay(bookings);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        0,
        AppSpacing.l,
        AppSpacing.m,
      ),
      children: [
        for (final entry in grouped.entries) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
            child: Text(
              DateFormat.yMMMEd(locale).format(entry.key),
              style: context.appTextStyles.label,
            ),
          ),
          for (final booking in entry.value) ...[
            _BookingCard(
              booking: booking,
              onCancel: canCancel && booking.status == BookingStatus.active
                  ? () => _confirmCancel(context, ref, booking)
                  : null,
            ),
            const SizedBox(height: AppSpacing.s),
          ],
        ],
      ],
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking, this.onCancel});

  final Booking booking;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final time = '${booking.start.hour.toString().padLeft(2, '0')}:00 · '
        '${l10n.durationHours(booking.durationHours)}';
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.m),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child:
                    Text(booking.clubName, style: context.appTextStyles.title),
              ),
              if (booking.status == BookingStatus.cancelled)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s + AppSpacing.xs / 2,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceAlt,
                    borderRadius: BorderRadius.circular(AppRadius.s),
                  ),
                  child: Text(
                    l10n.statusCancelled,
                    style: context.appTextStyles.label,
                  ),
                )
              else
                Text(
                  '\$${booking.price.toStringAsFixed(0)}',
                  style: context.appTextStyles.price,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            '${booking.courtName} · $time',
            style: context.appTextStyles.bodySecondary,
          ),
          if (onCancel != null) ...[
            const SizedBox(height: AppSpacing.s),
            InkWell(
              borderRadius: BorderRadius.circular(AppRadius.s),
              onTap: onCancel,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Text(
                  l10n.bookingCancel,
                  style: context.appTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.danger,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
