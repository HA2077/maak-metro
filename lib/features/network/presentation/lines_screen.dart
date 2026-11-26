import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maak_metro/core/l10n/app_localizations.dart';
import 'package:maak_metro/core/motion/app_haptics.dart';
import 'package:maak_metro/core/motion/fade_slide_in.dart';
import 'package:maak_metro/core/theme/app_theme.dart';
import 'package:maak_metro/core/theme/line_colors.dart';
import 'package:maak_metro/core/utils/digits.dart';
import 'package:maak_metro/core/utils/directions.dart';
import 'package:maak_metro/core/utils/localized_names.dart';
import 'package:maak_metro/features/network/domain/models/models.dart';
import 'package:maak_metro/features/network/presentation/widgets/line_chip.dart';

import 'network_cubit.dart';

const String _mapAsset = 'assets/images/metro_map.png';

class LinesScreen extends StatelessWidget {
  const LinesScreen({super.key, required this.onStationSelected});

  final void Function(Station station, {required bool from}) onStationSelected;

  static String _branchTitle(String branch) => branch
      .split('_')
      .where((word) => word.isNotEmpty)
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');

  void _showMap(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
      backgroundColor: AppTheme.light.colorScheme.surface,
      builder: (sheetContext) {
        final l10n = AppLocalizations.of(sheetContext);
        return Theme(
          data: AppTheme.light,
          child: FractionallySizedBox(
            heightFactor: 0.9,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpace.lg,
                AppSpace.md,
                AppSpace.lg,
                AppSpace.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          header: true,
                          child: Text(
                            l10n.metroMap,
                            style: AppTheme.light.textTheme.titleLarge,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        tooltip: l10n.close,
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.sm),
                  Expanded(
                    child: Semantics(
                      label: l10n.metroMap,
                      child: InteractiveViewer(
                        minScale: 1.0,
                        maxScale: 4.0,
                        child: Center(
                          child: Image.asset(_mapAsset, fit: BoxFit.contain),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showStation(BuildContext context, Station station) {
    final network = context.read<NetworkCubit>().state.network;
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
          AppHaptics.confirm();
          Navigator.of(sheetContext).pop();
          onStationSelected(station, from: from);
        }

        return SingleChildScrollView(
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
    final network = context.select((NetworkCubit cubit) => cubit.state.network);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.linesTitle)),
      body: network == null || network.lines.isEmpty
          ? const SizedBox.shrink()
          : Column(
              children: [
                _MapPreviewCard(onTap: () => _showMap(context)),
                Expanded(child: _lineList(context, network, theme)),
              ],
            ),
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
        final termini = lineTerminusNames(
          line,
          Localizations.localeOf(context).languageCode,
        );
        final terminusText = l10n.lineTermini(termini.a, termini.b);

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
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizedDigits(context, l10n.stationsCount(stationCount)),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (termini.a.isNotEmpty)
                    Semantics(
                      label: terminusText,
                      child: ExcludeSemantics(
                        child: Text(
                          terminusText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
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

class _MapPreviewCard extends StatelessWidget {
  const _MapPreviewCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FadeSlideIn(
      child: Semantics(
        button: true,
        label: l10n.openMetroMap,
        onTap: onTap,
        child: ExcludeSemantics(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Theme(
              data: AppTheme.light,
              child: Builder(
                builder: (context) {
                  final theme = Theme.of(context);
                  return Card(
                    color: theme.colorScheme.surface,
                    margin: const EdgeInsetsDirectional.only(
                      start: 18,
                      top: 18,
                      end: 18,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 88,
                          height: 72,
                          child: Image.asset(_mapAsset, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: AppSpace.md),
                        Expanded(
                          child: Text(
                            l10n.metroMap,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        Icon(Icons.zoom_in, color: theme.colorScheme.primary),
                        const SizedBox(width: AppSpace.lg),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
