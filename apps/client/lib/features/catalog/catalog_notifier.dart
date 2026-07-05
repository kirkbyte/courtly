import 'package:courtly_api/courtly_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/di.dart';
import '../../domain/club_filtering.dart';

part 'catalog_notifier.g.dart';

@riverpod
class CatalogNotifier extends _$CatalogNotifier {
  var _filters = const ClubFilters();

  ClubFilters get filters => _filters;

  @override
  Future<List<Club>> build() async {
    final clubs = await ref.watch(clubsRepositoryProvider).getClubs();
    return applyClubFilters(clubs, _filters);
  }

  Future<void> setFilters(ClubFilters filters) async {
    _filters = filters;
    ref.invalidateSelf();
    await future;
  }

  void retry() => ref.invalidateSelf();
}
