# Access Mauritius — first implementation

The app opens at `/explore` with one searchable venue list. Search matches venue
name, area and category. Optional entrance and toilet filters require an explicit
positive access report; unknown and limited access do not pass these filters.
Tap a card to read its access details and source. The health routines button
opens the original Table Habit app, with a visible Back to places action.

## Current data

All four bundled venues are fictional, clearly labelled fixtures. No real venue
has been assessed. Last-checked dates are unknown and photos have not been
supplied. Directions are disabled for samples. Real records with coordinates
can open Apple Maps, with a visible explanation that the route is not verified
for wheelchair use. Launcher failures have a recoverable message.

## Next data integration

Replace `sampleVenueCatalog` with sourced Mauritius records. Preserve source,
observation date, separate entrance/toilet states, and unknown values. Do not
infer wheelchair access from venue category or missing tags. Only include photos
that can be reused and that correspond to the specific venue. Review OpenStreetMap
attribution/licensing before importing its records. No map, geolocation request,
public review submission, or outing checklist is included in this iteration.

## Validation

Local Dart assertions passed for case/accent-insensitive area/category search,
combined access filters, empty matches, and disabled sample directions. Dart
formatting and `git diff --check` passed. Flutter setup was blocked by automatic
approval review after it attempted a cloud metadata request; widget tests,
full analysis and an iOS build could not be executed in this session.


Run `flutter test test/features/venue_discovery/venue_discovery_test.dart` and
`flutter test test/unit/routes/app_router_test.dart` with the repository's pinned
Flutter SDK. iOS compilation/signing must be performed on macOS with Xcode.
