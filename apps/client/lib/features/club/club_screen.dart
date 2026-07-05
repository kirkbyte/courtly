import 'package:courtly_api/courtly_api.dart';
import 'package:courtly_core/courtly_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../catalog/catalog_screen.dart';
import '../catalog/filters_sheet.dart';
import 'club_notifier.dart';

class ClubScreen extends ConsumerWidget {
  const ClubScreen({super.key, required this.clubId});

  final String clubId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final details = ref.watch(clubProvider(clubId));
    return Scaffold(
      appBar: AppBar(),
      body: switch (details) {
        AsyncData(:final value) => ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              0,
              AppSpacing.l,
              AppSpacing.l,
            ),
            children: [
              Container(
                height: 140,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppRadius.m),
                ),
                child: Text(
                  value.club.name.characters.first,
                  style: context.appTextStyles.headline
                      .copyWith(color: colors.primary),
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              Text(value.club.name, style: context.appTextStyles.headline),
              const SizedBox(height: AppSpacing.xs),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      value.club.address,
                      style: context.appTextStyles.bodySecondary,
                    ),
                  ),
                  Text(
                    l10n.ratingLabel(value.club.rating.toStringAsFixed(1)),
                    style: context.appTextStyles.body
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s),
              Wrap(
                spacing: AppSpacing.s,
                runSpacing: AppSpacing.s,
                children: [
                  if (value.club.hasIndoor)
                    AppTag(text: l10n.placementIndoor),
                  if (value.club.hasOutdoor)
                    AppTag(text: l10n.placementOutdoor),
                  for (final surface in value.club.surfaces)
                    AppTag(text: surfaceLabel(context, surface)),
                ],
              ),
              const SizedBox(height: AppSpacing.l),
              Text(l10n.clubCourtsTitle, style: context.appTextStyles.title),
              const SizedBox(height: AppSpacing.m),
              for (final court in value.courts) ...[
                _CourtTile(clubId: clubId, court: court),
                const SizedBox(height: AppSpacing.m),
              ],
            ],
          ),
        AsyncError() => AppErrorView(
            onRetry: () => ref.read(clubProvider(clubId).notifier).retry(),
          ),
        _ => const AppListSkeleton(itemHeight: 88),
      },
    );
  }
}

class _CourtTile extends StatelessWidget {
  const _CourtTile({required this.clubId, required this.court});

  final String clubId;
  final Court court;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final placement =
        court.isIndoor ? l10n.placementIndoor : l10n.placementOutdoor;
    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.m),
        side: BorderSide(color: colors.outline),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.m),
        onTap: () => context.go('/clubs/$clubId/courts/${court.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(court.name, style: context.appTextStyles.title),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${courtTypeLabel(context, court.type)} · '
                      '${surfaceLabel(context, court.surface)} · $placement',
                      style: context.appTextStyles.bodySecondary,
                    ),
                  ],
                ),
              ),
              Text(
                l10n.perHour('\$${court.pricePerHour.toStringAsFixed(0)}'),
                style: context.appTextStyles.price,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
