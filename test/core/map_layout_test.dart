import 'package:flutter_test/flutter_test.dart';
import 'package:maak_metro/core/map/metro_map_layout.dart';
import 'package:maak_metro/data/in_memory_metro_repository.dart';
import 'package:maak_metro/domain/models/metro_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late NetworkData network;
  late MetroMapLayout layout;
  setUpAll(() async {
    network = await InMemoryMetroRepository().loadNetwork();
    layout = MetroMapLayout.of(network);
  });

  test('every station of the network has a place on the map', () {
    expect(layout.points.length, network.stations.length);
    for (final station in network.stations) {
      expect(layout.points[station.id], isNotNull, reason: station.id);
    }
  });

  test('one path per line and branch, in travel order', () {
    expect(layout.paths.length, 5);
    expect(layout.paths.every((path) => path.ids.length >= 2), isTrue);
    // A branch begins at the station it forks from.
    final fork = network.branches.firstWhere(
      (row) => row.lineId == 3 && row.branch == 'cairo_uni',
    );
    final track = layout.paths.firstWhere(
      (path) =>
          path.lineId == 3 &&
          path.ids.contains(fork.startsAfter) &&
          path.ids.contains('uni'),
    );
    expect(track.ids.first, fork.startsAfter);
  });

  test('the drawing stays inside the canvas', () {
    for (final point in layout.points.values) {
      expect(point.dx, inInclusiveRange(0, mapWidth));
      expect(point.dy, inInclusiveRange(0, mapHeight));
    }
  });

  test('no two consecutive stations sit on the same spot', () {
    for (final path in layout.paths) {
      for (var index = 1; index < path.ids.length; index++) {
        expect(
          layout.points[path.ids[index]],
          isNot(layout.points[path.ids[index - 1]]),
          reason: '${path.ids[index]} overlaps ${path.ids[index - 1]}',
        );
      }
    }
  });

  test('the fork leaves Kit Kat, and interchanges are shared points', () {
    final branches = network.branchesOf(3);
    for (final branch in branches) {
      final trunk = network.stationsOf(3, 'main').map((s) => s.id).toList();
      final startsAfter = network.branches
          .firstWhere((row) => row.lineId == 3 && row.branch == branch)
          .startsAfter;
      expect(trunk, contains(startsAfter));
    }
    for (final id in ['sadat', 'shohadaa', 'attaba', 'nasser', 'uni']) {
      expect(network.linesServing(id).length, 2, reason: id);
      expect(layout.points[id], isNotNull, reason: id);
    }
  });
}
