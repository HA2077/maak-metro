import 'package:flutter_test/flutter_test.dart';

import 'package:maak_metro/features/planner/domain/dijkstra.dart';
import 'package:maak_metro/features/planner/domain/leg_builder.dart';
import 'package:maak_metro/features/planner/domain/models/models.dart';
import 'package:maak_metro/features/planner/domain/routing_graph.dart';

import '../../../fixtures/fixture_network.dart';

List<List<Object>> _shape(List<RouteLeg> legs) => [
  for (final leg in legs) [leg.lineId, leg.branch, leg.stationIds],
];

void main() {
  final graph = RoutingGraph.fromNetwork(
    buildFixtureNetwork(),
    const RoutingConfig(),
  );

  ({List<RouteLeg> legs, int stations}) route(String from, String to) {
    final result = findCheapestPath(
      graph,
      graph.nodesOfStation(from).toSet(),
      graph.nodesOfStation(to).toSet(),
    );
    expect(result, isNotNull, reason: 'no path from $from to $to');
    return (legs: buildLegs(result!.path, graph), stations: result.stations);
  }

  group('buildLegs', () {
    test('splits t1 to p2 into three legs at both interchanges', () {
      final result = route('t1', 'p2');

      expect(_shape(result.legs), [
        [
          2,
          'main',
          ['t1', 't2', 'x'],
        ],
        [
          1,
          'main',
          ['x', 's4'],
        ],
        [
          3,
          'br_a',
          ['s4', 'k', 'p1', 'p2'],
        ],
      ]);
      expect(result.stations, 6);
      expect(result.legs.length - 1, 2);
    });

    test('splits p2 to q3 at the fork station k', () {
      final result = route('p2', 'q3');

      expect(_shape(result.legs), [
        [
          3,
          'br_a',
          ['p2', 'p1', 'k'],
        ],
        [
          3,
          'br_b',
          ['k', 'q1', 'q2', 'q3'],
        ],
      ]);
      expect(result.stations, 5);
      expect(result.legs.length - 1, 1);
    });

    test('keeps m1 to p1 as one leg entering br_a', () {
      final result = route('m1', 'p1');

      expect(_shape(result.legs), [
        [
          3,
          'br_a',
          ['m1', 's4', 'k', 'p1'],
        ],
      ]);
      expect(result.stations, 3);
      expect(result.legs.length - 1, 0);
    });

    test('keeps a single-line route in one main leg', () {
      final result = route('s1', 's5');

      expect(_shape(result.legs), [
        [
          1,
          'main',
          ['s1', 's2', 'x', 's4', 's5'],
        ],
      ]);
    });

    test('shares the transfer station between adjacent legs', () {
      final result = route('s1', 't4');

      expect(_shape(result.legs), [
        [
          1,
          'main',
          ['s1', 's2', 'x'],
        ],
        [
          2,
          'main',
          ['x', 't4'],
        ],
      ]);
      expect(
        result.legs.first.stationIds.last,
        result.legs.last.stationIds.first,
      );
    });

    test('returns no legs for an empty path', () {
      expect(buildLegs(const <NodeKey>[], graph), isEmpty);
    });

    test('throws when a branch change has no fork station', () {
      expect(
        () => buildLegs([
          const NodeKey(stationId: 'p1', lineId: 3),
          const NodeKey(stationId: 'q1', lineId: 3),
        ], graph),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('no fork station'),
          ),
        ),
      );
    });
  });
}
