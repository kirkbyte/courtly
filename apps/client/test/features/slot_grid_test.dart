import 'package:courtly_api/courtly_api.dart';
import 'package:courtly_client/app/di.dart';
import 'package:courtly_client/features/booking/slot_grid_screen.dart';
import 'package:courtly_core/courtly_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('seed-occupied slot is disabled, confirm needs a selection',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          clubsApiProvider
              .overrideWithValue(FakeClubsApi(latency: Duration.zero)),
          bookingsApiProvider
              .overrideWithValue(FakeBookingsApi(latency: Duration.zero)),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SlotGridScreen(clubId: 'club-1', courtId: 'court-1a'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Seeded occupancy blocks 10:00 on every court, every day — including
    // today, regardless of the current time.
    final tenOClock = find.text('10:00');
    await tester.scrollUntilVisible(
      tenOClock,
      200,
      scrollable: find.byType(Scrollable).last,
    );
    // Tapping a booked slot selects nothing: the confirm button stays
    // disabled. 'Book now' is l10n.confirmBookingButton (test runs in
    // English).
    await tester.tap(tenOClock, warnIfMissed: false);
    await tester.pump();
    final confirmButton = find.widgetWithText(FilledButton, 'Book now');
    expect(tester.widget<FilledButton>(confirmButton).onPressed, isNull);
  });
}
