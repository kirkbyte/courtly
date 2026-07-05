import 'models.dart';

/// Deterministic fake data. Deliberately not random so screenshots and
/// tests are reproducible. Names and addresses follow the design mockups.
abstract final class Seed {
  static const clubs = <Club>[
    Club(
      id: 'club-1',
      name: 'Ace Arena',
      address: '220 Central Ave, Riverside',
      rating: 4.8,
      openHour: 7,
      closeHour: 23,
      surfaces: {Surface.hard, Surface.clay},
      courtTypes: {CourtType.tennis},
      hasIndoor: true,
      hasOutdoor: true,
    ),
    Club(
      id: 'club-2',
      name: 'Padel Point',
      address: '18 Harbor Rd, Riverside',
      rating: 4.6,
      openHour: 8,
      closeHour: 22,
      surfaces: {Surface.hard},
      courtTypes: {CourtType.padel},
      hasIndoor: true,
      hasOutdoor: false,
    ),
    Club(
      id: 'club-3',
      name: 'Grand Slam Center',
      address: '4 Stadium Way, Riverside',
      rating: 4.9,
      openHour: 6,
      closeHour: 23,
      surfaces: {Surface.hard, Surface.clay, Surface.grass},
      courtTypes: {CourtType.tennis, CourtType.padel},
      hasIndoor: true,
      hasOutdoor: true,
    ),
    Club(
      id: 'club-4',
      name: 'Riverside Racquet',
      address: '77 Bank St, Riverside',
      rating: 4.3,
      openHour: 9,
      closeHour: 21,
      surfaces: {Surface.clay},
      courtTypes: {CourtType.tennis},
      hasIndoor: false,
      hasOutdoor: true,
    ),
    Club(
      id: 'club-5',
      name: 'Baseline Club',
      address: '9 Meadow Ln, Riverside',
      rating: 4.5,
      openHour: 8,
      closeHour: 22,
      surfaces: {Surface.grass, Surface.hard},
      courtTypes: {CourtType.tennis, CourtType.padel},
      hasIndoor: true,
      hasOutdoor: true,
    ),
  ];

  static const courts = <Court>[
    Court(id: 'court-1a', clubId: 'club-1', name: 'Court 1', surface: Surface.hard, type: CourtType.tennis, isIndoor: true, pricePerHour: 30),
    Court(id: 'court-1b', clubId: 'club-1', name: 'Court 2', surface: Surface.hard, type: CourtType.tennis, isIndoor: false, pricePerHour: 24),
    Court(id: 'court-1c', clubId: 'club-1', name: 'Court 3', surface: Surface.clay, type: CourtType.tennis, isIndoor: false, pricePerHour: 26),
    Court(id: 'court-2a', clubId: 'club-2', name: 'Padel A', surface: Surface.hard, type: CourtType.padel, isIndoor: true, pricePerHour: 20),
    Court(id: 'court-2b', clubId: 'club-2', name: 'Padel B', surface: Surface.hard, type: CourtType.padel, isIndoor: true, pricePerHour: 20),
    Court(id: 'court-3a', clubId: 'club-3', name: 'Centre Court', surface: Surface.grass, type: CourtType.tennis, isIndoor: false, pricePerHour: 45),
    Court(id: 'court-3b', clubId: 'club-3', name: 'Clay 1', surface: Surface.clay, type: CourtType.tennis, isIndoor: false, pricePerHour: 32),
    Court(id: 'court-3c', clubId: 'club-3', name: 'Indoor Hard', surface: Surface.hard, type: CourtType.tennis, isIndoor: true, pricePerHour: 38),
    Court(id: 'court-3d', clubId: 'club-3', name: 'Padel Hall', surface: Surface.hard, type: CourtType.padel, isIndoor: true, pricePerHour: 22),
    Court(id: 'court-4a', clubId: 'club-4', name: 'River Clay 1', surface: Surface.clay, type: CourtType.tennis, isIndoor: false, pricePerHour: 18),
    Court(id: 'court-5a', clubId: 'club-5', name: 'Lawn 1', surface: Surface.grass, type: CourtType.tennis, isIndoor: false, pricePerHour: 28),
    Court(id: 'court-5b', clubId: 'club-5', name: 'Padel 1', surface: Surface.hard, type: CourtType.padel, isIndoor: true, pricePerHour: 21),
  ];

  /// Bookings made by "other users" for [day]: every court is taken
  /// 10:00–11:00 and 18:00–20:00. Deterministic occupancy for the slot grid.
  static List<Booking> occupancy(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return [
      for (final court in courts) ...[
        _occupied(court, d, startHour: 10, hours: 1),
        _occupied(court, d, startHour: 18, hours: 2),
      ],
    ];
  }

  static Booking _occupied(
    Court court,
    DateTime day, {
    required int startHour,
    required int hours,
  }) =>
      Booking(
        id: 'seed-${court.id}-$startHour-${day.toIso8601String()}',
        clubId: court.clubId,
        clubName: clubs.firstWhere((c) => c.id == court.clubId).name,
        courtId: court.id,
        courtName: court.name,
        start: day.add(Duration(hours: startHour)),
        durationHours: hours,
        price: court.pricePerHour * hours,
        status: BookingStatus.active,
      );
}
