import 'fare_bracket.dart';
import 'line.dart';
import 'line_branch.dart';
import 'line_station.dart';
import 'station.dart';

class NetworkData {
  NetworkData({
    required List<Line> lines,
    required List<Station> stations,
    required List<LineBranch> branches,
    required List<LineStation> lineStations,
    required List<FareBracket> fares,
    required this.snapshotDate,
  }) : lines = List.unmodifiable(lines),
       stations = List.unmodifiable(stations),
       branches = List.unmodifiable(branches),
       lineStations = List.unmodifiable(lineStations),
       fares = List.unmodifiable(_sortFares(fares)),
       _stationsById = {for (final station in stations) station.id: station},
       _linesById = {for (final line in lines) line.id: line},
       _lineStationsByLine = _groupBy(
         lineStations,
         (lineStation) => lineStation.lineId,
       ),
       _branchesByLine = _groupBy(branches, (branch) => branch.lineId),
       _linesByStation = _buildLinesByStation(lines, lineStations);

  final List<Line> lines;
  final List<Station> stations;
  final List<LineBranch> branches;
  final List<LineStation> lineStations;
  final List<FareBracket> fares;
  final String snapshotDate;

  final Map<String, Station> _stationsById;
  final Map<int, Line> _linesById;
  final Map<int, List<LineStation>> _lineStationsByLine;
  final Map<int, List<LineBranch>> _branchesByLine;
  final Map<String, List<Line>> _linesByStation;

  Station? stationById(String id) => _stationsById[id];

  Line? lineById(int id) => _linesById[id];

  List<Line> linesServing(String stationId) =>
      List.unmodifiable(_linesByStation[stationId] ?? const <Line>[]);

  List<LineStation> stationsOfLine(int lineId) {
    final lineStations = _lineStationsByLine[lineId] ?? const <LineStation>[];
    final ordered = <LineStation>[
      for (final lineStation in lineStations)
        if (lineStation.branch == 'main') lineStation,
    ]..sort((a, b) => a.seq.compareTo(b.seq));

    for (final branch in _branchesByLine[lineId] ?? const <LineBranch>[]) {
      final branchStations = <LineStation>[
        for (final lineStation in lineStations)
          if (lineStation.branch == branch.branch) lineStation,
      ]..sort((a, b) => a.seq.compareTo(b.seq));
      ordered.addAll(branchStations);
    }

    return List.unmodifiable(ordered);
  }

  static List<FareBracket> _sortFares(List<FareBracket> fares) =>
      [...fares]..sort((a, b) => a.maxStations.compareTo(b.maxStations));

  static Map<K, List<T>> _groupBy<T, K>(List<T> items, K Function(T) keyOf) {
    final result = <K, List<T>>{};
    for (final item in items) {
      (result[keyOf(item)] ??= <T>[]).add(item);
    }
    return result;
  }

  static Map<String, List<Line>> _buildLinesByStation(
    List<Line> lines,
    List<LineStation> lineStations,
  ) {
    final stationIdsByLine = <int, Set<String>>{};
    for (final lineStation in lineStations) {
      (stationIdsByLine[lineStation.lineId] ??= <String>{}).add(
        lineStation.stationId,
      );
    }

    final result = <String, List<Line>>{};
    for (final line in lines) {
      for (final stationId in stationIdsByLine[line.id] ?? const <String>{}) {
        (result[stationId] ??= <Line>[]).add(line);
      }
    }
    return result;
  }
}
