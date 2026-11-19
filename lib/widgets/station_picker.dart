import 'package:flutter/material.dart';
import 'package:maak_metro/core/l10n/app_localizations.dart';
import 'package:maak_metro/core/utils/localized_names.dart';
import 'package:maak_metro/core/utils/station_search.dart';
import 'package:maak_metro/domain/models/metro_models.dart';

/// Full-height sheet with a search field. Returns the picked station, or null
/// when the user closes it.
Future<Station?> showStationPicker(
  BuildContext context, {
  required List<Station> stations,
  required String title,
}) {
  return showModalBottomSheet<Station>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
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
          start: 16,
          end: 16,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
              controller: _query,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: l10n.searchStations,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: results.isEmpty
                  ? Center(
                      child: Text(
                        l10n.noStationsFound,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
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
                          onTap: () => Navigator.of(context).pop(station),
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
