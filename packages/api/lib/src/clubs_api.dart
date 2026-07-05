import 'dart:math';

import 'models.dart';
import 'seed.dart';

abstract interface class ClubsApi {
  Future<List<Club>> fetchClubs();
  Future<Club> fetchClub(String id);
  Future<List<Court>> fetchCourts(String clubId);
}

class FakeClubsApi implements ClubsApi {
  /// [latency] overrides the default random 300–800 ms delay (tests pass
  /// [Duration.zero]).
  FakeClubsApi({Duration? latency}) : _fixedLatency = latency;

  final Duration? _fixedLatency;
  final _random = Random(42);

  /// When true, every call throws [ApiException] — used to demo/test the
  /// error state of screens.
  bool shouldFail = false;

  Future<T> _respond<T>(T Function() body) async {
    await Future<void>.delayed(
      _fixedLatency ?? Duration(milliseconds: 300 + _random.nextInt(500)),
    );
    if (shouldFail) throw const ApiException('Simulated network failure');
    return body();
  }

  @override
  Future<List<Club>> fetchClubs() => _respond(() => List.of(Seed.clubs));

  @override
  Future<Club> fetchClub(String id) => _respond(
        () => Seed.clubs.firstWhere(
          (c) => c.id == id,
          orElse: () => throw ApiException('Club not found: $id'),
        ),
      );

  @override
  Future<List<Court>> fetchCourts(String clubId) => _respond(
        () => Seed.courts.where((c) => c.clubId == clubId).toList(),
      );
}
