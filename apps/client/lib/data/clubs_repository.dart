import 'package:courtly_api/courtly_api.dart';

/// Thin pass-through today; the seam where caching/mapping would live with
/// a real backend. Depends on the abstract ClubsApi only.
class ClubsRepository {
  ClubsRepository(this._api);

  final ClubsApi _api;

  Future<List<Club>> getClubs() => _api.fetchClubs();

  Future<Club> getClub(String id) => _api.fetchClub(id);

  Future<List<Court>> getCourts(String clubId) => _api.fetchCourts(clubId);
}
