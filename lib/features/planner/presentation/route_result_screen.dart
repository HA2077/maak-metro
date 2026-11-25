import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maak_metro/core/l10n/app_localizations.dart';
import 'package:maak_metro/core/motion/app_haptics.dart';
import 'package:maak_metro/core/motion/app_motion.dart';
import 'package:maak_metro/core/motion/fade_slide_in.dart';
import 'package:maak_metro/core/theme/app_theme.dart';
import 'package:maak_metro/core/utils/digits.dart';
import 'package:maak_metro/core/utils/localized_names.dart';
import 'package:maak_metro/features/library/presentation/library_cubit.dart';
import 'package:maak_metro/features/network/domain/models/models.dart';
import 'package:maak_metro/features/network/presentation/widgets/line_chip.dart';
import 'package:maak_metro/features/planner/domain/domain.dart';
import 'package:maak_metro/features/planner/presentation/widgets/count_up.dart';
import 'package:maak_metro/features/planner/presentation/widgets/leg_card.dart';
import 'package:maak_metro/features/planner/presentation/widgets/summary_stat.dart';

class RouteResultScreen extends StatelessWidget {
  const RouteResultScreen({
    super.key,
    required this.result,
    required this.network,
  });

  final RouteResult result;
  final NetworkData network;

  static String _minutes(double value) => value == value.roundToDouble()
      ? value.round().toString()
      : value.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.routeTitle),
        actions: [_FavoriteButton(fromId: result.fromId, toId: result.toId)],
      ),
      body: ListView(
        padding: const EdgeInsetsDirectional.all(18),
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
                        l10n.estimatedTime(_minutes(result.estimatedMinutes)),
                      ),
                      child: ExcludeSemantics(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.estimatedLabel,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: AppSpace.xs),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: AlignmentDirectional.centerStart,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  CountUp(
                                    value: result.estimatedMinutes,
                                    duration: AppMotion.counter,
                                    text: (value) => localizedDigits(
                                      context,
                                      _minutes(value),
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
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                  next: result.legs[index],
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
    final station = previousStops.isEmpty
        ? ''
        : stationNameById(context, network, previousStops.last);

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: AppSpace.sm),
      child: Row(
        children: [
          Icon(Icons.alt_route, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpace.sm),
          if (line != null) ...[
            LineChip(line: line),
            const SizedBox(width: AppSpace.sm),
          ],
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
