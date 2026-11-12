import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/features/venue_discovery/page.dart';
import 'package:mhabit/features/venue_discovery/venue.dart';

void main() {
  test(
    'unknown and limited access never pass an affirmative access filter',
    () {
      final results = sampleVenueCatalog.search(
        stepFreeOnly: true,
        accessibleToiletOnly: true,
      );
      expect(results.map((v) => v.id), ['sample-gallery']);
      expect(
        sampleVenueCatalog.search(query: 'EBENE').single.id,
        'sample-garden',
      );
      expect(
        sampleVenueCatalog.search(query: 'cafe moka').single.id,
        'sample-cafe',
      );
      expect(sampleVenueCatalog.search(query: 'no such venue'), isEmpty);
    },
  );

  test('fictional venues cannot open directions even with coordinates', () {
    const venue = Venue(
      id: 'sample',
      name: 'Example',
      area: 'Moka',
      category: 'Café',
      entrance: VenueAccess.unknown,
      toilet: VenueAccess.unknown,
      description: '',
      parking: 'Unknown',
      assistance: 'Unknown',
      source: 'Example',
      isSample: true,
      latitude: -20,
      longitude: 57,
    );
    expect(venue.directionsUri, isNull);
    const real = Venue(
      id: 'real',
      name: 'A & B',
      area: 'Moka',
      category: 'Café',
      entrance: VenueAccess.unknown,
      toilet: VenueAccess.unknown,
      description: '',
      parking: 'Unknown',
      assistance: 'Unknown',
      source: 'Visitor',
      latitude: -20,
      longitude: 57,
    );
    expect(real.directionsUri?.queryParameters['q'], 'A & B');
    expect(real.directionsUri?.queryParameters['daddr'], '-20.0,57.0');
  });

  testWidgets(
    'search, filter, open details and return without a planning flow',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: VenueDiscoveryPage()));
      await tester.enterText(find.byKey(const Key('venue-search')), 'Moka');
      await tester.pumpAndSettle();
      expect(find.text('Palm Courtyard Café'), findsOneWidget);
      expect(find.text('Island Garden'), findsNothing);
      await tester.ensureVisible(find.text('Palm Courtyard Café'));
      await tester.tap(find.text('Palm Courtyard Café'));
      await tester.pumpAndSettle();
      expect(find.text('Access at a glance'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const Key('venue-directions')),
        300,
      );
      final directions = tester.widget<FilledButton>(
        find.byKey(const Key('venue-directions')),
      );
      expect(directions.onPressed, isNull);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Moka'), findsOneWidget);
      await tester.tap(find.byTooltip('Clear search'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Accessible toilet'));
      await tester.pumpAndSettle();
      expect(find.text('Lagoon Gallery'), findsOneWidget);
      expect(find.text('Palm Courtyard Café'), findsNothing);
    },
  );

  testWidgets('empty search can be reset at large text scale', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: const VenueDiscoveryPage(),
        ),
      ),
    );
    await tester.enterText(find.byKey(const Key('venue-search')), 'xyz');
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Clear search and filters'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Clear search and filters'));
    await tester.pumpAndSettle();
    expect(find.text('4 places to preview'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
