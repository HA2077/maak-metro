import 'package:flutter_test/flutter_test.dart';
import 'package:maak_metro/domain/models/models.dart';
import 'package:maak_metro/domain/routing_graph.dart';

import '../fixtures/fixture_network.dart';

NodeKey _node(String stationId, int lineId) =>
    NodeKey(stationId: stationId, lineId: lineId);

Edge? _edge(RoutingGraph graph, NodeKey from, NodeKey to) {
  for (final edge in graph.adjacency[from] ?? const <Edge>[]) {
    if (edge.to == to) return edge;
  }
  return null;
}

NetworkData _networkWithBranch(LineBranch branch) {
  final fixture = buildFixtureNetwork();
  return NetworkData(
    lines: fixture.lines,
    stations: fixture.stations,
    branches: [...fixture.branches, branch],
    lineStations: fixture.lineStations,
    fares: fixture.fares,
    snapshotDate: fixture.snapshotDate,
  );
}

void main() {
  final graph = RoutingGraph.fromNetwork(
    buildFixtureNetwork(),
    const RoutingConfig(),
  );

  group('NodeKey', () {
    test('equality and hashCode use both fields', () {
      const key = NodeKey(stationId: 'x', lineId: 1);
      const same = NodeKey(stationId: 'x', lineId: 1);
      const otherLine = NodeKey(stationId: 'x', lineId: 2);
      const otherStation = NodeKey(stationId: 's4', lineId: 1);

      expect(key, same);
      expect(key.hashCode, same.hashCode);
      expect(key, isNot(otherLine));
      expect(key, isNot(otherStation));
      expect(<NodeKey, int>{key: 1}[same], 1);
    });
  });

  group('RoutingGraph.fromNetwork', () {
    test('builds one node per station-line pair and skips unused stations', () {
      final nodes = graph.adjacency.keys.toSet();

      expect(nodes.length, 17);
      expect(nodes.where((node) => node.lineId == 1).length, 5);
      expect(nodes.where((node) => node.lineId == 2).length, 4);
      expect(nodes.where((node) => node.lineId == 3).length, 8);
      expect(nodes, contains(_node('k', 3)));
      expect(nodes, isNot(contains(_node('iso', 1))));
    });

    test('builds the expected number of edges of each type', () {
      final edges = graph.adjacency.values.expand((list) => list).toList();
      final transfers = edges.where((edge) => edge.isTransfer).toList();
      final nonTransfers = edges.where((edge) => !edge.isTransfer).toList();

      final k = _node('k', 3);
      final forks = [
        _edge(graph, k, _node('p1', 3)),
        _edge(graph, _node('p1', 3), k),
        _edge(graph, k, _node('q1', 3)),
        _edge(graph, _node('q1', 3), k),
      ];

      expect(edges.length, 32);
      expect(transfers.length, 4);
      expect(nonTransfers.length, 28);
      expect(
        nonTransfers.length - forks.where((edge) => edge != null).length,
        24,
      );
      for (final edge in nonTransfers) {
        expect(edge.cost, 25);
        expect(edge.stations, 1);
      }
      for (final edge in transfers) {
        expect(edge.cost, 75);
        expect(edge.stations, 0);
      }
    });

    test('adds fork edges in both directions', () {
      final k = _node('k', 3);
      for (final target in [_node('p1', 3), _node('q1', 3)]) {
        for (final edge in [_edge(graph, k, target), _edge(graph, target, k)]) {
          expect(edge, isNotNull);
          expect(edge!.cost, 25);
          expect(edge.stations, 1);
          expect(edge.isTransfer, isFalse);
        }
      }
    });

    test('adds transfer edges only at x and s4', () {
      final transferNodes = graph.adjacency.entries
          .where((entry) => entry.value.any((edge) => edge.isTransfer))
          .map((entry) => entry.key)
          .toSet();

      expect(transferNodes, {
        _node('x', 1),
        _node('x', 2),
        _node('s4', 1),
        _node('s4', 3),
      });
      final xToL2 = _edge(graph, _node('x', 1), _node('x', 2));
      final s4ToL3 = _edge(graph, _node('s4', 1), _node('s4', 3));
      expect(xToL2, isNotNull);
      expect(xToL2!.isTransfer, isTrue);
      expect(s4ToL3, isNotNull);
      expect(s4ToL3!.isTransfer, isTrue);
    });

    test('every edge has an equal reverse edge', () {
      for (final entry in graph.adjacency.entries) {
        for (final edge in entry.value) {
          final reverse = _edge(graph, edge.to, entry.key);
          expect(reverse, isNotNull);
          expect(reverse!.cost, edge.cost);
          expect(reverse.stations, edge.stations);
          expect(reverse.isTransfer, edge.isTransfer);
        }
      }
    });

    test('rejects a fork whose starts_after station is not on the line', () {
      final invalid = _networkWithBranch(
        const LineBranch(lineId: 3, branch: 'bad', startsAfter: 's1'),
      );

      expect(
        () => RoutingGraph.fromNetwork(invalid, const RoutingConfig()),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('s1'),
          ),
        ),
      );
    });

    test('rejects a fork with no seq 1 station', () {
      final invalid = _networkWithBranch(
        const LineBranch(lineId: 3, branch: 'bad', startsAfter: 'k'),
      );

      expect(
        () => RoutingGraph.fromNetwork(invalid, const RoutingConfig()),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('seq 1'),
          ),
        ),
      );
    });
  });

  group('RoutingGraph lookups', () {
    test('branchOf returns the branch of each node', () {
      expect(graph.branchOf(_node('k', 3)), 'main');
      expect(graph.branchOf(_node('p1', 3)), 'br_a');
      expect(graph.branchOf(_node('q1', 3)), 'br_b');
      expect(graph.branchOf(_node('x', 1)), 'main');
      expect(() => graph.branchOf(_node('iso', 1)), throwsStateError);
    });

    test('nodesOfStation returns the nodes in line order', () {
      expect(graph.nodesOfStation('x'), [_node('x', 1), _node('x', 2)]);
      expect(graph.nodesOfStation('s4'), [_node('s4', 1), _node('s4', 3)]);
      expect(graph.nodesOfStation('iso'), isEmpty);
    });
  });
}
