import 'package:flutter/material.dart';
import 'package:maak_metro/core/l10n/app_localizations.dart';
import 'package:maak_metro/core/motion/app_haptics.dart';
import 'package:maak_metro/core/motion/fade_slide_in.dart';
import 'package:maak_metro/core/theme/app_theme.dart';
import 'package:maak_metro/core/theme/line_colors.dart';
import 'package:maak_metro/core/utils/digits.dart';
import 'package:maak_metro/core/utils/localized_names.dart';
import 'package:maak_metro/domain/models/metro_models.dart';
import 'package:maak_metro/providers/route_provider.dart';
import 'package:maak_metro/screens/home_shell.dart';
import 'package:maak_metro/screens/metro_map_screen.dart';
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
    final shell = HomeShell.of(context);
    final network = route.network;
    final lines = network.linesServing(station.id);

    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      constraints: const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
      builder: (sheetContext) {
        final l10n = AppLocalizations.of(sheetContext);
        final theme = Theme.of(sheetContext);
        void goToPlanner() {
          Navigator.of(sheetContext).pop();
          shell.select(0);
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
                            onPressed: () {
                              AppHaptics.confirm();
                              route.setFrom(station.id);
                              goToPlanner();
                            },
                            child: Text(l10n.setAsFrom),
                          ),
                        ),
                        const SizedBox(width: AppSpace.md),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              AppHaptics.confirm();
                              route.setTo(station.id);
                              goToPlanner();
                            },
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
      appBar: AppBar(
        title: Text(l10n.linesTitle),
        actions: [
          IconButton(
            onPressed: () => _openMap(context),
            tooltip: l10n.mapTitle,
            icon: const Icon(Icons.map_outlined),
          ),
        ],
      ),
      body: network.lines.isEmpty
          ? const SizedBox.shrink()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    18,
                    AppSpace.md,
                    18,
                    0,
                  ),
                  child: FilledButton.tonalIcon(
                    onPressed: () => _openMap(context),
                    icon: const Icon(Icons.map_outlined),
                    label: Text(l10n.mapTitle),
                  ),
                ),
                Expanded(child: _lineList(context, network, theme)),
              ],
            ),
    );
  }

  void _openMap(BuildContext context) {
    AppHaptics.tap();
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const MetroMapScreen()));
  }

  Widget _lineList(BuildContext context, NetworkData network, ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return ListView.separated(
      padding: const EdgeInsetsDirectional.all(18),
      itemCount: network.lines.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpace.md),
      itemBuilder: (context, index) {
        final line = network.lines[index];
        final branches = network.branchesOf(line.id);
        final groups = ['main', ...branches.where((b) => b != 'main')];
        final color = parseHexColor(line.colorHex);
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
                localizedDigits(
                  context,
                  l10n.stationsCount(network.lineStationsOf(line.id).length),
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              children: [
                for (final branch in groups) ...[
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
                  for (final station in network.stationsOf(line.id, branch))
                    ListTile(
                      contentPadding: const EdgeInsetsDirectional.only(
                        start: 18,
                        end: 18,
                      ),
                      minLeadingWidth: 10,
                      leading: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: color, width: 2),
                        ),
                      ),
                      title: Text(stationName(context, station)),
                      onTap: () => _showStation(context, station),
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
