import 'package:flutter/material.dart';
import 'package:maak_metro/core/l10n/app_localizations.dart';
import 'package:maak_metro/core/motion/app_haptics.dart';
import 'package:maak_metro/core/motion/fade_slide_in.dart';
import 'package:maak_metro/core/theme/app_theme.dart';
import 'package:maak_metro/core/theme/line_colors.dart';
import 'package:maak_metro/core/utils/digits.dart';
import 'package:maak_metro/core/utils/localized_names.dart';
import 'package:maak_metro/domain/domain.dart';
import 'package:maak_metro/providers/route_provider.dart';
import 'package:maak_metro/screens/home_shell.dart';
import 'package:maak_metro/widgets/line_chip.dart';
import 'package:provider/provider.dart';

class LinesScreen extends StatelessWidget {
  const LinesScreen({super.key});

  static String _branchTitle(String branch) => branch
      .split('_')
      .where((word) => word.isNotEmpty)
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');

  void _showStation(BuildContext context, Station station) {
    final route = context.read<RouteProvider>();
    final network = route.network;
    if (network == null) return;
    final lines = network.linesServing(station.id);

    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      constraints: const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
      builder: (sheetContext) {
        final l10n = AppLocalizations.of(sheetContext);
        final theme = Theme.of(sheetContext);
        void setAs({required bool from}) {
          if (from) {
            route.setFrom(station);
          } else {
            route.setTo(station);
          }
          AppHaptics.confirm();
          Navigator.of(sheetContext).pop();
          HomeShell.openPlanner(context);
        }

        return Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpace.xl,
            0,
            AppSpace.sm,
            AppSpace.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          header: true,
                          child: Text(
                            stationName(sheetContext, station),
                            style: theme.textTheme.headlineSmall,
                          ),
                        ),
                        const SizedBox(height: AppSpace.xs),
                        Text(
                          otherStationName(sheetContext, station),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    tooltip: l10n.close,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.lg),
              Padding(
                padding: const EdgeInsetsDirectional.only(end: AppSpace.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.servesLines,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpace.sm),
                    Wrap(
                      spacing: AppSpace.sm,
                      runSpacing: AppSpace.sm,
                      children: [
                        for (final line in lines) LineChip(line: line),
                      ],
                    ),
                    const SizedBox(height: AppSpace.xl),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setAs(from: true),
                            child: Text(l10n.setAsFrom),
                          ),
                        ),
                        const SizedBox(width: AppSpace.md),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => setAs(from: false),
                            child: Text(l10n.setAsTo),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final network = context.watch<RouteProvider>().network;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.linesTitle)),
      body: network == null || network.lines.isEmpty
          ? const SizedBox.shrink()
          : _lineList(context, network, theme),
    );
  }

  Widget _lineList(BuildContext context, NetworkData network, ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return ListView.separated(
      padding: const EdgeInsetsDirectional.all(18),
      itemCount: network.lines.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpace.md),
      itemBuilder: (context, index) {
        final line = network.lines[index];
        final color = parseHexColor(line.colorHex);
        final rows = network.stationsOfLine(line.id);
        final branches = <String>[];
        for (final row in rows) {
          if (!branches.contains(row.branch)) branches.add(row.branch);
        }
        final stationCount = {for (final row in rows) row.stationId}.length;

        return FadeSlideIn(
          index: index,
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: ExpansionTile(
              leading: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              title: Text(
                lineName(context, line),
                style: theme.textTheme.titleMedium,
              ),
              subtitle: Text(
                localizedDigits(context, l10n.stationsCount(stationCount)),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              children: [
                for (final branch in branches) ...[
                  if (branch != 'main')
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        18,
                        AppSpace.lg,
                        18,
                        AppSpace.xs,
                      ),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          l10n.branchLabel(_branchTitle(branch)),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  for (final row in rows)
                    if (row.branch == branch)
                      _StationRow(
                        station: network.stationById(row.stationId),
                        color: color,
                        onTap: _showStation,
                      ),
                ],
                const SizedBox(height: AppSpace.sm),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StationRow extends StatelessWidget {
  const _StationRow({
    required this.station,
    required this.color,
    required this.onTap,
  });

  final Station? station;
  final Color color;
  final void Function(BuildContext, Station) onTap;

  @override
  Widget build(BuildContext context) {
    final station = this.station;
    if (station == null) return const SizedBox.shrink();
    return ListTile(
      contentPadding: const EdgeInsetsDirectional.only(start: 18, end: 18),
      minLeadingWidth: 10,
      leading: _StopDot(color: color),
      title: Text(stationName(context, station)),
      onTap: () => onTap(context, station),
    );
  }
}

/// A stop is a dot threaded on the line colour, so a list of stations reads as
/// the line it belongs to rather than a list of bullets.
class _StopDot extends StatelessWidget {
  const _StopDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 28,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(width: 2, color: color.withValues(alpha: 0.35)),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
        ],
      ),
    );
  }
}
