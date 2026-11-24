import 'package:flutter/material.dart';
import 'package:maak_metro/core/l10n/app_localizations.dart';
import 'package:maak_metro/core/theme/app_theme.dart';
import 'package:maak_metro/core/utils/arabic_normalize.dart';
import 'package:maak_metro/domain/domain.dart';

/// Opens a full-height bottom sheet listing [stations] with a search field.
///
/// Returns the picked station, or `null` when the sheet is dismissed. The list
/// is filtered with [stationMatchesQuery], so Arabic spelling variants and
/// English casing both match. Each row shows the name in the active language
/// with the other language as a smaller subtitle.
Future<Station?> showStationPicker(
  BuildContext context,
  List<Station> stations,
) {
  return showModalBottomSheet<Station>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => _StationPickerSheet(stations: stations),
  );
}

class _StationPickerSheet extends StatefulWidget {
  const _StationPickerSheet({required this.stations});

  final List<Station> stations;

  @override
  State<_StationPickerSheet> createState() => _StationPickerSheetState();
}

class _StationPickerSheetState extends State<_StationPickerSheet> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';
  late String _languageCode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _languageCode = Localizations.localeOf(context).languageCode;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Station> get _filtered {
    final matched = <Station>[
      for (final station in widget.stations)
        if (stationMatchesQuery(station.nameAr, _query) ||
            stationMatchesQuery(station.nameEn, _query))
          station,
    ];
    matched.sort(
      (a, b) => a
          .localizedName(_languageCode)
          .compareTo(b.localizedName(_languageCode)),
    );
    return matched;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final results = _filtered;

    return FractionallySizedBox(
      heightFactor: 0.92,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSpace.lg,
              AppSpace.sm,
              AppSpace.lg,
              AppSpace.md,
            ),
            child: TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: l10n.searchStations,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpace.xxl),
                      child: Text(
                        l10n.noStationsFound,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: results.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final station = results[index];
                      final primary = station.localizedName(_languageCode);
                      final secondary = _languageCode == 'ar'
                          ? station.nameEn
                          : station.nameAr;
                      return ListTile(
                        title: Text(primary),
                        subtitle: Text(
                          secondary,
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
    );
  }
}
