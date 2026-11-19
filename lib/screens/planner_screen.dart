import 'package:flutter/material.dart';
import 'package:maak_metro/core/l10n/app_localizations.dart';
import 'package:maak_metro/core/theme/app_theme.dart';
import 'package:maak_metro/core/utils/localized_names.dart';
import 'package:maak_metro/domain/models/metro_models.dart';
import 'package:maak_metro/providers/library_provider.dart';
import 'package:maak_metro/providers/route_provider.dart';
import 'package:maak_metro/screens/route_result_screen.dart';
import 'package:maak_metro/widgets/station_picker.dart';
import 'package:provider/provider.dart';

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

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
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const RouteResultScreen()));
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
    final route = context.watch<RouteProvider>();
    final library = context.watch<LibraryProvider>();
    final errorText = _errorText(l10n, route.error);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.plannerTitle)),
      body: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpace.lg,
          AppSpace.sm,
          AppSpace.lg,
          AppSpace.xl,
        ),
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: AppSpace.lg),
            child: Text(
              l10n.plannerHint,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          _TripCard(
            from: route.fromStation,
            to: route.toStation,
            l10n: l10n,
            onPickFrom: () => _pick(context, from: true),
            onPickTo: () => _pick(context, from: false),
            onSwap: route.swap,
          ),
          const SizedBox(height: AppSpace.lg),
          FilledButton(
            onPressed: route.canSearch ? () => _search(context) : null,
            child: route.loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.findRoute),
          ),
          if (errorText != null) ...[
            const SizedBox(height: AppSpace.md),
            _ErrorText(text: errorText),
          ],
          if (library.history.isNotEmpty) ...[
            const SizedBox(height: AppSpace.xl),
            Text(
              l10n.recentSearches,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpace.md),
            Wrap(
              spacing: AppSpace.sm,
              runSpacing: AppSpace.sm,
              children: [
                for (final entry in library.history.take(3))
                  ActionChip(
                    onPressed: () {
                      route.setFrom(entry.fromId);
                      route.setTo(entry.toId);
                    },
                    label: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 240),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              stationNameById(
                                context,
                                route.network,
                                entry.fromId,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsetsDirectional.symmetric(
                              horizontal: AppSpace.xs,
                            ),
                            child: Icon(Icons.arrow_forward, size: 14),
                          ),
                          Flexible(
                            child: Text(
                              stationNameById(
                                context,
                                route.network,
                                entry.toId,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({
    required this.from,
    required this.to,
    required this.l10n,
    required this.onPickFrom,
    required this.onPickTo,
    required this.onSwap,
  });

  final Station? from;
  final Station? to;
  final AppLocalizations l10n;
  final VoidCallback onPickFrom;
  final VoidCallback onPickTo;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpace.lg),
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
              icon: const Icon(Icons.swap_vert),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.field),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(vertical: AppSpace.md),
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
            Text(
              value ?? placeholder,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                color: value == null
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.onSurface,
              ),
            ),
          ],
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
