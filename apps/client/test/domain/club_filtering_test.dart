import 'package:courtly_api/courtly_api.dart';
import 'package:courtly_client/domain/club_filtering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final clubs = Seed.clubs;

  test('empty filters return all clubs', () {
    expect(applyClubFilters(clubs, const ClubFilters()), hasLength(clubs.length));
  });

  test('filters by surface, court type and placement together', () {
    final filtered = applyClubFilters(
      clubs,
      const ClubFilters(
        surface: Surface.grass,
        courtType: CourtType.padel,
        indoor: true,
      ),
    );
    // Only club-3 (Grand Slam) and club-5 (Baseline) have grass+padel+indoor.
    expect(filtered.map((c) => c.id).toList(), ['club-3', 'club-5']);
  });

  test('copyWith can reset a field to null', () {
    const filters = ClubFilters(surface: Surface.clay);
    expect(filters.copyWith(surface: null).surface, isNull);
    expect(filters.copyWith().surface, Surface.clay);
  });
}
