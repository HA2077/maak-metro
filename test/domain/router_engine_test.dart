import 'package:flutter_test/flutter_test.dart';
import 'package:maak_metro/domain/domain.dart';

import '../fixtures/fixture_network.dart';

class _Expected {
  const _Expected(
    this.from,
    this.to,
    this.legs,
    this.stations,
    this.transfers,
    this.minutes,
    this.fare,
  );

  final String from;
  final String to;
  final List<List<Object>> legs;
  final int stations;
  final int transfers;
  final double minutes;
  final int fare;
}

List<List<Object>> _shape(List<RouteLeg> legs) => [
  for (final leg in legs) [leg.lineId, leg.branch, leg.stationIds],
];

void main() {
  final data = buildFixtureNetwork();
  const config = RoutingConfig();

  RouteResult? route(String from, String to) =>
      findRoute(fromId: from, toId: to, data: data, config: config);

  final expected = [
    _Expected(
      's1',
      's5',
      [
        [
          1,
          'main',
          ['s1', 's2', 'x', 's4', 's5'],
        ],
      ],
      4,
      0,
      10.0,
      10,
    ),
    _Expected(
      's5',
      's1',
      [
        [
          1,
          'main',
          ['s5', 's4', 'x', 's2', 's1'],
        ],
      ],
      4,
      0,
      10.0,
      10,
    ),
    _Expected(
      's1',
      't4',
      [
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
      ],
      3,
      1,
      15.0,
      10,
    ),
    _Expected(
      't1',
      'p2',
      [
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
      ],
      6,
      2,
      30.0,
      10,
    ),
    _Expected(
      'p2',
      'q3',
      [
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
      ],
      5,
      1,
      20.0,
      10,
    ),
    _Expected(
      'm1',
      'p1',
      [
        [
          3,
          'br_a',
          ['m1', 's4', 'k', 'p1'],
        ],
      ],
      3,
      0,
      7.5,
      10,
    ),
  ];

  group('findRoute', () {
    for (final expectedRoute in expected) {
      test('matches expected_routes.md for ${expectedRoute.from} to '
          '${expectedRoute.to}', () {
        final result = route(expectedRoute.from, expectedRoute.to);

        expect(result, isNotNull);
        expect(result!.fromId, expectedRoute.from);
        expect(result.toId, expectedRoute.to);
        expect(_shape(result.legs), expectedRoute.legs);
        expect(result.stationCount, expectedRoute.stations);
        expect(result.transfers, expectedRoute.transfers);
        expect(result.estimatedMinutes, expectedRoute.minutes);
        expect(result.fareEgp, expectedRoute.fare);
      });
    }

    test('returns null for same, unknown and line-less stations', () {
      expect(route('s1', 's1'), isNull);
      expect(route('s1', 'zzz'), isNull);
      expect(route('zzz', 's1'), isNull);
      expect(route('s1', 'iso'), isNull);
    });

    test('is symmetric for every reachable fixture pair', () {
      final stationIds = data.lineStations.map((row) => row.stationId).toSet();
      var pairs = 0;

      for (final from in stationIds) {
        for (final to in stationIds) {
          if (from.compareTo(to) >= 0) continue;
          final forward = route(from, to);
          final backward = route(to, from);
          expect(forward, isNotNull, reason: 'no route from $from to $to');
          expect(backward, isNotNull, reason: 'no route from $to to $from');
          expect(
            backward!.estimatedMinutes,
            forward!.estimatedMinutes,
            reason: '$from <-> $to minutes',
          );
          expect(
            backward.stationCount,
            forward.stationCount,
            reason: '$from <-> $to stations',
          );
          expect(
            backward.transfers,
            forward.transfers,
            reason: '$from <-> $to transfers',
          );
          expect(
            backward.fareEgp,
            forward.fareEgp,
            reason: '$from <-> $to fare',
          );
          pairs++;
        }
      }

      expect(pairs, 105);
    });
  });
}
