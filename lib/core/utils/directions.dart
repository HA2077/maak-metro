import 'package:maak_metro/features/network/domain/models/models.dart';
import 'package:maak_metro/features/planner/domain/models/models.dart';

({String a, String b}) lineTerminusNames(Line line, String languageCode) {
  final arabic = languageCode == 'ar';
  return (
    a: arabic ? line.terminusAAr : line.terminusAEn,
    b: arabic ? line.terminusBAr : line.terminusBEn,
  );
}

String lineTerminusHeader(Line line, String languageCode) {
  final names = lineTerminusNames(line, languageCode);
  return '${names.a} ↔ ${names.b}';
}

String legTerminus(RouteLeg leg, NetworkData network, String languageCode) {
  final line = network.lineById(leg.lineId);
  if (line == null) return '';

  final arabic = languageCode == 'ar';
  final ids = leg.stationIds;
  if (ids.length < 2) {
    return arabic ? line.terminusAAr : line.terminusAEn;
  }

  final first = _seqOf(network, leg.lineId, leg.branch, ids.first);
  final last = _seqOf(network, leg.lineId, leg.branch, ids.last);
  if (last >= first) {
    for (final branch in network.branches) {
      if (branch.lineId == leg.lineId && branch.branch == leg.branch) {
        return arabic ? branch.terminusAr : branch.terminusEn;
      }
    }
    return arabic ? line.terminusBAr : line.terminusBEn;
  }
  return arabic ? line.terminusAAr : line.terminusAEn;
}

int _seqOf(NetworkData network, int lineId, String branch, String stationId) {
  for (final row in network.lineStations) {
    if (row.lineId == lineId &&
        row.branch == branch &&
        row.stationId == stationId) {
      return row.seq;
    }
  }
  return 0;
}
