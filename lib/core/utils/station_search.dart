import 'package:maak_metro/core/utils/arabic_normalize.dart';
import 'package:maak_metro/domain/models/metro_models.dart';

/// Filters the station list for the picker, best match first: exact name, then
/// prefix, then contains. Both the active-language name and the other language
/// name are searched, after [normalizeSearch].
List<Station> searchStations(
  List<Station> stations,
  String query, {
  required String Function(Station station) name,
  required String Function(Station station) otherName,
}) {
  final needle = normalizeSearch(query);
  if (needle.isEmpty) return stations;

  final matches = <({int rank, String label, Station station})>[];
  for (final station in stations) {
    final primary = normalizeSearch(name(station));
    final secondary = normalizeSearch(otherName(station));
    var rank = 4;
    for (final candidate in [primary, secondary]) {
      if (candidate == needle) {
        rank = 0;
        break;
      }
      if (candidate.startsWith(needle)) {
        if (rank > 1) rank = 1;
      } else if (candidate.contains(needle) && rank > 2) {
        rank = 2;
      }
    }
    if (rank < 4) {
      matches.add((rank: rank, label: primary, station: station));
    }
  }

  matches.sort((a, b) {
    final byRank = a.rank.compareTo(b.rank);
    return byRank != 0 ? byRank : a.label.compareTo(b.label);
  });
  return [for (final match in matches) match.station];
}
