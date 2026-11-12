import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mhabit/features/venue_discovery/page.dart';
import 'package:mhabit/routes/app_router.dart';

void main() {
  testWidgets(
    'discovery opens first and habits can return to the same search',
    (tester) async {
      final router =
          (AppRouterBuilder()
                ..addVenueDiscovery(
                  builder: (context, _) => VenueDiscoveryPage(
                    onOpenHabits: () => context.pushNamed(AppRoute.habits.name),
                  ),
                )
                ..addHabits(
                  builder: (_, _) =>
                      const Scaffold(body: Text('Health routines')),
                ))
              .build(
                initialLocation: '/explore',
                rootBuilder: (_, _, child) => child,
              );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      expect(find.text('Where can I go?'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('venue-search')), 'Moka');
      await tester.tap(find.byTooltip('My health routines'));
      await tester.pumpAndSettle();
      expect(find.text('Health routines'), findsOneWidget);
      router.pop();
      await tester.pumpAndSettle();
      expect(find.text('Moka'), findsOneWidget);
      expect(find.text('Palm Courtyard Café'), findsOneWidget);
    },
  );
}
