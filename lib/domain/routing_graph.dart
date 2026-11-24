import 'models/models.dart';

class NodeKey {
  const NodeKey({required this.stationId, required this.lineId});

  final String stationId;
  final int lineId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NodeKey &&
          other.stationId == stationId &&
          other.lineId == lineId;

  @override
  int get hashCode => Object.hash(stationId, lineId);
}

class Edge {
  const Edge({
    required this.to,
    required this.cost,
    required this.stations,
    required this.isTransfer,
  });

  final NodeKey to;
  final int cost;
  final int stations;
  final bool isTransfer;
}

class RoutingGraph {
  RoutingGraph._(this.adjacency, this._branchByNode, this._data);

  factory RoutingGraph.fromNetwork(NetworkData data, RoutingConfig config) {
    final adjacency = <NodeKey, List<Edge>>{
      for (final lineStation in data.lineStations)
        NodeKey(stationId: lineStation.stationId, lineId: lineStation.lineId):
            <Edge>[],
    };
    final branchByNode = <NodeKey, String>{
      for (final lineStation in data.lineStations)
        NodeKey(stationId: lineStation.stationId, lineId: lineStation.lineId):
            lineStation.branch,
    };

    final perStop = _tenths(config.perStopMinutes);
    final transferPenalty = _tenths(config.transferPenaltyMinutes);

    final ordered = [...data.lineStations]
      ..sort((a, b) {
        final byLine = a.lineId.compareTo(b.lineId);
        if (byLine != 0) return byLine;
        final byBranch = a.branch.compareTo(b.branch);
        if (byBranch != 0) return byBranch;
        return a.seq.compareTo(b.seq);
      });
    for (var i = 1; i < ordered.length; i++) {
      final previous = ordered[i - 1];
      final current = ordered[i];
      if (previous.lineId != current.lineId ||
          previous.branch != current.branch) {
        continue;
      }
      _connect(
        adjacency,
        NodeKey(stationId: previous.stationId, lineId: previous.lineId),
        NodeKey(stationId: current.stationId, lineId: current.lineId),
        cost: perStop,
        stations: 1,
        isTransfer: false,
      );
    }

    for (final branch in data.branches) {
      if (branch.branch == 'main') continue;
      final start = NodeKey(
        stationId: branch.startsAfter,
        lineId: branch.lineId,
      );
      if (!adjacency.containsKey(start)) {
        throw StateError(
          'Fork starts_after station ${branch.startsAfter} is not on line '
          '${branch.lineId}',
        );
      }
      final first = data.lineStations.firstWhere(
        (lineStation) =>
            lineStation.lineId == branch.lineId &&
            lineStation.branch == branch.branch &&
            lineStation.seq == 1,
        orElse: () => throw StateError(
          'Branch ${branch.branch} on line ${branch.lineId} has no station '
          'at seq 1',
        ),
      );
      _connect(
        adjacency,
        start,
        NodeKey(stationId: first.stationId, lineId: first.lineId),
        cost: perStop,
        stations: 1,
        isTransfer: false,
      );
    }

    for (final station in data.stations) {
      final lines = data.linesServing(station.id);
      for (var i = 0; i < lines.length; i++) {
        for (var j = i + 1; j < lines.length; j++) {
          _connect(
            adjacency,
            NodeKey(stationId: station.id, lineId: lines[i].id),
            NodeKey(stationId: station.id, lineId: lines[j].id),
            cost: transferPenalty,
            stations: 0,
            isTransfer: true,
          );
        }
      }
    }

    final immutableAdjacency = <NodeKey, List<Edge>>{
      for (final entry in adjacency.entries)
        entry.key: List.unmodifiable(entry.value),
    };
    return RoutingGraph._(
      Map.unmodifiable(immutableAdjacency),
      branchByNode,
      data,
    );
  }

  final Map<NodeKey, List<Edge>> adjacency;
  final Map<NodeKey, String> _branchByNode;
  final NetworkData _data;

  String branchOf(NodeKey node) {
    final branch = _branchByNode[node];
    if (branch == null) {
      throw StateError('Unknown node ${node.stationId} on line ${node.lineId}');
    }
    return branch;
  }

  Iterable<NodeKey> nodesOfStation(String stationId) => _data
      .linesServing(stationId)
      .map((line) => NodeKey(stationId: stationId, lineId: line.id));

  static int _tenths(double minutes) => (minutes * 10).round();

  static void _connect(
    Map<NodeKey, List<Edge>> adjacency,
    NodeKey from,
    NodeKey to, {
    required int cost,
    required int stations,
    required bool isTransfer,
  }) {
    adjacency
        .putIfAbsent(from, () => <Edge>[])
        .add(
          Edge(to: to, cost: cost, stations: stations, isTransfer: isTransfer),
        );
    adjacency
        .putIfAbsent(to, () => <Edge>[])
        .add(
          Edge(
            to: from,
            cost: cost,
            stations: stations,
            isTransfer: isTransfer,
          ),
        );
  }
}
