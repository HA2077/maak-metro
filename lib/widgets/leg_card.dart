import 'package:flutter/material.dart';
import 'package:maak_metro/core/l10n/app_localizations.dart';
import 'package:maak_metro/core/theme/app_theme.dart';
import 'package:maak_metro/core/theme/line_colors.dart';
import 'package:maak_metro/domain/domain.dart';
import 'package:maak_metro/widgets/line_chip.dart';

/// One section of the route: a run of consecutive stations on the same line.
///
/// The coloured strip on the leading edge matches the line colour, and the
/// intermediate stations hide behind a disclosure tile so a 20-station leg does
/// not push the transfer markers off screen.
class LegCard extends StatelessWidget {
  const LegCard({
    super.key,
    required this.leg,
    required this.network,
    this.bottomPadding = AppSpace.md,
  });

  final RouteLeg leg;
  final NetworkData network;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final language = Localizations.localeOf(context).languageCode;
    final line = network.lineById(leg.lineId);
    final color = line == null
        ? unknownLineColor
        : parseHexColor(line.colorHex);

    final stations = [
      for (final id in leg.stationIds)
        if (network.stationById(id) case final station?) station,
    ];
    if (stations.isEmpty) return const SizedBox.shrink();

    final first = stations.first.localizedName(language);
    final last = stations.last.localizedName(language);
    final intermediate = stations.length - 2;

    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: bottomPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            constraints: const BoxConstraints(minHeight: 72),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (line != null) LineChip(line: line),
                const SizedBox(height: AppSpace.sm),
                Text(
                  AppLocalizations.of(context).legFromTo(first, last),
                  style: theme.textTheme.titleMedium,
                ),
                if (intermediate > 0) ...[
                  const SizedBox(height: AppSpace.xs),
                  Theme(
                    data: theme.copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: const EdgeInsetsDirectional.only(
                        start: AppSpace.md,
                      ),
                      dense: true,
                      title: Text(
                        AppLocalizations.of(context)
                            .intermediateStations(intermediate),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      children: [
                        for (final station in stations.sublist(
                          1,
                          stations.length - 1,
                        ))
                          _Dot(
                            label: station.localizedName(language),
                            color: color,
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpace.sm),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

/// The "change to line X at station Y" marker drawn between two legs.
class TransferMarker extends StatelessWidget {
  const TransferMarker({
    super.key,
    required this.station,
    required this.nextLine,
  });

  final Station station;
  final Line nextLine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final language = Localizations.localeOf(context).languageCode;

    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: AppSpace.xs,
        bottom: AppSpace.md,
      ),
      child: Row(
        children: [
          Icon(
            Icons.swap_horiz,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Text(
              AppLocalizations.of(context).changeTo(
                nextLine.localizedName(language),
                station.localizedName(language),
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
