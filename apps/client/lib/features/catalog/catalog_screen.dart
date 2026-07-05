import 'package:courtly_api/courtly_api.dart';
import 'package:courtly_core/courtly_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/club_filtering.dart';
import 'catalog_notifier.dart';
import 'filters_sheet.dart';

class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({super.key});

  Future<void> _openFilters(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(catalogProvider.notifier);
    final updated = await showFiltersSheet(context, notifier.filters);
    if (updated != null) await notifier.setFilters(updated);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final clubs = ref.watch(catalogProvider);
    final filters = ref.read(catalogProvider.notifier).filters;
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
                AppSpacing.m,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.catalogTitle,
                      style: context.appTextStyles.headline),
                  AppTonalButton(
                    onPressed: () => _openFilters(context, ref),
                    child: Text(l10n.filtersTitle),
                  ),
                ],
              ),
            ),
            _QuickFilters(
              filters: filters,
              onChanged: (f) =>
                  ref.read(catalogProvider.notifier).setFilters(f),
            ),
            const SizedBox(height: AppSpacing.m),
            Expanded(
              child: switch (clubs) {
                AsyncData(:final value) when value.isEmpty =>
                  AppEmptyView(message: l10n.catalogEmpty),
                AsyncData(:final value) => ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.l,
                      0,
                      AppSpacing.l,
                      AppSpacing.m,
                    ),
                    itemCount: value.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.m),
                    itemBuilder: (context, index) =>
                        _ClubCard(club: value[index]),
                  ),
                AsyncError() => AppErrorView(
                    onRetry: () => ref.read(catalogProvider.notifier).retry(),
                  ),
                _ => const AppListSkeleton(itemHeight: 240),
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Quick presets from the design header: All / Tennis / Padel / Indoor.
class _QuickFilters extends StatelessWidget {
  const _QuickFilters({required this.filters, required this.onChanged});

  final ClubFilters filters;
  final ValueChanged<ClubFilters> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
        children: [
          AppChoiceChip(
            label: l10n.filterAll,
            selected: filters.isEmpty,
            onTap: () => onChanged(const ClubFilters()),
          ),
          const SizedBox(width: AppSpacing.s),
          AppChoiceChip(
            label: l10n.courtTypeTennis,
            selected: filters.courtType == CourtType.tennis,
            onTap: () =>
                onChanged(filters.copyWith(courtType: CourtType.tennis)),
          ),
          const SizedBox(width: AppSpacing.s),
          AppChoiceChip(
            label: l10n.courtTypePadel,
            selected: filters.courtType == CourtType.padel,
            onTap: () =>
                onChanged(filters.copyWith(courtType: CourtType.padel)),
          ),
          const SizedBox(width: AppSpacing.s),
          AppChoiceChip(
            label: l10n.placementIndoor,
            selected: filters.indoor == true,
            onTap: () => onChanged(filters.copyWith(indoor: true)),
          ),
        ],
      ),
    );
  }
}

class _ClubCard extends StatelessWidget {
  const _ClubCard({required this.club});

  final Club club;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.m),
        side: BorderSide(color: colors.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/clubs/${club.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 140,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ColoredBox(
                      color: colors.surfaceAlt,
                      child: Center(
                        child: Text(
                          club.name.characters.first,
                          style: context.appTextStyles.headline
                              .copyWith(color: colors.primary),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: AppSpacing.s,
                    right: AppSpacing.s,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s + AppSpacing.xs / 2,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.s),
                      ),
                      child: Text(
                        l10n.ratingLabel(club.rating.toStringAsFixed(1)),
                        style: context.appTextStyles.bodySecondary.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(club.name, style: context.appTextStyles.title),
                  const SizedBox(height: AppSpacing.s),
                  Text(club.address,
                      style: context.appTextStyles.bodySecondary),
                  const SizedBox(height: AppSpacing.s),
                  Wrap(
                    spacing: AppSpacing.s,
                    runSpacing: AppSpacing.s,
                    children: [
                      for (final type in club.courtTypes)
                        AppTag(text: courtTypeLabel(context, type)),
                      for (final surface in club.surfaces)
                        AppTag(text: surfaceLabel(context, surface)),
                      if (club.hasIndoor) AppTag(text: l10n.placementIndoor),
                      if (club.hasOutdoor) AppTag(text: l10n.placementOutdoor),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Static tag from the design: surfaceAlt background, label style, radius 8.
class AppTag extends StatelessWidget {
  const AppTag({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s + AppSpacing.xs,
        vertical: AppSpacing.xs + AppSpacing.xs / 2,
      ),
      decoration: BoxDecoration(
        color: context.appColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.s),
      ),
      child: Text(text, style: context.appTextStyles.label),
    );
  }
}
