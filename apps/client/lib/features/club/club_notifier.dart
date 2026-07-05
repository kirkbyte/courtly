import 'package:courtly_api/courtly_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/di.dart';

part 'club_notifier.g.dart';

typedef ClubDetails = ({Club club, List<Court> courts});

@riverpod
class ClubNotifier extends _$ClubNotifier {
  @override
  Future<ClubDetails> build(String clubId) async {
    final repo = ref.watch(clubsRepositoryProvider);
    final club = await repo.getClub(clubId);
    final courts = await repo.getCourts(clubId);
    return (club: club, courts: courts);
  }

  void retry() => ref.invalidateSelf();
}
