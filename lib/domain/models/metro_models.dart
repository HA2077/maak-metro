/// Pure Dart models for the metro network. No Flutter or sqflite imports, so
/// the router and these helpers can be tested without a device.
library;

class Line {
  const Line({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.colorHex,
  });

  final int id;
  final String nameAr;
  final String nameEn;
  final String colorHex;
}

class Station {
  const Station({required this.id, required this.nameAr, required this.nameEn});

  final String id;
  final String nameAr;
  final String nameEn;
}

class LineStation {
  const LineStation({
    required this.lineId,
    required this.stationId,
    required this.branch,
    required this.seq,
  });

  final int lineId;
  final String stationId;
  final String branch;
  final int seq;
}

class LineBranch {
  const LineBranch({
    required this.lineId,
    required this.branch,
    required this.startsAfter,
  });

  final int lineId;
  final String branch;
  final String startsAfter;
}

class FareBracket {
  const FareBracket({required this.maxStations, required this.priceEgp});

  final int maxStations;
  final int priceEgp;
}

class RouteLeg {
  const RouteLeg({
    required this.lineId,
    required this.branch,
    required this.stationIds,
  });

  final int lineId;
  final String branch;

  /// Boarding station first, alighting station last.
  final List<String> stationIds;
}

class RouteResult {
  const RouteResult({
    required this.fromId,
    required this.toId,
    required this.legs,
    required this.stationCount,
    required this.transfers,
    required this.estimatedMinutes,
    required this.fareEgp,
  });

  final String fromId;
  final String toId;
  final List<RouteLeg> legs;
  final int stationCount;
  final int transfers;
  final double estimatedMinutes;
  final int fareEgp;
}

class FavoriteRoute {
  const FavoriteRoute({
    required this.id,
    required this.fromId,
    required this.toId,
    required this.createdAt,
  });

  final int id;
  final String fromId;
  final String toId;
  final String createdAt;
}

class HistoryEntry {
  const HistoryEntry({
    required this.id,
    required this.fromId,
    required this.toId,
    required this.searchedAt,
  });

  final int id;
  final String fromId;
  final String toId;
  final String searchedAt;
}

class NetworkData {
  const NetworkData({
    required this.lines,
    required this.stations,
    required this.branches,
    required this.lineStations,
    required this.fares,
    this.snapshotDate = '',
  });

  static const NetworkData empty = NetworkData(
    lines: [],
    stations: [],
    branches: [],
    lineStations: [],
    fares: [],
  );

  final List<Line> lines;
  final List<Station> stations;
  final List<LineBranch> branches;
  final List<LineStation> lineStations;
  final List<FareBracket> fares;
  final String snapshotDate;

  bool get isEmpty => stations.isEmpty;

  Station? stationById(String id) {
    for (final station in stations) {
      if (station.id == id) return station;
    }
    return null;
  }

  Line? lineById(int id) {
    for (final line in lines) {
      if (line.id == id) return line;
    }
    return null;
  }

  /// Branch ids of [lineId], empty when the line has no fork.
  List<String> branchesOf(int lineId) => [
    for (final branch in branches)
      if (branch.lineId == lineId) branch.branch,
  ];

  List<LineStation> lineStationsOf(int lineId) => [
    for (final lineStation in lineStations)
      if (lineStation.lineId == lineId) lineStation,
  ];

  /// Stations of one (line, branch), in travel order.
  List<Station> stationsOf(int lineId, String branch) {
    final rows =
        lineStations
            .where((row) => row.lineId == lineId && row.branch == branch)
            .toList()
          ..sort((a, b) => a.seq.compareTo(b.seq));
    return rows
        .map((row) => stationById(row.stationId))
        .whereType<Station>()
        .toList();
  }

  List<Line> linesServing(String stationId) {
    final ids = {
      for (final row in lineStations)
        if (row.stationId == stationId) row.lineId,
    };
    return [
      for (final line in lines)
        if (ids.contains(line.id)) line,
    ];
  }
}
