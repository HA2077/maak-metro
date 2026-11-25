import 'package:maak_metro/features/network/domain/models/models.dart';

import 'dijkstra.dart';
import 'fare_calculator.dart';
import 'leg_builder.dart';
import 'models/models.dart';
import 'routing_graph.dart';

RouteResult? findRoute({
  required String fromId,
  required String toId,
  required NetworkData data,
  required RoutingConfig config,
}) {
  if (fromId == toId) return null;
  if (data.stationById(fromId) == null || data.stationById(toId) == null) {
    return null;
  }

  final graph = RoutingGraph.fromNetwork(data, config);
  final starts = graph.nodesOfStation(fromId).toSet();
  final goals = graph.nodesOfStation(toId).toSet();
  if (starts.isEmpty || goals.isEmpty) return null;

  final shortest = findCheapestPath(graph, starts, goals);
  if (shortest == null) return null;

  final legs = buildLegs(shortest.path, graph);
  final stationCount = shortest.stations;
  final transfers = legs.length - 1;
  final estimatedMinutes =
      stationCount * config.perStopMinutes +
      transfers * config.transferPenaltyMinutes;

  return RouteResult(
    fromId: fromId,
    toId: toId,
    legs: legs,
    stationCount: stationCount,
    transfers: transfers,
    estimatedMinutes: estimatedMinutes,
    fareEgp: FareCalculator(data.fares).fareFor(stationCount),
  );
}
