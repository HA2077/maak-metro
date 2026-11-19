import 'package:flutter_test/flutter_test.dart';
import 'package:maak_metro/data/in_memory_metro_repository.dart';
import 'package:maak_metro/domain/models/metro_models.dart';

/// Guards the seed against silent damage: the counts and the interchanges are
/// the ones the network actually has (Cairo Metro lines 1-3, read 2026-11-19).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late NetworkData network;
  setUpAll(() async {
    network = await InMemoryMetroRepository().loadNetwork();
  });

  test('three lines, two forks, 84 stations', () {
    expect(network.lines.length, 3);
    expect(network.stations.length, 84);
    expect(
      network.branchesOf(3),
      containsAll(<String>['rod_el_farag_axis', 'cairo_uni']),
    );
    expect(network.branchesOf(1), isEmpty);
  });

  test('each line carries its real station count', () {
    expect(network.lineStationsOf(1).length, 35);
    expect(network.lineStationsOf(2).length, 20);
    expect(network.lineStationsOf(3).length, 34);
    expect(network.stationsOf(3, 'main').length, 23);
    expect(network.stationsOf(3, 'rod_el_farag_axis').length, 6);
    expect(network.stationsOf(3, 'cairo_uni').length, 5);
  });

  test('the interchanges are the real ones', () {
    expect(network.linesServing('shohadaa').length, 2);
    expect(network.linesServing('sadat').length, 2);
    expect(network.linesServing('attaba').length, 2);
    expect(network.linesServing('nasser').length, 2);
    expect(network.linesServing('uni').length, 2);
    expect(network.linesServing('marg').length, 1);
  });

  test('sequences are contiguous and unique per branch', () {
    for (final line in network.lines) {
      for (final branch in ['main', ...network.branchesOf(line.id)]) {
        final rows =
            network
                .lineStationsOf(line.id)
                .where((row) => row.branch == branch)
                .toList()
              ..sort((a, b) => a.seq.compareTo(b.seq));
        expect(
          rows.map((row) => row.seq),
          List<int>.generate(rows.length, (index) => index + 1),
          reason: 'line ${line.id} branch $branch',
        );
      }
    }
  });

  test('every row and fork points at something that exists', () {
    for (final row in network.lineStations) {
      expect(network.lineById(row.lineId), isNotNull);
      expect(network.stationById(row.stationId), isNotNull);
    }
    for (final branch in network.branches) {
      final trunk = network.stationsOf(branch.lineId, 'main');
      expect(
        trunk.map((station) => station.id),
        contains(branch.startsAfter),
        reason: '${branch.branch} forks off the trunk',
      );
    }
  });

  test('the fare table climbs with distance', () {
    final fares = network.fares;
    expect(fares, isNotEmpty);
    expect(fares.first.priceEgp, 8);
    expect(fares.last.priceEgp, 20);
    for (var index = 1; index < fares.length; index++) {
      expect(
        fares[index].maxStations,
        greaterThan(fares[index - 1].maxStations),
      );
      expect(
        fares[index].priceEgp,
        greaterThanOrEqualTo(fares[index - 1].priceEgp),
      );
    }
  });
}
