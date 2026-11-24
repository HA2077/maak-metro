import 'package:collection/collection.dart';

import 'routing_graph.dart';

class DijkstraResult {
  const DijkstraResult({
    required this.path,
    required this.cost,
    required this.transfers,
    required this.stations,
  });

  final List<NodeKey> path;
  final int cost;
  final int transfers;
  final int stations;
}

class Costs {
  const Costs(this.cost, this.transfers, this.stations);

  final int cost;
  final int transfers;
  final int stations;

  Costs operator +(Edge edge) => Costs(
    cost + edge.cost,
    transfers + (edge.isTransfer ? 1 : 0),
    stations + edge.stations,
  );
}

int compareCosts(Costs a, Costs b) {
  final byCost = a.cost.compareTo(b.cost);
  if (byCost != 0) return byCost;
  final byTransfers = a.transfers.compareTo(b.transfers);
  if (byTransfers != 0) return byTransfers;
  return a.stations.compareTo(b.stations);
}

class State {
  const State(this.node, this.costs);

  final NodeKey node;
  final Costs costs;
}

int compareStates(State a, State b) {
  final byCosts = compareCosts(a.costs, b.costs);
  if (byCosts != 0) return byCosts;

  final byStation = a.node.stationId.compareTo(b.node.stationId);
  if (byStation != 0) return byStation;

  return a.node.lineId.compareTo(b.node.lineId);
}

DijkstraResult? findCheapestPath(
  RoutingGraph graph,
  Set<NodeKey> starts,
  Set<NodeKey> goals,
) {
  if (starts.isEmpty || goals.isEmpty) return null;

  final queue = PriorityQueue<State>(compareStates);
  final best = <NodeKey, Costs>{};
  final previous = <NodeKey, NodeKey>{};
  const initial = Costs(0, 0, 0);

  for (final start in starts) {
    best[start] = initial;
    queue.add(State(start, initial));
  }

  while (queue.isNotEmpty) {
    final state = queue.removeFirst();
    final current = best[state.node];
    if (current == null || compareCosts(current, state.costs) != 0) continue;

    if (goals.contains(state.node)) {
      final path = <NodeKey>[state.node];
      var node = state.node;
      while (!starts.contains(node)) {
        final predecessor = previous[node];
        if (predecessor == null) {
          throw StateError(
            'No predecessor for ${node.stationId} on line '
            '${node.lineId}',
          );
        }
        node = predecessor;
        path.add(node);
      }
      return DijkstraResult(
        path: path.reversed.toList(),
        cost: current.cost,
        transfers: current.transfers,
        stations: current.stations,
      );
    }

    for (final edge in graph.adjacency[state.node] ?? const <Edge>[]) {
      final next = state.costs + edge;
      final known = best[edge.to];
      if (known != null && compareCosts(next, known) >= 0) continue;
      best[edge.to] = next;
      previous[edge.to] = state.node;
      queue.add(State(edge.to, next));
    }
  }

  return null;
}
