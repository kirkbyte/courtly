import 'package:courtly_api/courtly_api.dart';
import 'package:courtly_client/app/di.dart';
import 'package:courtly_client/features/catalog/catalog_screen.dart';
import 'package:courtly_client/features/catalog/filters_sheet.dart';
import 'package:courtly_core/courtly_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(FakeClubsApi api) => ProviderScope(
      overrides: [clubsApiProvider.overrideWithValue(api)],
      child: MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CatalogScreen(),
      ),
    );

void main() {
  testWidgets('catalog shows skeleton, then the seeded clubs', (tester) async {
    await tester.pumpWidget(_app(FakeClubsApi(latency: Duration.zero)));
    expect(find.byType(AppListSkeleton), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Ace Arena'), findsOneWidget);
    // Further cards are built lazily — scroll until the third club appears.
    await tester.scrollUntilVisible(
      find.text('Grand Slam Center'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Grand Slam Center'), findsOneWidget);
  });

  testWidgets('catalog shows error view with retry when api fails',
      (tester) async {
    final api = FakeClubsApi(latency: Duration.zero)..shouldFail = true;
    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);

    api.shouldFail = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Ace Arena'), findsOneWidget);
  });

  testWidgets('quick Padel chip narrows the list', (tester) async {
    await tester.pumpWidget(_app(FakeClubsApi(latency: Duration.zero)));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(AppChoiceChip, 'Padel'));
    await tester.pumpAndSettle();
    // Tennis-only clubs disappear; padel clubs stay.
    expect(find.text('Ace Arena'), findsNothing);
    expect(find.text('Padel Point'), findsOneWidget);
  });
}
