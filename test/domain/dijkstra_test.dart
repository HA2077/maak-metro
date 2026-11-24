import 'package:flutter_test/flutter_test.dart';
import 'package:maak_metro/domain/dijkstra.dart';
import 'package:maak_metro/domain/models/models.dart';
import 'package:maak_metro/domain/routing_graph.dart';

import '../fixtures/fixture_network.dart';

NodeKey _n(String stationId, int lineId) =>
    NodeKey(stationId: stationId, lineId: lineId);

Line _line(int id) =>
    Line(id: id, nameAr: 'Line $id', nameEn: 'Line $id', colorHex: '#000000');

Station _station(String id) => Station(id: id, nameAr: id, nameEn: id);

NetworkData _tieNetwork() => NetworkData(
  lines: [_line(1), _line(2), _line(3)],
  stations: [
    for (final id in ['a', 'b', 'c', 'd', 'e', 'z']) _station(id),
  ],
  branches: const [],
  lineStations: const [
    LineStation(lineId: 1, stationId: 'a', branch: 'main', seq: 1),
    LineStation(lineId: 1, stationId: 'b', branch: 'main', seq: 2),
    LineStation(lineId: 1, stationId: 'c', branch: 'main', seq: 3),
    LineStation(lineId: 1, stationId: 'd', branch: 'main', seq: 4),
    LineStation(lineId: 1, stationId: 'e', branch: 'main', seq: 5),
    LineStation(lineId: 2, stationId: 'a', branch: 'main', seq: 1),
    LineStation(lineId: 2, stationId: 'e', branch: 'main', seq: 2),
    LineStation(lineId: 3, stationId: 'z', branch: 'main', seq: 1),
  ],
  fares: const [],
  snapshotDate: 'test',
);

class _Case {
  const _Case(
    this.from,
    this.to,
    this.path,
    this.cost,
    this.transfers,
    this.stations,
  );

  final String from;
  final String to;
  final List<NodeKey> path;
  final int cost;
  final int transfers;
  final int stations;
}

void main() {
  final graph = RoutingGraph.fromNetwork(
    buildFixtureNetwork(),
    const RoutingConfig(),
  );

  final cases = [
    _Case(
      's1',
      's5',
      [_n('s1', 1), _n('s2', 1), _n('x', 1), _n('s4', 1), _n('s5', 1)],
      100,
      0,
      4,
    ),
    _Case(
      's5',
      's1',
      [_n('s5', 1), _n('s4', 1), _n('x', 1), _n('s2', 1), _n('s1', 1)],
      100,
      0,
      4,
    ),
    _Case(
      's1',
      't4',
      [_n('s1', 1), _n('s2', 1), _n('x', 1), _n('x', 2), _n('t4', 2)],
      150,
      1,
      3,
    ),
    _Case(
      't1',
      'p2',
      [
        _n('t1', 2),
        _n('t2', 2),
        _n('x', 2),
        _n('x', 1),
        _n('s4', 1),
        _n('s4', 3),
        _n('k', 3),
        _n('p1', 3),
        _n('p2', 3),
      ],
      300,
      2,
      6,
    ),
    _Case(
      'p2',
      'q3',
      [
        _n('p2', 3),
        _n('p1', 3),
        _n('k', 3),
        _n('q1', 3),
        _n('q2', 3),
        _n('q3', 3),
      ],
      125,
      0,
      5,
    ),
    _Case(
      'm1',
      'p1',
      [_n('m1', 3), _n('s4', 3), _n('k', 3), _n('p1', 3)],
      75,
      0,
      3,
    ),
  ];

  group('findCheapestPath', () {
    for (final route in cases) {
      test('matches expected_routes.md for ${route.from} to ${route.to}', () {
        final result = findCheapestPath(
          graph,
          graph.nodesOfStation(route.from).toSet(),
          graph.nodesOfStation(route.to).toSet(),
        );

        expect(result, isNotNull);
        expect(result!.path, route.path);
        expect(result.cost, route.cost);
        expect(result.transfers, route.transfers);
        expect(result.stations, route.stations);
      });
    }

    test('prefers fewer transfers when two paths cost the same', () {
      final tieGraph = RoutingGraph.fromNetwork(
        _tieNetwork(),
        const RoutingConfig(),
      );

      final result = findCheapestPath(
        tieGraph,
        {_n('a', 1)},
        {_n('e', 1), _n('e', 2)},
      );

      expect(result, isNotNull);
      expect(result!.path, [
        _n('a', 1),
        _n('b', 1),
        _n('c', 1),
        _n('d', 1),
        _n('e', 1),
      ]);
      expect(result.cost, 100);
      expect(result.transfers, 0);
      expect(result.stations, 4);
    });

    test('returns a zero-cost single-node path when start is the goal', () {
      final result = findCheapestPath(graph, {_n('s4', 1)}, {_n('s4', 1)});

      expect(result, isNotNull);
      expect(result!.path, [_n('s4', 1)]);
      expect(result.cost, 0);
      expect(result.transfers, 0);
      expect(result.stations, 0);
    });

    test('returns null for empty start or goal sets', () {
      expect(findCheapestPath(graph, const <NodeKey>{}, {_n('s1', 1)}), isNull);
      expect(findCheapestPath(graph, {_n('s1', 1)}, const <NodeKey>{}), isNull);
    });

    test('returns null when the goal is unreachable or unknown', () {
      final tieGraph = RoutingGraph.fromNetwork(
        _tieNetwork(),
        const RoutingConfig(),
      );

      expect(findCheapestPath(tieGraph, {_n('a', 1)}, {_n('z', 3)}), isNull);
      expect(findCheapestPath(graph, {_n('s1', 1)}, {_n('iso', 1)}), isNull);
    });
  });
}
