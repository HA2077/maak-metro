import 'package:flutter/material.dart';
import 'package:maak_metro/core/l10n/app_localizations.dart';
import 'package:maak_metro/core/theme/app_theme.dart';
import 'package:maak_metro/domain/domain.dart';
import 'package:maak_metro/providers/route_provider.dart';
import 'package:maak_metro/widgets/leg_card.dart';
import 'package:maak_metro/widgets/summary_stat.dart';
import 'package:provider/provider.dart';

/// Shows [RouteProvider.result] as a summary plus one card per leg.
class RouteResultScreen extends StatefulWidget {
  const RouteResultScreen({super.key});

  @override
  State<RouteResultScreen> createState() => _RouteResultScreenState();
}

class _RouteResultScreenState extends State<RouteResultScreen> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteState();
  }

  Future<void> _loadFavoriteState() async {
    final isFavorite = await context.read<RouteProvider>().isCurrentFavorite();
    if (!mounted) return;
    setState(() => _isFavorite = isFavorite);
  }

  Future<void> _toggleFavorite() async {
    await context.read<RouteProvider>().toggleFavorite();
    if (!mounted) return;
    setState(() => _isFavorite = !_isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final route = context.watch<RouteProvider>();
    final result = route.result;
    final network = route.network;

    if (result == null || network == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.routeTitle)),
        body: EmptyHint(icon: Icons.route, message: l10n.noRouteError),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.routeTitle),
        actions: [
          IconButton(
            tooltip: _isFavorite ? l10n.removeFavorite : l10n.addFavorite,
            onPressed: _toggleFavorite,
            icon: Icon(_isFavorite ? Icons.star : Icons.star_border),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpace.lg),
        children: [
          _SummaryCard(result: result),
          const SizedBox(height: AppSpace.xl),
          for (var i = 0; i < result.legs.length; i++) ...[
            LegCard(leg: result.legs[i], network: network),
            if (i < result.legs.length - 1)
              if (_transferBetween(result.legs[i], result.legs[i + 1])
                  case final marker?)
                marker,
          ],
        ],
      ),
    );
  }

  /// Builds the transfer marker between two consecutive legs, or null when the
  /// shared station or the next line cannot be resolved from the network.
  Widget? _transferBetween(RouteLeg current, RouteLeg next) {
    if (current.stationIds.isEmpty) return null;
    final station = network?.stationById(current.stationIds.last);
    final line = network?.lineById(next.lineId);
    if (station == null || line == null) return null;
    return TransferMarker(station: station, nextLine: line);
  }

  NetworkData? get network => context.read<RouteProvider>().network;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.result});

  final RouteResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final minutes = result.estimatedMinutes.round().toString();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.estimatedTime(minutes),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpace.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SummaryStat(
                    icon: Icons.place,
                    value: '${result.stationCount}',
                    label: l10n.stationsCount(result.stationCount),
                  ),
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: SummaryStat(
                    icon: Icons.swap_horiz,
                    value: '${result.transfers}',
                    label: l10n.transfersCount(result.transfers),
                  ),
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: SummaryStat(
                    icon: Icons.payments_outlined,
                    value: l10n.fareEgp(result.fareEgp.toString()),
                    label: l10n.fare,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
