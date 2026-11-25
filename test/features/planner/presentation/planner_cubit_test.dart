import 'package:flutter_test/flutter_test.dart';

import 'package:maak_metro/features/planner/presentation/planner_cubit.dart';

import '../../../fixtures/fixture_network.dart';

void main() {
  final data = buildFixtureNetwork();
  late PlannerCubit planner;

  setUp(() {
    planner = PlannerCubit();
    addTearDown(planner.close);
  });

  test('returns the expected route across all three lines', () {
    planner.setFrom(data.stationById('t1'));
    planner.setTo(data.stationById('p2'));
    expect(planner.state.canSearch, isTrue);

    final result = planner.calculate(data);
    expect(result, isNotNull);
    expect(result!.fromId, 't1');
    expect(result.toId, 'p2');
    expect(result.legs.map((leg) => leg.lineId), [2, 1, 3]);
    expect(result.stationCount, 6);
    expect(result.transfers, 2);
    expect(result.estimatedMinutes, 30.0);
    expect(result.fareEgp, 10);
    expect(planner.state.error, RouteError.none);
  });

  test('rejects a route with identical endpoints', () {
    final station = data.stationById('s1');
    planner.setPair(station, station);

    expect(planner.state.canSearch, isFalse);
    expect(planner.calculate(data), isNull);
    expect(planner.state.error, RouteError.sameStation);
  });

  test('reports no route to an isolated station', () {
    planner.setPair(data.stationById('s1'), data.stationById('iso'));

    expect(planner.calculate(data), isNull);
    expect(planner.state.error, RouteError.noRoute);
  });

  test('reports no route with missing endpoints or network', () {
    planner.setFrom(data.stationById('s1'));
    expect(planner.calculate(data), isNull);
    expect(planner.state.error, RouteError.noRoute);

    planner.setTo(data.stationById('s5'));
    expect(planner.calculate(null), isNull);
    expect(planner.state.error, RouteError.noRoute);
  });

  test('swap reverses endpoints and changes clear the previous error', () {
    planner.setPair(data.stationById('s1'), data.stationById('iso'));
    planner.calculate(data);
    planner.swap();

    expect(planner.state.from?.id, 'iso');
    expect(planner.state.to?.id, 's1');
    expect(planner.state.error, RouteError.none);

    planner.setFrom(data.stationById('s1'));
    planner.calculate(data);
    expect(planner.state.error, RouteError.sameStation);

    planner.setTo(data.stationById('t4'));
    expect(planner.state.error, RouteError.none);
  });
}
