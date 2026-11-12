// Licensed under the Apache License, Version 2.0. See LICENSE.

/// Unknown is distinct from a reported barrier. Never infer access from a
/// venue category or from missing map tags.
enum VenueAccess { yes, limited, no, unknown }

class Venue {
  const Venue({
    required this.id,
    required this.name,
    required this.area,
    required this.category,
    required this.entrance,
    required this.toilet,
    required this.description,
    required this.parking,
    required this.assistance,
    required this.source,
    this.checkedOn,
    this.latitude,
    this.longitude,
    this.photoUrls = const [],
    this.isSample = false,
  });

  final String id;
  final String name;
  final String area;
  final String category;
  final VenueAccess entrance;
  final VenueAccess toilet;
  final String description;
  final String parking;
  final String assistance;
  final String source;
  final DateTime? checkedOn;
  final double? latitude;
  final double? longitude;
  final List<String> photoUrls;
  final bool isSample;

  bool get canNavigate => !isSample && latitude != null && longitude != null;

  /// Open a destination only; this is not a wheelchair routing guarantee.
  Uri? get directionsUri => canNavigate
      ? Uri.https('maps.apple.com', '/', {
          'daddr': '$latitude,$longitude',
          'q': name,
        })
      : null;
}

class VenueCatalog {
  const VenueCatalog(this.venues);

  final List<Venue> venues;

  List<Venue> search({
    String query = '',
    bool stepFreeOnly = false,
    bool accessibleToiletOnly = false,
  }) {
    final terms = _normalize(
      query,
    ).split(RegExp(r'\s+')).where((s) => s.isNotEmpty);
    return venues
        .where((venue) {
          final text = _normalize(
            '${venue.name} ${venue.area} ${venue.category}',
          );
          return terms.every(text.contains) &&
              (!stepFreeOnly || venue.entrance == VenueAccess.yes) &&
              (!accessibleToiletOnly || venue.toilet == VenueAccess.yes);
        })
        .toList(growable: false);
  }

  static String _normalize(String text) => text
      .toLowerCase()
      .replaceAll('é', 'e')
      .replaceAll('è', 'e')
      .replaceAll('ê', 'e')
      .replaceAll('à', 'a')
      .replaceAll('â', 'a')
      .replaceAll('ô', 'o');
}

/// Fictional fixtures, never real venue recommendations. Replace this catalog
/// with sourced records before enabling directions or location-based discovery.
const sampleVenueCatalog = VenueCatalog([
  Venue(
    id: 'sample-cafe',
    name: 'Palm Courtyard Café',
    area: 'Moka',
    category: 'Café',
    entrance: VenueAccess.yes,
    toilet: VenueAccess.unknown,
    description:
        'An example courtyard café. This sample shows how entrance information and missing toilet details appear.',
    parking: 'Example: drop-off near the entrance',
    assistance: 'Example: assistance may be needed on the approach',
    source: 'Illustrative data',
    isSample: true,
  ),
  Venue(
    id: 'sample-garden',
    name: 'Island Garden',
    area: 'Ebene',
    category: 'Garden',
    entrance: VenueAccess.unknown,
    toilet: VenueAccess.unknown,
    description:
        'An example garden with access information still to be collected.',
    parking: 'Unknown',
    assistance: 'Unknown',
    source: 'Illustrative data',
    isSample: true,
  ),
  Venue(
    id: 'sample-gallery',
    name: 'Lagoon Gallery',
    area: 'Grand Baie',
    category: 'Gallery',
    entrance: VenueAccess.yes,
    toilet: VenueAccess.yes,
    description:
        'An example gallery showing a record with both step-free entry and toilet access reported.',
    parking: 'Example: designated parking space',
    assistance: 'Not assessed',
    source: 'Illustrative data',
    isSample: true,
  ),
  Venue(
    id: 'sample-market',
    name: 'Harbour Market',
    area: 'Port Louis',
    category: 'Market',
    entrance: VenueAccess.limited,
    toilet: VenueAccess.no,
    description:
        'An example with a barrier: some areas are reached by steps. Limited access should remain visible.',
    parking: 'Unknown',
    assistance: 'Example: help needed at a threshold',
    source: 'Illustrative data',
    isSample: true,
  ),
]);
