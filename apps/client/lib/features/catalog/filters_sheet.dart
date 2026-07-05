import 'package:courtly_api/courtly_api.dart';
import 'package:courtly_core/courtly_core.dart';
import 'package:flutter/material.dart';

import '../../domain/club_filtering.dart';

String surfaceLabel(BuildContext context, Surface surface) => switch (surface) {
      Surface.hard => context.l10n.surfaceHard,
      Surface.clay => context.l10n.surfaceClay,
      Surface.grass => context.l10n.surfaceGrass,
    };

String courtTypeLabel(BuildContext context, CourtType type) => switch (type) {
      CourtType.tennis => context.l10n.courtTypeTennis,
      CourtType.padel => context.l10n.courtTypePadel,
    };

/// Choice chip from the design: radius 8, primary when selected, surface with
/// outline border otherwise.
class AppChoiceChip extends StatelessWidget {
  const AppChoiceChip({
    super.key,
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
      color: selected ? colors.primary : colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.s),
        side: selected
            ? BorderSide.none
            : BorderSide(color: colors.outline),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.s),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.s,
          ),
          child: Text(
            label,
            style: context.appTextStyles.bodySecondary.copyWith(
              fontWeight: FontWeight.w500,
              color: selected ? colors.onPrimary : colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Returns the new filters, or null if dismissed.
Future<ClubFilters?> showFiltersSheet(
  BuildContext context,
  ClubFilters current,
) =>
    showModalBottomSheet<ClubFilters>(
      context: context,
      builder: (_) => _FiltersSheet(initial: current),
    );

class _FiltersSheet extends StatefulWidget {
  const _FiltersSheet({required this.initial});

  final ClubFilters initial;

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  late ClubFilters _filters = widget.initial;

  Widget _chipRow<T>({
    required String title,
    required List<T> values,
    required T? selected,
    required String Function(T) label,
    required void Function(T?) onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.appTextStyles.label),
        const SizedBox(height: AppSpacing.s),
        Wrap(
          spacing: AppSpacing.s,
          runSpacing: AppSpacing.s,
          children: [
            AppChoiceChip(
              label: context.l10n.filterAll,
              selected: selected == null,
              onTap: () => onSelected(null),
            ),
            for (final value in values)
              AppChoiceChip(
                label: label(value),
                selected: selected == value,
                onTap: () => onSelected(value),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          0,
          AppSpacing.l,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.filtersTitle, style: context.appTextStyles.title),
            const SizedBox(height: AppSpacing.m),
            _chipRow<Surface>(
              title: l10n.filterSurface,
              values: Surface.values,
              selected: _filters.surface,
              label: (s) => surfaceLabel(context, s),
              onSelected: (s) =>
                  setState(() => _filters = _filters.copyWith(surface: s)),
            ),
            const SizedBox(height: AppSpacing.m),
            _chipRow<CourtType>(
              title: l10n.filterCourtType,
              values: CourtType.values,
              selected: _filters.courtType,
              label: (t) => courtTypeLabel(context, t),
              onSelected: (t) =>
                  setState(() => _filters = _filters.copyWith(courtType: t)),
            ),
            const SizedBox(height: AppSpacing.m),
            _chipRow<bool>(
              title: l10n.filterPlacement,
              values: const [true, false],
              selected: _filters.indoor,
              label: (indoor) =>
                  indoor ? l10n.placementIndoor : l10n.placementOutdoor,
              onSelected: (v) =>
                  setState(() => _filters = _filters.copyWith(indoor: v)),
            ),
            const SizedBox(height: AppSpacing.l),
            Row(
              children: [
                Expanded(
                  child: AppTonalButton(
                    onPressed: () =>
                        setState(() => _filters = const ClubFilters()),
                    child: Text(l10n.filterReset),
                  ),
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(_filters),
                    child: Text(l10n.filterApply),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
