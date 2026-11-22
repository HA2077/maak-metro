import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:maak_metro/data/db_helper.dart';
import 'package:maak_metro/data/metro_repository.dart';
import 'package:maak_metro/data/seed_loader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Map<String, Object?> _readSeed() =>
    jsonDecode(File('assets/metro_seed.json').readAsStringSync())
        as Map<String, Object?>;

List<Object?> _list(Object? value) => value! as List<Object?>;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late DbHelper helper;
  late SqliteMetroRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    helper = DbHelper(path: inMemoryDatabasePath);
    repository = await SqliteMetroRepository.create(
      helper: helper,
      prefs: prefs,
    );
  });

  tearDown(() async {
    await helper.close();
  });

  group('SqliteMetroRepository.loadNetwork', () {
    test('returns the same data as the seed file', () async {
      final seed = _readSeed();
      final network = await repository.loadNetwork();

      expect(network.lines.length, _list(seed['lines']).length);
      expect(network.stations.length, _list(seed['stations']).length);
      expect(network.branches.length, _list(seed['line_branches']).length);
      expect(network.lineStations.length, _list(seed['line_stations']).length);
      expect(network.fares.length, _list(seed['fares']).length);
      expect(network.snapshotDate, seed['snapshot_date']);

      final firstLine = _list(seed['lines']).first as Map<String, Object?>;
      final line = network.lineById(firstLine['id']! as int);
      expect(line, isNotNull);
      expect(line!.nameAr, firstLine['name_ar']);
      expect(line.nameEn, firstLine['name_en']);
      expect(line.colorHex, firstLine['color_hex']);
    });

    test('orders lines and stations by id', () async {
      final network = await repository.loadNetwork();

      final lineIds = [for (final line in network.lines) line.id];
      expect(lineIds, [...lineIds]..sort());

      final stationIds = [for (final station in network.stations) station.id];
      expect(stationIds, [...stationIds]..sort());
    });

    test('orders line_stations by line_id, branch, seq', () async {
      final network = await repository.loadNetwork();
      final rows = network.lineStations;

      for (var i = 1; i < rows.length; i++) {
        final previous = rows[i - 1];
        final current = rows[i];
        final order = previous.lineId != current.lineId
            ? previous.lineId.compareTo(current.lineId)
            : previous.branch != current.branch
            ? previous.branch.compareTo(current.branch)
            : previous.seq.compareTo(current.seq);
        expect(order, lessThanOrEqualTo(0));
      }
    });

    test('builds lookup data from the models', () async {
      final network = await repository.loadNetwork();

      final sadat = network.stationById('sadat');
      expect(sadat, isNotNull);
      expect(network.linesServing('sadat'), isNotEmpty);

      final line3 = network.stationsOfLine(3);
      expect(line3, isNotEmpty);
      expect(line3.first.branch, 'main');

      expect(network.stationById('not_a_station'), isNull);
      expect(network.lineById(99), isNull);
    });

    test('an already stored seed version leaves the network empty', () async {
      // `inMemoryDatabasePath` is shared within the process, and the outer
      // `setUp` already opened it, so this case needs its own database.
      await helper.close();
      SharedPreferences.setMockInitialValues(<String, Object>{
        seedVersionKey: 999,
      });
      final prefs = await SharedPreferences.getInstance();
      final emptyHelper = DbHelper(path: inMemoryDatabasePath);
      final emptyRepository = await SqliteMetroRepository.create(
        helper: emptyHelper,
        prefs: prefs,
      );

      final network = await emptyRepository.loadNetwork();
      expect(network.lines, isEmpty);
      expect(network.stations, isEmpty);
      expect(network.lineStations, isEmpty);
      expect(network.fares, isEmpty);
      expect(network.snapshotDate, '');

      await emptyHelper.close();
    });
  });
}
