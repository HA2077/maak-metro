import 'package:flutter/material.dart';
import 'package:maak_metro/core/l10n/app_localizations.dart';
import 'package:maak_metro/core/theme/app_theme.dart';
import 'package:maak_metro/domain/domain.dart';
import 'package:maak_metro/providers/library_provider.dart';
import 'package:maak_metro/providers/route_provider.dart';
import 'package:maak_metro/screens/route_result_screen.dart';
import 'package:maak_metro/widgets/station_picker.dart';
import 'package:provider/provider.dart';

/// The first tab: pick a from and a to station and ask for the best route.
class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final route = context.watch<RouteProvider>();
    final library = context.watch<LibraryProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.plannerTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpace.lg),
        children: [
          Text(
            l10n.plannerHint,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          _StationFields(route: route),
          const SizedBox(height: AppSpace.md),
          _Errors(route: route),
          const SizedBox(height: AppSpace.lg),
          FilledButton.icon(
            onPressed: route.canSearch && !route.loading
                ? () => _search(context, route)
                : null,
            icon: route.loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.alt_route),
            label: Text(l10n.findRoute),
          ),
          const SizedBox(height: AppSpace.xxl),
          _RecentSearches(history: library.history, route: route),
        ],
      ),
    );
  }

  Future<void> _search(BuildContext context, RouteProvider route) async {
    final found = await route.calculate();
    if (!found || !context.mounted) return;
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const RouteResultScreen()));
  }
}

class _StationFields extends StatelessWidget {
  const _StationFields({required this.route});

  final RouteProvider route;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stations = route.stations;

    Future<void> pick({required bool isFrom}) async {
      final picked = await showStationPicker(context, stations);
      if (picked == null) return;
      if (isFrom) {
        route.setFrom(picked);
      } else {
        route.setTo(picked);
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.lg),
        child: Column(
          children: [
            _StationField(
              label: l10n.fromLabel,
              station: route.from,
              icon: Icons.trip_origin,
              onTap: () => pick(isFrom: true),
            ),
            Row(
              children: [
                const Expanded(child: Divider(indent: AppSpace.xl)),
                IconButton(
                  tooltip: l10n.swapStations,
                  onPressed: route.swap,
                  icon: const Icon(Icons.swap_vert),
                ),
                const Expanded(child: Divider(indent: AppSpace.xl)),
              ],
            ),
            _StationField(
              label: l10n.toLabel,
              station: route.to,
              icon: Icons.place,
              onTap: () => pick(isFrom: false),
            ),
          ],
        ),
      ),
    );
  }
}

class _StationField extends StatelessWidget {
  const _StationField({
    required this.label,
    required this.station,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Station? station;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final language = Localizations.localeOf(context).languageCode;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.field),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        child: Text(
          station?.localizedName(language) ?? l10n.selectStation,
          style: station == null
              ? theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                )
              : theme.textTheme.bodyLarge,
        ),
      ),
    );
  }
}

class _Errors extends StatelessWidget {
  const _Errors({required this.route});

  final RouteProvider route;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final message = switch (route.error) {
      RouteError.sameStation => l10n.sameStationError,
      RouteError.noRoute => l10n.noRouteError,
      RouteError.none => null,
    };
    if (message == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(Icons.error_outline, size: 18, color: theme.colorScheme.error),
        const SizedBox(width: AppSpace.sm),
        Expanded(
          child: Text(
            message,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
      ],
    );
  }
}

class _RecentSearches extends StatelessWidget {
  const _RecentSearches({required this.history, required this.route});

  final List<HistoryEntry> history;
  final RouteProvider route;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final network = route.network;
    if (network == null || history.isEmpty) return const SizedBox.shrink();

    final recent = history.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.recentSearches,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpace.sm),
        Wrap(
          spacing: AppSpace.sm,
          runSpacing: AppSpace.sm,
          children: [
            for (final entry in recent)
              if (_pair(context, network, entry) case final pair?)
                ActionChip(
                  label: Text(pair),
                  onPressed: () {
                    route.setFrom(network.stationById(entry.fromId));
                    route.setTo(network.stationById(entry.toId));
                  },
                ),
          ],
        ),
      ],
    );
  }

  /// "From → To" in the active language, or null when a station is gone.
  String? _pair(BuildContext context, NetworkData network, HistoryEntry entry) {
    final from = network.stationById(entry.fromId);
    final to = network.stationById(entry.toId);
    if (from == null || to == null) return null;
    final language = Localizations.localeOf(context).languageCode;
    return '${from.localizedName(language)} ← ${to.localizedName(language)}';
  }
}
