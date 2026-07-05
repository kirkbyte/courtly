import 'package:courtly_api/courtly_api.dart';
import 'package:test/test.dart';

void main() {
  late FakeClubsApi api;

  setUp(() => api = FakeClubsApi(latency: Duration.zero));

  test('fetchClubs returns the 5 seeded clubs', () async {
    final clubs = await api.fetchClubs();
    expect(clubs, hasLength(5));
    expect(clubs.map((c) => c.id).toSet(), hasLength(5));
  });

  test('fetchCourts returns only courts of the requested club', () async {
    final courts = await api.fetchCourts('club-1');
    expect(courts, isNotEmpty);
    expect(courts.every((c) => c.clubId == 'club-1'), isTrue);
  });

  test('fetchClub throws ApiException for unknown id', () {
    expect(() => api.fetchClub('nope'), throwsA(isA<ApiException>()));
  });

  test('shouldFail flag makes any call throw ApiException', () {
    api.shouldFail = true;
    expect(() => api.fetchClubs(), throwsA(isA<ApiException>()));
  });
}
