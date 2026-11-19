import 'package:flutter/material.dart';
import 'package:maak_metro/core/l10n/app_localizations.dart';
import 'package:maak_metro/core/theme/app_theme.dart';
import 'package:maak_metro/core/utils/localized_names.dart';
import 'package:maak_metro/domain/models/metro_models.dart';
import 'package:maak_metro/providers/route_provider.dart';
import 'package:maak_metro/widgets/leg_card.dart';
import 'package:maak_metro/widgets/summary_stat.dart';
import 'package:provider/provider.dart';

class RouteResultScreen extends StatelessWidget {
  const RouteResultScreen({super.key});

  static String _minutes(double value) => value == value.roundToDouble()
      ? value.round().toString()
      : value.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final route = context.watch<RouteProvider>();
    final result = route.result;
    final network = route.network;
    final isFavorite = route.isCurrentFavorite;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.routeTitle),
        actions: [
          if (result != null)
            IconButton(
              onPressed: route.toggleFavorite,
              tooltip: isFavorite ? l10n.removeFavorite : l10n.addFavorite,
              icon: Icon(isFavorite ? Icons.star : Icons.star_border),
            ),
        ],
      ),
      body: result == null
          ? const SizedBox.shrink()
          : ListView(
              padding: const EdgeInsetsDirectional.all(AppSpace.lg),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.all(AppSpace.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.estimatedTime(_minutes(result.estimatedMinutes)),
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: AppSpace.lg),
                        Row(
                          children: [
                            Expanded(
                              child: SummaryStat(
                                icon: Icons.pin_drop_outlined,
                                text: l10n.stationsCount(result.stationCount),
                              ),
                            ),
                            Expanded(
                              child: SummaryStat(
                                icon: Icons.alt_route,
                                text: l10n.transfersCount(result.transfers),
                              ),
                            ),
                            Expanded(
                              child: SummaryStat(
                                icon: Icons.payments_outlined,
                                text: l10n.fareEgp(result.fareEgp.toString()),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpace.lg),
                for (var index = 0; index < result.legs.length; index++) ...[
                  if (index > 0)
                    _TransferRow(
                      network: network,
                      previous: result.legs[index - 1],
                      next: result.legs[index],
                    ),
                  LegCard(leg: result.legs[index], network: network),
                  if (index < result.legs.length - 1)
                    const SizedBox(height: AppSpace.md),
                ],
              ],
            ),
    );
  }
}

class _TransferRow extends StatelessWidget {
  const _TransferRow({
    required this.network,
    required this.previous,
    required this.next,
  });

  final NetworkData network;
  final RouteLeg previous;
  final RouteLeg next;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final line = network.lineById(next.lineId);
    final previousStops = previous.stationIds;
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: AppSpace.sm),
      child: Row(
        children: [
          Icon(Icons.alt_route, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpace.sm),
          Expanded(
            child: Text(
              l10n.changeTo(
                line == null ? '' : lineName(context, line),
                previousStops.isEmpty
                    ? ''
                    : stationNameById(context, network, previousStops.last),
              ),
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
