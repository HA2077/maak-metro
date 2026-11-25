import 'package:maak_metro/features/network/domain/models/models.dart';

import 'arabic_normalize.dart';

/// Filters the station list for the picker, best match first: exact name, then
/// prefix, contains, and finally one-typo matches. Both the active-language name
/// and the other language name are searched, after [normalizeSearch].
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
    final candidates = [primary, secondary];
    var rank = 4;
    for (final candidate in candidates) {
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
    if (rank == 4 && _isNearMiss(candidates, needle)) {
      rank = 3;
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

/// One edit away from the whole name or from one of its words. Short queries
/// are excluded because at that length a single edit matches too much.
bool _isNearMiss(List<String> candidates, String needle) {
  if (needle.length < 3) return false;
  for (final candidate in candidates) {
    if (_withinOneEdit(candidate, needle)) return true;
    for (final word in candidate.split(' ')) {
      if (_withinOneEdit(word, needle)) return true;
    }
  }
  return false;
}

/// Levenshtein distance of at most one: a substitution, an insertion, a
/// deletion, or a shortened last word.
bool _withinOneEdit(String a, String b) {
  if ((a.length - b.length).abs() > 1) return false;
  var i = 0;
  var j = 0;
  var edits = 0;
  while (i < a.length && j < b.length) {
    if (a[i] == b[j]) {
      i++;
      j++;
      continue;
    }
    if (++edits > 1) return false;
    if (a.length > b.length) {
      i++;
    } else if (b.length > a.length) {
      j++;
    } else {
      i++;
      j++;
    }
  }
  return edits + (a.length - i) + (b.length - j) <= 1;
}
