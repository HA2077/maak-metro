import 'package:flutter/material.dart';
import 'package:maak_metro/core/l10n/app_localizations.dart';
import 'package:maak_metro/core/theme/app_theme.dart';
import 'package:maak_metro/domain/domain.dart';
import 'package:maak_metro/providers/route_provider.dart';
import 'package:maak_metro/screens/home_shell.dart';
import 'package:maak_metro/widgets/line_chip.dart';
import 'package:maak_metro/widgets/summary_stat.dart';
import 'package:provider/provider.dart';

/// Every line with its stations in travel order, as expandable sections.
///
/// Tapping a station opens a sheet where it can be set as the origin or the
/// destination of a trip; doing so switches to the Planner tab.
class LinesScreen extends StatelessWidget {
  const LinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final route = context.watch<RouteProvider>();
    final network = route.network;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.linesTitle)),
      body: network == null
          ? EmptyHint(icon: Icons.subway_outlined, message: l10n.loadError)
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpace.lg),
              itemCount: network.lines.length,
              itemBuilder: (context, index) {
                final line = network.lines[index];
                return _LineSection(line: line, network: network);
              },
            ),
    );
  }
}

class _LineSection extends StatelessWidget {
  const _LineSection({required this.line, required this.network});

  final Line line;
  final NetworkData network;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final language = Localizations.localeOf(context).languageCode;
    final stations = network.stationsOfLine(line.id);
    final branches = [
      for (final branch in network.branches)
        if (branch.lineId == line.id) branch,
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpace.md),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpace.lg,
          ),
          childrenPadding: const EdgeInsetsDirectional.only(
            bottom: AppSpace.md,
          ),
          leading: LineChip(line: line),
          title: Text(
            '${stations.length}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          children: _buildStationList(context, stations, branches, language),
        ),
      ),
    );
  }

  List<Widget> _buildStationList(
    BuildContext context,
    List<LineStation> stations,
    List<LineBranch> branches,
    String language,
  ) {
    final branchNames = {for (final branch in branches) branch.branch: branch};
    final widgets = <Widget>[];
    String? lastBranch;

    for (final lineStation in stations) {
      // Line 3 forks: show a header the first time each branch appears.
      // The main trunk has no header of its own.
      if (lineStation.branch != lastBranch) {
        lastBranch = lineStation.branch;
        if (lineStation.branch != 'main') {
          widgets.add(
            _BranchHeader(
              label: AppLocalizations.of(context)
                  .branchLabel(branchNames[lineStation.branch]?.branch ?? ''),
            ),
          );
        }
      }

      final station = network.stationById(lineStation.stationId);
      if (station == null) continue;

      widgets.add(
        ListTile(
          dense: true,
          leading: const SizedBox(width: AppSpace.sm),
          title: Text(station.localizedName(language)),
          subtitle: Text(
            language == 'ar' ? station.nameEn : station.nameAr,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          trailing: network.linesServing(station.id).length > 1
              ? const Icon(Icons.sync_alt, size: 18)
              : null,
          onTap: () => _openStationSheet(context, station),
        ),
      );
    }
    return widgets;
  }

  Future<void> _openStationSheet(BuildContext context, Station station) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => _StationSheet(station: station),
    );
  }
}

class _BranchHeader extends StatelessWidget {
  const _BranchHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpace.lg,
        AppSpace.md,
        AppSpace.lg,
        AppSpace.xs,
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

class _StationSheet extends StatelessWidget {
  const _StationSheet({required this.station});

  final Station station;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final route = context.watch<RouteProvider>();
    final network = route.network;
    final language = Localizations.localeOf(context).languageCode;
    final serving = network?.linesServing(station.id) ?? const <Line>[];
    // Captured before the sheet pops; the sheet's own context is unmounted after.
    final shellContext = context;

    void apply({required bool asFrom}) {
      if (asFrom) {
        route.setFrom(station);
      } else {
        route.setTo(station);
      }
      Navigator.of(context).pop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        HomeShell.openPlanner(shellContext);
      });
    }

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpace.lg,
        AppSpace.sm,
        AppSpace.lg,
        AppSpace.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.stationDetails,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpace.xs),
          Text(
            station.localizedName(language),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            language == 'ar' ? station.nameEn : station.nameAr,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          Text(
            l10n.servesLines,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpace.sm),
          Wrap(
            spacing: AppSpace.sm,
            runSpacing: AppSpace.sm,
            children: [for (final line in serving) LineChip(line: line)],
          ),
          const SizedBox(height: AppSpace.xl),
          FilledButton.icon(
            onPressed: () => apply(asFrom: true),
            icon: const Icon(Icons.trip_origin),
            label: Text(l10n.setAsFrom),
          ),
          const SizedBox(height: AppSpace.sm),
          OutlinedButton.icon(
            onPressed: () => apply(asFrom: false),
            icon: const Icon(Icons.place),
            label: Text(l10n.setAsTo),
          ),
        ],
      ),
    );
  }
}
