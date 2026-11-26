import 'package:flutter/material.dart';

import 'package:maak_metro/core/l10n/app_localizations.dart';
import 'package:maak_metro/core/motion/app_haptics.dart';
import 'package:maak_metro/core/theme/app_theme.dart';
import 'package:maak_metro/core/theme/line_colors.dart';
import 'package:maak_metro/core/utils/digits.dart';
import 'package:maak_metro/core/utils/directions.dart';
import 'package:maak_metro/core/utils/localized_names.dart';
import 'package:maak_metro/features/network/domain/models/models.dart';
import 'package:maak_metro/features/network/presentation/widgets/line_chip.dart';
import 'package:maak_metro/features/planner/domain/models/route_leg.dart';

/// One leg of the route: colour strip on the line colour, boarding and
/// alighting station, and the stops in between behind a tap.
class LegCard extends StatefulWidget {
  const LegCard({super.key, required this.leg, required this.network});

  final RouteLeg leg;
  final NetworkData network;

  @override
  State<LegCard> createState() => _LegCardState();
}

class _LegCardState extends State<LegCard> {
  int _passed = 0;

  void _toggleStop(int index) {
    AppHaptics.action();
    setState(() {
      _passed = index < _passed ? index : index + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final leg = widget.leg;
    final network = widget.network;
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
    final terminus = legTerminus(
      leg,
      network,
      Localizations.localeOf(context).languageCode,
    );

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
                _LegNode(
                  name: stationNameById(context, network, ids.first),
                  color: color,
                  tracked: true,
                ),
                if (terminus.isNotEmpty)
                  Text(
                    l10n.direction(terminus),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
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
                        for (var index = 0; index < middle.length; index++)
                          _CheckableStop(
                            stationId: middle[index],
                            color: color,
                            network: network,
                            passed: index < _passed,
                            upcoming: index == _passed,
                            onTap: () => _toggleStop(index),
                          ),
                      ],
                    ),
                  ),
                if (middle.isEmpty)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 28,
                      bottom: AppSpace.xs,
                    ),
                    child: Text(
                      l10n.nextStop,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                _LegNode(
                  name: stationNameById(context, network, ids.last),
                  color: color,
                  tracked: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegNode extends StatelessWidget {
  const _LegNode({
    required this.name,
    required this.color,
    required this.tracked,
  });

  final String name;
  final Color color;
  final bool tracked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 32,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (tracked)
                Container(
                  width: 2,
                  height: 32,
                  color: color.withValues(alpha: 0.35),
                ),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpace.sm),
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}

class _CheckableStop extends StatelessWidget {
  const _CheckableStop({
    required this.stationId,
    required this.color,
    required this.network,
    required this.passed,
    required this.upcoming,
    required this.onTap,
  });

  final String stationId;
  final Color color;
  final NetworkData network;
  final bool passed;
  final bool upcoming;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final name = stationNameById(context, network, stationId);
    final label = passed
        ? l10n.stopPassed
        : upcoming
        ? l10n.stopUpcoming
        : name;
    return Semantics(
      button: true,
      label: label,
      value: name,
      onTap: onTap,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsetsDirectional.only(bottom: AppSpace.sm),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 28,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(width: 2, color: color.withValues(alpha: 0.35)),
                      Container(
                        width: upcoming ? 12 : 8,
                        height: upcoming ? 12 : 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: passed
                              ? theme.colorScheme.outlineVariant
                              : color,
                          border: upcoming
                              ? Border.all(color: color, width: 2)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: Text(
                    name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: passed
                          ? theme.colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.6,
                            )
                          : null,
                      fontWeight: upcoming ? FontWeight.w600 : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
