import 'package:courtly_core/courtly_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('AppErrorView shows retry and fires callback', (tester) async {
    var retried = false;
    await tester.pumpWidget(_wrap(AppErrorView(onRetry: () => retried = true)));
    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);
  });

  testWidgets('AppEmptyView shows message', (tester) async {
    await tester.pumpWidget(_wrap(const AppEmptyView(message: 'Nothing here')));
    expect(find.text('Nothing here'), findsOneWidget);
  });

  testWidgets('AppListSkeleton renders requested item count', (tester) async {
    await tester.pumpWidget(_wrap(const AppListSkeleton(itemCount: 3)));
    await tester.pump();
    expect(find.byType(AppSkeletonTile), findsNWidgets(3));
  });

  testWidgets('themes expose both token extensions', (tester) async {
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      expect(theme.extension<AppColors>(), isNotNull);
      expect(theme.extension<AppTextStyles>(), isNotNull);
    }
  });
}
