// Licensed under the Apache License, Version 2.0. See LICENSE.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'venue.dart';

const _ocean = Color(0xFF0866C6);

class VenueDiscoveryPage extends StatefulWidget {
  const VenueDiscoveryPage({
    super.key,
    this.catalog = sampleVenueCatalog,
    this.onOpenHabits,
  });

  final VenueCatalog catalog;
  final VoidCallback? onOpenHabits;

  @override
  State<VenueDiscoveryPage> createState() => _VenueDiscoveryPageState();
}

class _VenueDiscoveryPageState extends State<VenueDiscoveryPage> {
  final _search = TextEditingController();
  bool _stepFree = false;
  bool _toilet = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _reset() => setState(() {
    _search.clear();
    _stepFree = false;
    _toilet = false;
  });

  @override
  Widget build(BuildContext context) {
    final results = widget.catalog.search(
      query: _search.text,
      stepFreeOnly: _stepFree,
      accessibleToiletOnly: _toilet,
    );
    final hasSamples = widget.catalog.venues.any((v) => v.isSample);
    return _DiscoveryTheme(
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Access Mauritius'),
            actions: [
              if (widget.onOpenHabits != null)
                IconButton(
                  tooltip: 'My health routines',
                  onPressed: widget.onOpenHabits,
                  icon: const Icon(Icons.checklist_rounded),
                ),
            ],
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      sliver: SliverList.list(
                        children: [
                          Text(
                            'Where can I go?',
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Find a place. Check access. Head out.',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            key: const Key('venue-search'),
                            controller: _search,
                            onChanged: (_) => setState(() {}),
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              labelText: 'Search places or areas',
                              hintText: 'Try Moka or Ebene',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _search.text.isEmpty
                                  ? null
                                  : IconButton(
                                      tooltip: 'Clear search',
                                      onPressed: () => setState(_search.clear),
                                      icon: const Icon(Icons.close),
                                    ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              FilterChip(
                                label: const Text('Step-free entrance'),
                                selected: _stepFree,
                                onSelected: (value) =>
                                    setState(() => _stepFree = value),
                                avatar: const Icon(
                                  Icons.accessible_forward,
                                  size: 20,
                                ),
                              ),
                              FilterChip(
                                label: const Text('Accessible toilet'),
                                selected: _toilet,
                                onSelected: (value) =>
                                    setState(() => _toilet = value),
                                avatar: const Icon(Icons.wc, size: 20),
                              ),
                            ],
                          ),
                          if (hasSamples) ...[
                            const SizedBox(height: 16),
                            const _InfoPanel(
                              icon: Icons.science_outlined,
                              title: 'Preview with sample places',
                              text:
                                  'These venues and access details are fictional. Real Mauritius listings are coming next.',
                            ),
                          ],
                          const SizedBox(height: 24),
                          Text(
                            '${results.length} ${results.length == 1 ? 'place' : 'places'}${hasSamples ? ' to preview' : ' found'}',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    if (results.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              const Icon(Icons.search_off, size: 48),
                              const SizedBox(height: 12),
                              const Text(
                                'No places match yet',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Try another area or remove an access filter.',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton(
                                onPressed: _reset,
                                child: const Text('Clear search and filters'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                        sliver: SliverList.builder(
                          itemCount: results.length,
                          itemBuilder: (context, index) => _VenueCard(
                            venue: results[index],
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    VenueDetailPage(venue: results[index]),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VenueCard extends StatelessWidget {
  const _VenueCard({required this.venue, required this.onTap});
  final Venue venue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 14),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: Icon(
                    _categoryIcon(venue.category),
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        venue.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('${venue.area} · ${venue.category}'),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _AccessBadge(label: 'Entrance', access: venue.entrance),
                _AccessBadge(label: 'Toilet', access: venue.toilet),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _checkedLabel(venue),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    ),
  );
}

class VenueDetailPage extends StatelessWidget {
  const VenueDetailPage({super.key, required this.venue});
  final Venue venue;

  Future<void> _directions(BuildContext context) async {
    final uri = venue.directionsUri;
    if (uri == null) return;
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
    } catch (_) {
      // Show a recoverable failure instead of leaving a dead action.
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open Maps. Please try again.')),
    );
  }

  @override
  Widget build(BuildContext context) => _DiscoveryTheme(
    child: Builder(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Access details')),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    venue.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${venue.area} · ${venue.category}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 20),
                  if (venue.isSample) ...[
                    const _InfoPanel(
                      icon: Icons.science_outlined,
                      title: 'Fictional sample venue',
                      text:
                          'Access details are examples. This is not a real destination.',
                    ),
                    const SizedBox(height: 20),
                  ],
                  Text(
                    'Access at a glance',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          _DetailRow(
                            icon: Icons.accessible_forward,
                            title: 'Entrance',
                            value: _entranceLabel(venue.entrance),
                          ),
                          const Divider(height: 28),
                          _DetailRow(
                            icon: Icons.wc,
                            title: 'Toilet',
                            value: _toiletLabel(venue.toilet),
                          ),
                          const Divider(height: 28),
                          _DetailRow(
                            icon: Icons.local_parking,
                            title: 'Parking & drop-off',
                            value: venue.parking,
                          ),
                          const Divider(height: 28),
                          _DetailRow(
                            icon: Icons.people_outline,
                            title: 'Assistance',
                            value: venue.assistance,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    venue.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 20),
                  _InfoPanel(
                    icon: Icons.info_outline,
                    title: venue.source,
                    text: _checkedLabel(venue),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Photos',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (venue.photoUrls.isEmpty)
                    const _InfoPanel(
                      icon: Icons.photo_camera_outlined,
                      title: 'No entrance photos yet',
                      text:
                          'Photos can help you judge the entrance and space for your chair.',
                    )
                  else
                    ...venue.photoUrls.map(
                      (url) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            url,
                            semanticLabel: '${venue.name} access photo',
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const _InfoPanel(
                              icon: Icons.broken_image_outlined,
                              title: 'Photo unavailable',
                              text: 'Please try again later.',
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    key: const Key('venue-directions'),
                    onPressed: venue.canNavigate
                        ? () => _directions(context)
                        : null,
                    icon: const Icon(Icons.directions_outlined),
                    label: const Text('Directions'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    venue.isSample
                        ? 'Directions will be available for real venues.'
                        : venue.canNavigate
                        ? 'Maps provides directions to the venue, not a verified wheelchair route.'
                        : 'Directions unavailable: location has not been supplied.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
  });
  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(value),
          ],
        ),
      ),
    ],
  );
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({
    required this.icon,
    required this.title,
    required this.text,
  });
  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(text),
            ],
          ),
        ),
      ],
    ),
  );
}

class _AccessBadge extends StatelessWidget {
  const _AccessBadge({required this.label, required this.access});
  final String label;
  final VenueAccess access;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final color = switch (access) {
      VenueAccess.yes =>
        dark ? const Color(0xFF7ADBC5) : const Color(0xFF086958),
      VenueAccess.limited =>
        dark ? const Color(0xFFFFD182) : const Color(0xFF805100),
      VenueAccess.no => Theme.of(context).colorScheme.error,
      VenueAccess.unknown => Theme.of(context).colorScheme.onSurfaceVariant,
    };
    final value = label == 'Entrance'
        ? _entranceLabel(access)
        : _toiletLabel(access);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _DiscoveryTheme extends StatelessWidget {
  const _DiscoveryTheme({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final colors = ColorScheme.fromSeed(
      seedColor: _ocean,
      brightness: base.brightness,
    );
    return Theme(
      data: base.copyWith(
        colorScheme: colors,
        scaffoldBackgroundColor: base.brightness == Brightness.dark
            ? const Color(0xFF101820)
            : const Color(0xFFFAF9F6),
        appBarTheme: AppBarTheme(
          backgroundColor: colors.surface,
          foregroundColor: colors.onSurface,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: colors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: colors.outlineVariant),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(48, 52),
            textStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        materialTapTargetSize: MaterialTapTargetSize.padded,
      ),
      child: child,
    );
  }
}

String _entranceLabel(VenueAccess access) => switch (access) {
  VenueAccess.yes => 'Step-free',
  VenueAccess.limited => 'Limited access',
  VenueAccess.no => 'Steps / barrier reported',
  VenueAccess.unknown => 'Unknown',
};

String _toiletLabel(VenueAccess access) => switch (access) {
  VenueAccess.yes => 'Accessible',
  VenueAccess.limited => 'Limited access',
  VenueAccess.no => 'Not accessible',
  VenueAccess.unknown => 'Unknown',
};

String _checkedLabel(Venue venue) {
  if (venue.isSample) return 'Sample data · Not verified';
  final date = venue.checkedOn;
  if (date == null) return 'Last checked: unknown';
  return 'Last checked: ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

IconData _categoryIcon(String category) => switch (category) {
  'Café' => Icons.local_cafe_outlined,
  'Garden' => Icons.park_outlined,
  'Gallery' => Icons.palette_outlined,
  _ => Icons.storefront_outlined,
};
