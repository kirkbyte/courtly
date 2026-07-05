import 'package:courtly_api/courtly_api.dart';
import 'package:courtly_client/app/di.dart';
import 'package:courtly_client/data/bookings_local_datasource.dart';
import 'package:courtly_client/features/bookings/bookings_screen.dart';
import 'package:courtly_core/courtly_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('active booking shows, cancel flow moves it to history',
      (tester) async {
    final start = DateTime.now().add(const Duration(days: 1));
    final booking = Booking(
      id: 'b1',
      clubId: 'club-1',
      clubName: 'Ace Arena',
      courtId: 'court-1a',
      courtName: 'Court 1',
      start: DateTime(start.year, start.month, start.day, 12),
      durationHours: 1,
      price: 30,
      status: BookingStatus.active,
    );
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    // Pre-seed the local store through the datasource used by the app.
    await BookingsLocalDatasource(prefs).saveBookings([booking]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          bookingsApiProvider
              .overrideWithValue(FakeBookingsApi(latency: Duration.zero)),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const BookingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Ace Arena'), findsOneWidget);

    await tester.tap(find.text('Cancel booking'));
    await tester.pumpAndSettle();
    // The sheet's destructive confirm reuses the same label.
    await tester.tap(find.text('Cancel booking').last);
    await tester.pumpAndSettle();

    // Active tab is now empty; the booking lives in History as cancelled.
    expect(find.textContaining('No bookings yet'), findsOneWidget);
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.text('Ace Arena'), findsOneWidget);
    expect(find.text('Cancelled'), findsOneWidget);
  });
}
