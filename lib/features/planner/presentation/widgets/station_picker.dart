import 'package:flutter/material.dart';

import 'package:maak_metro/core/l10n/app_localizations.dart';
import 'package:maak_metro/core/motion/app_haptics.dart';
import 'package:maak_metro/core/theme/app_theme.dart';
import 'package:maak_metro/core/utils/localized_names.dart';
import 'package:maak_metro/core/utils/station_search.dart';
import 'package:maak_metro/features/network/domain/models/station.dart';

/// Full-height sheet with a search field. Returns the picked station, or null
/// when the user closes it. Dismissible by drag and by the close button.
Future<Station?> showStationPicker(
  BuildContext context, {
  required List<Station> stations,
  required String title,
}) {
  return showModalBottomSheet<Station>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
    builder: (_) => _StationPickerSheet(stations: stations, title: title),
  );
}

class _StationPickerSheet extends StatefulWidget {
  const _StationPickerSheet({required this.stations, required this.title});

  final List<Station> stations;
  final String title;

  @override
  State<_StationPickerSheet> createState() => _StationPickerSheetState();
}

class _StationPickerSheetState extends State<_StationPickerSheet> {
  final TextEditingController _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final results = searchStations(
      widget.stations,
      _query.text,
      name: (station) => stationName(context, station),
      otherName: (station) => otherStationName(context, station),
    );

    return FractionallySizedBox(
      heightFactor: 0.9,
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: AppSpace.lg,
          end: AppSpace.lg,
          bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpace.sm,
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
                      widget.title,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: l10n.close,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.xs),
            TextField(
              controller: _query,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: l10n.searchStations,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _query.clear();
                          setState(() {});
                        },
                        tooltip: l10n.close,
                        icon: const Icon(Icons.clear),
                      ),
              ),
            ),
            const SizedBox(height: AppSpace.sm),
            Expanded(
              child: results.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 32,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: AppSpace.sm),
                          Text(
                            l10n.noStationsFound,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final station = results[index];
                        return ListTile(
                          title: Text(stationName(context, station)),
                          subtitle: Text(
                            otherStationName(context, station),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          onTap: () {
                            AppHaptics.tap();
                            Navigator.of(context).pop(station);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
