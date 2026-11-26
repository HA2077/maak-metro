import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maak_metro/core/l10n/app_localizations.dart';
import 'package:maak_metro/core/motion/app_haptics.dart';
import 'package:maak_metro/core/motion/app_motion.dart';
import 'package:maak_metro/core/motion/fade_slide_in.dart';
import 'package:maak_metro/core/theme/app_theme.dart';
import 'package:maak_metro/core/utils/digits.dart';
import 'package:maak_metro/core/utils/directions.dart';
import 'package:maak_metro/core/utils/localized_names.dart';
import 'package:maak_metro/features/library/presentation/library_cubit.dart';
import 'package:maak_metro/features/network/domain/models/models.dart';
import 'package:maak_metro/features/planner/domain/domain.dart';
import 'package:maak_metro/features/planner/presentation/planner_cubit.dart';
import 'package:maak_metro/features/planner/presentation/widgets/count_up.dart';
import 'package:maak_metro/features/planner/presentation/widgets/leg_card.dart';
import 'package:maak_metro/features/planner/presentation/widgets/summary_stat.dart';

class RouteResultScreen extends StatefulWidget {
  const RouteResultScreen({
    super.key,
    required this.result,
    required this.network,
    this.now,
  });

  final RouteResult result;
  final NetworkData network;
  final DateTime? now;

  static String _minutes(double value) => value == value.roundToDouble()
      ? value.round().toString()
      : value.toStringAsFixed(1);

  static String _ticketColorName(AppLocalizations l10n, String ticketColor) =>
      switch (ticketColor) {
        'green' => l10n.ticketGreen,
        'pink' => l10n.ticketPink,
        'lightBrown' => l10n.ticketLightBrown,
        _ => l10n.ticketYellow,
      };

  @override
  State<RouteResultScreen> createState() => _RouteResultScreenState();
}

String _arrivalClock(
  BuildContext context,
  DateTime arrival,
  AppLocalizations l10n,
) {
  final hour = arrival.hour % 12 == 0 ? 12 : arrival.hour % 12;
  final minute = arrival.minute.toString().padLeft(2, '0');
  final marker = arrival.hour < 12 ? l10n.amMarker : l10n.pmMarker;
  return localizedDigits(context, '$hour:$minute $marker');
}

String _tripSummary(
  BuildContext context,
  NetworkData network,
  RouteResult result,
) {
  final l10n = AppLocalizations.of(context);
  final languageCode = Localizations.localeOf(context).languageCode;
  final arrow = languageCode == 'ar' ? '←' : '→';
  final lines = <String>[
    '${stationNameById(context, network, result.fromId)} $arrow ${stationNameById(context, network, result.toId)}',
  ];
  for (final leg in result.legs) {
    final line = network.lineById(leg.lineId);
    if (line == null || leg.stationIds.isEmpty) continue;
    final start = stationNameById(context, network, leg.stationIds.first);
    final end = stationNameById(context, network, leg.stationIds.last);
    final terminus = legTerminus(leg, network, languageCode);
    lines.add(
      terminus.isEmpty
          ? l10n.legFromTo(start, end)
          : '${lineName(context, line)}: ${l10n.direction(terminus)} · ${l10n.legFromTo(start, end)}',
    );
  }
  for (var index = 1; index < result.legs.length; index++) {
    final previous = result.legs[index - 1].stationIds;
    if (previous.isNotEmpty) {
      lines.add(
        l10n.changeAt(stationNameById(context, network, previous.last)),
      );
    }
  }
  lines.add(localizedDigits(context, l10n.stationsCount(result.stationCount)));
  lines.add(localizedDigits(context, l10n.transfersCount(result.transfers)));
  lines.add(
    localizedDigits(
      context,
      l10n.estimatedTime(RouteResultScreen._minutes(result.estimatedMinutes)),
    ),
  );
  FareBracket? bracket;
  for (final fare in network.fares) {
    if (fare.priceEgp == result.fareEgp) {
      bracket = fare;
      break;
    }
  }
  final price = localizedDigits(
    context,
    l10n.fareEgp(result.fareEgp.toString()),
  );
  lines.add(
    bracket == null
        ? price
        : '${RouteResultScreen._ticketColorName(l10n, bracket.ticketColor)} · $price',
  );
  return lines.join('\n');
}

class _RouteResultScreenState extends State<RouteResultScreen> {
  late RouteResult result;
  late NetworkData network;

  @override
  void initState() {
    super.initState();
    result = widget.result;
    network = widget.network;
  }

  void _reverse() {
    final reversed = findRoute(
      fromId: result.toId,
      toId: result.fromId,
      data: network,
      config: context.read<PlannerCubit>().config,
    );
    if (reversed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).noRouteError)),
      );
      return;
    }
    AppHaptics.action();
    setState(() => result = reversed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    FareBracket? fareBracket;
    for (final bracket in network.fares) {
      if (bracket.priceEgp == result.fareEgp) {
        fareBracket = bracket;
        break;
      }
    }
    final badge = fareBracket == null
        ? null
        : AppTheme.ticketBadge(
            fareBracket.ticketColor,
            theme.colorScheme.brightness,
          );
    final arrival = (widget.now ?? DateTime.now()).add(
      Duration(minutes: result.estimatedMinutes.round()),
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.routeTitle),
            Text(
              l10n.routeEndpoints(
                stationNameById(context, network, result.fromId),
                stationNameById(context, network, result.toId),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          _CopyButton(result: result, network: network),
          _FavoriteButton(fromId: result.fromId, toId: result.toId),
        ],
      ),
      body: ListView(
        padding: EdgeInsetsDirectional.only(
          start: 18,
          top: 18,
          end: 18,
          bottom: MediaQuery.paddingOf(context).bottom + 16,
        ),
        children: [
          AnimatedSwitcher(
            duration: AppMotion.of(context, AppMotion.base),
            switchInCurve: AppMotion.decelerate,
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Column(
              key: ValueKey('${result.fromId}>${result.toId}'),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FadeSlideIn(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Semantics(
                            label: localizedDigits(
                              context,
                              l10n.estimatedTime(
                                RouteResultScreen._minutes(
                                  result.estimatedMinutes,
                                ),
                              ),
                            ),
                            child: ExcludeSemantics(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.estimatedLabel,
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                          color: theme
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                  ),
                                  const SizedBox(height: AppSpace.xs),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: AlignmentDirectional.centerStart,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        CountUp(
                                          value: result.estimatedMinutes,
                                          duration: AppMotion.counter,
                                          text: (value) => localizedDigits(
                                            context,
                                            RouteResultScreen._minutes(value),
                                          ),
                                          style: AppTheme.numeric(
                                            theme.textTheme.displaySmall,
                                          ),
                                        ),
                                        const SizedBox(width: AppSpace.sm),
                                        Text(
                                          l10n.minutesShort,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                        const SizedBox(width: AppSpace.md),
                                        Container(
                                          padding:
                                              const EdgeInsetsDirectional.symmetric(
                                                horizontal: AppSpace.sm,
                                                vertical: AppSpace.xs,
                                              ),
                                          decoration: BoxDecoration(
                                            color: theme
                                                .colorScheme
                                                .surfaceContainerHighest,
                                            borderRadius: BorderRadius.circular(
                                              AppRadius.field,
                                            ),
                                          ),
                                          child: Text(
                                            l10n.arrivalTime(
                                              _arrivalClock(
                                                context,
                                                arrival,
                                                l10n,
                                              ),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (fareBracket != null && badge != null) ...[
                            const SizedBox(height: AppSpace.md),
                            Container(
                              decoration: BoxDecoration(
                                color: badge.background,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.field,
                                ),
                              ),
                              padding: const EdgeInsetsDirectional.symmetric(
                                horizontal: AppSpace.md,
                                vertical: AppSpace.sm,
                              ),
                              child: Text(
                                '${RouteResultScreen._ticketColorName(l10n, fareBracket.ticketColor)} · ${localizedDigits(context, l10n.fareEgp(result.fareEgp.toString()))}',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: badge.foreground,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpace.lg),
                          Row(
                            children: [
                              Expanded(
                                child: SummaryStat(
                                  icon: Icons.pin_drop_outlined,
                                  text: localizedDigits(
                                    context,
                                    l10n.stationsCount(result.stationCount),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: SummaryStat(
                                  icon: Icons.alt_route,
                                  text: localizedDigits(
                                    context,
                                    l10n.transfersCount(result.transfers),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: SummaryStat(
                                  icon: Icons.payments_outlined,
                                  iconColor: badge?.background,
                                  text: localizedDigits(
                                    context,
                                    l10n.fareEgp(result.fareEgp.toString()),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpace.lg),
                for (var index = 0; index < result.legs.length; index++) ...[
                  if (index > 0)
                    FadeSlideIn(
                      index: index * 2 - 1,
                      child: _TransferRow(
                        network: network,
                        previous: result.legs[index - 1],
                      ),
                    ),
                  FadeSlideIn(
                    index: index * 2,
                    child: LegCard(leg: result.legs[index], network: network),
                  ),
                  if (index < result.legs.length - 1)
                    const SizedBox(height: AppSpace.md),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _reverse,
              icon: const Icon(Icons.swap_horiz),
              label: Text(l10n.reverseTrip),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CopyButton extends StatelessWidget {
  const _CopyButton({required this.result, required this.network});

  final RouteResult result;
  final NetworkData network;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l10n.copyTrip,
      onTap: () => _copy(context),
      child: ExcludeSemantics(
        child: IconButton(
          onPressed: () => _copy(context),
          tooltip: l10n.copyTrip,
          constraints: const BoxConstraints.tightFor(width: 48, height: 48),
          icon: const Icon(Icons.copy),
        ),
      ),
    );
  }

  Future<void> _copy(BuildContext context) async {
    AppHaptics.action();
    await Clipboard.setData(
      ClipboardData(text: _tripSummary(context, network, result)),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).routeCopied)),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.fromId, required this.toId});

  final String fromId;
  final String toId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isFavorite = context.select(
      (LibraryCubit cubit) => cubit.state.isFavorite(fromId, toId),
    );
    return IconButton(
      onPressed: () async {
        AppHaptics.action();
        await context.read<LibraryCubit>().toggleFavorite(fromId, toId);
      },
      tooltip: isFavorite ? l10n.removeFavorite : l10n.addFavorite,
      isSelected: isFavorite,
      icon: const Icon(Icons.star_border),
      selectedIcon: Icon(Icons.star, color: theme.colorScheme.primary),
    );
  }
}

class _TransferRow extends StatelessWidget {
  const _TransferRow({required this.network, required this.previous});

  final NetworkData network;
  final RouteLeg previous;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final previousStops = previous.stationIds;
    final station = previousStops.isEmpty
        ? ''
        : stationNameById(context, network, previousStops.last);

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: AppSpace.sm),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 24),
            child: SizedBox(
              width: 20,
              height: 28,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(width: 2, color: theme.colorScheme.outlineVariant),
                  Icon(
                    Icons.alt_route,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpace.sm),
          Expanded(
            child: Text(
              l10n.changeAt(station),
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
