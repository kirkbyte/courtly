import 'package:courtly_core/courtly_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'slot_grid_notifier.dart';

/// Returns true if the user confirmed.
Future<bool?> showConfirmBookingSheet(
  BuildContext context,
  SlotGridState state,
) {
  final l10n = context.l10n;
  final locale = Localizations.localeOf(context).toString();
  final when = DateFormat.MMMEd(locale).add_Hm().format(state.selected!.start);
  return showModalBottomSheet<bool>(
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
              l10n.confirmBookingTitle,
              style: sheetContext.appTextStyles.title,
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              '${state.club.name} · ${state.court.name}',
              style: sheetContext.appTextStyles.body,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '$when · ${l10n.durationHours(state.durationHours)}',
              style: sheetContext.appTextStyles.bodySecondary,
            ),
            const SizedBox(height: AppSpacing.m),
            Container(
              padding: const EdgeInsets.only(top: AppSpacing.s),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: sheetContext.appColors.outline),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.total, style: sheetContext.appTextStyles.body),
                  Text(
                    '\$${state.totalPrice!.toStringAsFixed(0)}',
                    style: sheetContext.appTextStyles.price,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            FilledButton(
              onPressed: () => Navigator.of(sheetContext).pop(true),
              child: Text(l10n.confirmBookingButton),
            ),
          ],
        ),
      ),
    ),
  );
}
