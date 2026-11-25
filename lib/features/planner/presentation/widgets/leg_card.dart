import 'package:flutter/material.dart';

import 'package:maak_metro/core/l10n/app_localizations.dart';
import 'package:maak_metro/core/theme/app_theme.dart';
import 'package:maak_metro/core/theme/line_colors.dart';
import 'package:maak_metro/core/utils/digits.dart';
import 'package:maak_metro/core/utils/localized_names.dart';
import 'package:maak_metro/features/network/domain/models/models.dart';
import 'package:maak_metro/features/network/presentation/widgets/line_chip.dart';
import 'package:maak_metro/features/planner/domain/models/route_leg.dart';

/// One leg of the route: colour strip on the line colour, boarding and
/// alighting station, and the stops in between behind a tap.
class LegCard extends StatelessWidget {
  const LegCard({super.key, required this.leg, required this.network});

  final RouteLeg leg;
  final NetworkData network;

  @override
  Widget build(BuildContext context) {
    final ids = leg.stationIds;
    if (ids.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final line = network.lineById(leg.lineId);
    final color = line == null
        ? unknownLineColor
        : parseHexColor(line.colorHex);
    final middle = ids.length > 2
        ? ids.sublist(1, ids.length - 1)
        : const <String>[];

    // The strip sits in a Stack instead of a stretched Row: a stretched Row
    // needs IntrinsicHeight, which cannot measure an ExpansionTile and
    // overflowed at 360dp with large text.
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          PositionedDirectional(
            start: 0,
            top: 0,
            bottom: 0,
            width: 6,
            child: ColoredBox(color: color),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              18,
              AppSpace.lg,
              18,
              AppSpace.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (line != null) LineChip(line: line),
                const SizedBox(height: AppSpace.sm),
                Text(
                  l10n.legFromTo(
                    stationNameById(context, network, ids.first),
                    stationNameById(context, network, ids.last),
                  ),
                  style: theme.textTheme.titleMedium,
                ),
                if (middle.isNotEmpty)
                  Theme(
                    data: theme.copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: const EdgeInsetsDirectional.only(
                        bottom: AppSpace.sm,
                      ),
                      title: Text(
                        localizedDigits(
                          context,
                          l10n.intermediateStations(middle.length),
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      children: [
                        for (final id in middle)
                          _StationDot(
                            stationId: id,
                            color: color,
                            network: network,
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StationDot extends StatelessWidget {
  const _StationDot({
    required this.stationId,
    required this.color,
    required this.network,
  });

  final String stationId;
  final Color color;
  final NetworkData network;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpace.sm),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 28,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(width: 2, color: theme.colorScheme.outlineVariant),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpace.sm),
          Expanded(
            child: Text(
              stationNameById(context, network, stationId),
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
