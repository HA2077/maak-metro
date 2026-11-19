import 'package:flutter/material.dart';
import 'package:maak_metro/core/l10n/app_localizations.dart';
import 'package:maak_metro/core/motion/app_haptics.dart';
import 'package:maak_metro/core/motion/app_motion.dart';
import 'package:maak_metro/core/motion/fade_slide_in.dart';
import 'package:maak_metro/core/theme/app_theme.dart';
import 'package:maak_metro/core/utils/localized_names.dart';
import 'package:maak_metro/domain/models/metro_models.dart';
import 'package:maak_metro/providers/library_provider.dart';
import 'package:maak_metro/providers/route_provider.dart';
import 'package:maak_metro/screens/route_result_screen.dart';
import 'package:maak_metro/widgets/station_picker.dart';
import 'package:provider/provider.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  double _swapTurns = 0;

  Future<void> _pick(BuildContext context, {required bool from}) async {
    final route = context.read<RouteProvider>();
    final l10n = AppLocalizations.of(context);
    final station = await showStationPicker(
      context,
      stations: route.network.stations,
      title: from ? l10n.fromLabel : l10n.toLabel,
    );
    if (station == null) return;
    if (from) {
      route.setFrom(station.id);
    } else {
      route.setTo(station.id);
    }
  }

  Future<void> _search(BuildContext context) async {
    final route = context.read<RouteProvider>();
    await route.calculate();
    if (!context.mounted || route.result == null) return;
    AppHaptics.confirm();
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const RouteResultScreen()));
  }

  void _swap(RouteProvider route) {
    route.swap();
    AppHaptics.action();
    if (!AppMotion.reduced(context)) {
      setState(() => _swapTurns += 0.5);
    }
  }

  String? _errorText(AppLocalizations l10n, RouteError? error) =>
      switch (error) {
        null => null,
        RouteError.sameStation => l10n.sameStationError,
        RouteError.noRoute => l10n.noRouteError,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final route = context.watch<RouteProvider>();
    final library = context.watch<LibraryProvider>();
    final errorText = _errorText(l10n, route.error);
    final recent = library.history.take(3).toList();
    final interchanges = _interchanges(context, route.network);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.plannerTitle)),
      body: route.network.isEmpty
          ? const _NoData()
          : ListView(
              padding: const EdgeInsetsDirectional.fromSTEB(
                18,
                AppSpace.sm,
                18,
                AppSpace.xl,
              ),
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: 20),
                  child: Text(
                    l10n.plannerHint,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                _TripCard(
                  from: route.fromStation,
                  to: route.toStation,
                  l10n: l10n,
                  swapTurns: _swapTurns,
                  onPickFrom: () => _pick(context, from: true),
                  onPickTo: () => _pick(context, from: false),
                  onSwap: () => _swap(route),
                ),
                const SizedBox(height: AppSpace.lg),
                FilledButton(
                  onPressed: route.canSearch ? () => _search(context) : null,
                  child: AnimatedSwitcher(
                    duration: AppMotion.of(context, AppMotion.base),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: route.loading
                        ? const SizedBox(
                            key: ValueKey('loading'),
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.findRoute, key: const ValueKey('label')),
                  ),
                ),
                AnimatedSize(
                  duration: AppMotion.of(context, AppMotion.base),
                  curve: AppMotion.decelerate,
                  alignment: AlignmentDirectional.topStart,
                  child: errorText == null
                      ? const SizedBox(width: double.infinity)
                      : Padding(
                          padding: const EdgeInsetsDirectional.only(
                            top: AppSpace.md,
                          ),
                          child: _ErrorText(text: errorText),
                        ),
                ),
                if (recent.isEmpty && interchanges.isNotEmpty) ...[
                  const SizedBox(height: AppSpace.xl),
                  Text(l10n.interchanges, style: theme.textTheme.titleSmall),
                  const SizedBox(height: AppSpace.md),
                  Wrap(
                    spacing: AppSpace.sm,
                    runSpacing: AppSpace.sm,
                    children: [
                      for (var index = 0; index < interchanges.length; index++)
                        FadeSlideIn(
                          index: index,
                          child: ActionChip(
                            onPressed: () =>
                                _quickPick(route, interchanges[index]),
                            label: Text(
                              stationName(context, interchanges[index]),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
                if (recent.isNotEmpty) ...[
                  const SizedBox(height: AppSpace.xl),
                  Text(l10n.recentSearches, style: theme.textTheme.titleSmall),
                  const SizedBox(height: AppSpace.md),
                  Wrap(
                    spacing: AppSpace.sm,
                    runSpacing: AppSpace.sm,
                    children: [
                      for (var index = 0; index < recent.length; index++)
                        FadeSlideIn(
                          index: index,
                          child: _RecentChip(
                            entry: recent[index],
                            network: route.network,
                            onTap: () {
                              route.setFrom(recent[index].fromId);
                              route.setTo(recent[index].toId);
                            },
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
    );
  }

  /// Interchange stations come straight from the data: any station served by
  /// more than one line. Shown until there is history to show instead.
  List<Station> _interchanges(BuildContext context, NetworkData network) {
    final stations = [
      for (final station in network.stations)
        if (network.linesServing(station.id).length > 1) station,
    ];
    stations.sort(
      (a, b) => stationName(context, a).compareTo(stationName(context, b)),
    );
    return stations.take(4).toList();
  }

  void _quickPick(RouteProvider route, Station station) {
    AppHaptics.tap();
    if (route.fromId == null) {
      route.setFrom(station.id);
    } else if (route.toId == null) {
      route.setTo(station.id);
    } else {
      route.setFrom(station.id);
    }
  }
}

class _NoData extends StatelessWidget {
  const _NoData();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 40,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpace.md),
            Text(
              l10n.noData,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpace.lg),
            FilledButton(
              onPressed: () {
                context.read<RouteProvider>().load();
                context.read<LibraryProvider>().refresh();
              },
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentChip extends StatelessWidget {
  const _RecentChip({
    required this.entry,
    required this.network,
    required this.onTap,
  });

  final HistoryEntry entry;
  final NetworkData network;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      label: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 240),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                stationNameById(context, network, entry.fromId),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Padding(
              padding: EdgeInsetsDirectional.symmetric(horizontal: AppSpace.xs),
              child: Icon(Icons.arrow_forward, size: 14),
            ),
            Flexible(
              child: Text(
                stationNameById(context, network, entry.toId),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({
    required this.from,
    required this.to,
    required this.l10n,
    required this.swapTurns,
    required this.onPickFrom,
    required this.onPickTo,
    required this.onSwap,
  });

  final Station? from;
  final Station? to;
  final AppLocalizations l10n;
  final double swapTurns;
  final VoidCallback onPickFrom;
  final VoidCallback onPickTo;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(18),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                vertical: AppSpace.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _Dot(filled: false),
                  Container(
                    width: 2,
                    height: 30,
                    color: theme.colorScheme.outlineVariant,
                  ),
                  const _Dot(filled: true),
                ],
              ),
            ),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _StationField(
                    label: l10n.fromLabel,
                    value: from == null ? null : stationName(context, from!),
                    placeholder: l10n.selectStation,
                    onTap: onPickFrom,
                  ),
                  const SizedBox(height: AppSpace.sm),
                  _StationField(
                    label: l10n.toLabel,
                    value: to == null ? null : stationName(context, to!),
                    placeholder: l10n.selectStation,
                    onTap: onPickTo,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpace.sm),
            IconButton.filledTonal(
              onPressed: onSwap,
              tooltip: l10n.swapStations,
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
              ),
              icon: AnimatedRotation(
                turns: swapTurns,
                duration: AppMotion.of(context, AppMotion.base),
                curve: AppMotion.decelerate,
                child: const Icon(Icons.swap_vert),
              ),
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
    required this.value,
    required this.placeholder,
    required this.onTap,
  });

  final String label;
  final String? value;
  final String placeholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = this.value;
    final text = value ?? placeholder;
    return Semantics(
      button: true,
      label: label,
      value: text,
      onTap: onTap,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.field),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedSwitcher(
                        duration: AppMotion.of(context, AppMotion.base),
                        switchInCurve: AppMotion.decelerate,
                        transitionBuilder: (child, animation) =>
                            FadeTransition(opacity: animation, child: child),
                        child: Text(
                          text,
                          key: ValueKey(text),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: value == null
                                ? theme.colorScheme.onSurfaceVariant
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpace.sm),
                Icon(
                  Icons.expand_more,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.filled});

  final bool filled;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? primary : null,
        border: filled ? null : Border.all(color: primary, width: 2),
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.error_outline, size: 18, color: theme.colorScheme.error),
        const SizedBox(width: AppSpace.sm),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
      ],
    );
  }
}
