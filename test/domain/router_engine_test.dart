import 'package:flutter_test/flutter_test.dart';
import 'package:maak_metro/domain/domain.dart';

import '../fixtures/fixture_network.dart';

const _defaultConfig = RoutingConfig();

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

List<Object> _leg(int lineId, String branch, List<String> stationIds) => [
  lineId,
  branch,
  stationIds,
];

List<List<Object>> _shape(List<RouteLeg> legs) => [
  for (final leg in legs) _leg(leg.lineId, leg.branch, leg.stationIds),
];

void main() {
  final data = buildFixtureNetwork();

  RouteResult? route(
    String from,
    String to, {
    RoutingConfig config = _defaultConfig,
  }) => findRoute(fromId: from, toId: to, data: data, config: config);

  final expected = [
    _Expected(
      's1',
      's5',
      [
        _leg(1, 'main', ['s1', 's2', 'x', 's4', 's5']),
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
        _leg(1, 'main', ['s5', 's4', 'x', 's2', 's1']),
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
        _leg(1, 'main', ['s1', 's2', 'x']),
        _leg(2, 'main', ['x', 't4']),
      ],
      3,
      1,
      15.0,
      10,
    ),
    _Expected(
      't4',
      's1',
      [
        _leg(2, 'main', ['t4', 'x']),
        _leg(1, 'main', ['x', 's2', 's1']),
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
        _leg(2, 'main', ['t1', 't2', 'x']),
        _leg(1, 'main', ['x', 's4']),
        _leg(3, 'br_a', ['s4', 'k', 'p1', 'p2']),
      ],
      6,
      2,
      30.0,
      10,
    ),
    _Expected(
      'p2',
      't1',
      [
        _leg(3, 'br_a', ['p2', 'p1', 'k', 's4']),
        _leg(1, 'main', ['s4', 'x']),
        _leg(2, 'main', ['x', 't2', 't1']),
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
        _leg(3, 'br_a', ['p2', 'p1', 'k']),
        _leg(3, 'br_b', ['k', 'q1', 'q2', 'q3']),
      ],
      5,
      1,
      20.0,
      10,
    ),
    _Expected(
      'q3',
      'p2',
      [
        _leg(3, 'br_b', ['q3', 'q2', 'q1', 'k']),
        _leg(3, 'br_a', ['k', 'p1', 'p2']),
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
        _leg(3, 'br_a', ['m1', 's4', 'k', 'p1']),
      ],
      3,
      0,
      7.5,
      10,
    ),
    _Expected(
      'p1',
      'm1',
      [
        _leg(3, 'br_a', ['p1', 'k', 's4', 'm1']),
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

    test('an interchange can be the start without a transfer penalty', () {
      final result = route('x', 't4');

      expect(result, isNotNull);
      expect(_shape(result!.legs), [
        _leg(2, 'main', ['x', 't4']),
      ]);
      expect(result.stationCount, 1);
      expect(result.transfers, 0);
      expect(result.estimatedMinutes, 2.5);
      expect(result.fareEgp, 10);
    });

    test(
      'an interchange can be the destination without a transfer penalty',
      () {
        final result = route('s1', 'x');

        expect(result, isNotNull);
        expect(_shape(result!.legs), [
          _leg(1, 'main', ['s1', 's2', 'x']),
        ]);
        expect(result.stationCount, 2);
        expect(result.transfers, 0);
        expect(result.estimatedMinutes, 5.0);
        expect(result.fareEgp, 10);
      },
    );

    test('a route across all three lines has two transfers', () {
      final result = route('t1', 'p2');

      expect(result, isNotNull);
      expect(result!.legs.map((leg) => leg.lineId), [2, 1, 3]);
      expect(result.transfers, 2);
    });

    test('zero transfer penalty leaves only the per-stop time', () {
      const freeTransfers = RoutingConfig(transferPenaltyMinutes: 0);
      final withConnections = route('t1', 'p2', config: freeTransfers);
      final withBranchSplit = route('p2', 'q3', config: freeTransfers);

      expect(withConnections, isNotNull);
      expect(
        withConnections!.estimatedMinutes,
        withConnections.stationCount * freeTransfers.perStopMinutes,
      );
      expect(withConnections.estimatedMinutes, 15.0);
      expect(withBranchSplit, isNotNull);
      expect(
        withBranchSplit!.estimatedMinutes,
        withBranchSplit.stationCount * freeTransfers.perStopMinutes,
      );
      expect(withBranchSplit.estimatedMinutes, 12.5);
    });

    test('returns null for same, unknown and line-less stations', () {
      expect(route('s1', 's1'), isNull);
      expect(route('s1', 'zzz'), isNull);
      expect(route('zzz', 's1'), isNull);
      expect(route('s1', 'iso'), isNull);
      expect(route('iso', 's1'), isNull);
    });

    test('is symmetric for every pair of fixture stations', () {
      final stationIds = data.stations.map((station) => station.id).toList();
      var pairs = 0;

      for (var i = 0; i < stationIds.length; i++) {
        for (var j = i + 1; j < stationIds.length; j++) {
          final from = stationIds[i];
          final to = stationIds[j];
          final forward = route(from, to);
          final backward = route(to, from);

          if (from == 'iso' || to == 'iso') {
            expect(forward, isNull, reason: '$from -> $to');
            expect(backward, isNull, reason: '$to -> $from');
          } else {
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
          }
          pairs++;
        }
      }

      expect(pairs, 120);
    });
  });
}
