import 'package:flutter/material.dart';
import 'package:maak_metro/core/l10n/app_localizations.dart';
import 'package:maak_metro/core/motion/app_haptics.dart';
import 'package:maak_metro/core/motion/app_motion.dart';
import 'package:maak_metro/core/motion/fade_slide_in.dart';
import 'package:maak_metro/core/theme/app_theme.dart';
import 'package:maak_metro/core/utils/digits.dart';
import 'package:maak_metro/core/utils/localized_names.dart';
import 'package:maak_metro/domain/domain.dart';
import 'package:maak_metro/providers/route_provider.dart';
import 'package:maak_metro/widgets/count_up.dart';
import 'package:maak_metro/widgets/leg_card.dart';
import 'package:maak_metro/widgets/line_chip.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.routeTitle),
        actions: [
          if (result != null)
            _FavoriteButton(pair: '${result.fromId}/${result.toId}'),
        ],
      ),
      body: result == null || network == null
          ? const SizedBox.shrink()
          : ListView(
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
                              l10n.estimatedTime(
                                _minutes(result.estimatedMinutes),
                              ),
                            ),
                            child: ExcludeSemantics(
                              child: CountUp(
                                value: result.estimatedMinutes,
                                duration: AppMotion.counter,
                                text: (value) => localizedDigits(
                                  context,
                                  l10n.estimatedTime(_minutes(value)),
                                ),
                                style: AppTheme.numeric(
                                  theme.textTheme.headlineSmall,
                                ),
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

/// The star reads the favourite state asynchronously, because the library is
/// async. It re-checks when the pair changes or after a toggle.
class _FavoriteButton extends StatefulWidget {
  const _FavoriteButton({required this.pair});

  final String pair;

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  @override
  void didUpdateWidget(_FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pair != widget.pair) _check();
  }

  Future<void> _check() async {
    final route = context.read<RouteProvider>();
    final favorite = await route.isCurrentFavorite();
    if (mounted) setState(() => _isFavorite = favorite);
  }

  Future<void> _toggle() async {
    AppHaptics.action();
    await context.read<RouteProvider>().toggleFavorite();
    await _check();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return IconButton(
      onPressed: _toggle,
      tooltip: _isFavorite ? l10n.removeFavorite : l10n.addFavorite,
      isSelected: _isFavorite,
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
