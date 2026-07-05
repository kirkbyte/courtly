import 'package:courtly_api/courtly_api.dart';

const _unset = Object();

/// Catalog filter selection. Null field = "all".
class ClubFilters {
  const ClubFilters({this.surface, this.courtType, this.indoor});

  final Surface? surface;
  final CourtType? courtType;

  /// true = indoor only, false = outdoor only, null = any.
  final bool? indoor;

  bool get isEmpty => surface == null && courtType == null && indoor == null;

  ClubFilters copyWith({
    Object? surface = _unset,
    Object? courtType = _unset,
    Object? indoor = _unset,
  }) =>
      ClubFilters(
        surface:
            identical(surface, _unset) ? this.surface : surface as Surface?,
        courtType: identical(courtType, _unset)
            ? this.courtType
            : courtType as CourtType?,
        indoor: identical(indoor, _unset) ? this.indoor : indoor as bool?,
      );

  @override
  bool operator ==(Object other) =>
      other is ClubFilters &&
      other.surface == surface &&
      other.courtType == courtType &&
      other.indoor == indoor;

  @override
  int get hashCode => Object.hash(surface, courtType, indoor);
}

List<Club> applyClubFilters(List<Club> clubs, ClubFilters filters) => clubs
    .where(
      (club) =>
          (filters.surface == null ||
              club.surfaces.contains(filters.surface)) &&
          (filters.courtType == null ||
              club.courtTypes.contains(filters.courtType)) &&
          (filters.indoor == null ||
              (filters.indoor! ? club.hasIndoor : club.hasOutdoor)),
    )
    .toList();
