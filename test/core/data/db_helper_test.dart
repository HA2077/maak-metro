import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:maak_metro/core/data/db_helper.dart';

/// Repository tests run on an in-memory database through `sqflite_common_ffi`,
/// so they need no device.
void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late DbHelper helper;

  setUp(() {
    helper = DbHelper(path: inMemoryDatabasePath);
  });

  tearDown(() async {
    await helper.close();
  });

  group('DbHelper', () {
    test('creates the seven tables from PLAN.md section 2', () async {
      final db = await helper.database;

      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master "
        "WHERE type = 'table' AND name NOT LIKE 'sqlite_%' ORDER BY name",
      );
      final names = [for (final row in tables) row['name'] as String];

      expect(names, <String>[
        'fares',
        'favorites',
        'history',
        'line_branches',
        'line_stations',
        'lines',
        'stations',
      ]);
    });

    test('enables foreign keys on the connection', () async {
      final db = await helper.database;

      final rows = await db.rawQuery('PRAGMA foreign_keys');

      expect(rows.single.values.single, 1);
    });

    test('rejects a line_stations row with an unknown station', () async {
      final db = await helper.database;

      await expectLater(
        db.insert('line_stations', <String, Object?>{
          'line_id': 1,
          'station_id': 'unknown_station',
          'branch': 'main',
          'seq': 1,
        }),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('upgrades a version 1 database and keeps user tables', () async {
      final path =
          '${Directory.systemTemp.path}/maak_upgrade_${DateTime.now().microsecondsSinceEpoch}.db';
      final old = await openDatabase(
        path,
        version: 1,
        onCreate: (db, _) async {
          await db.execute(
            'CREATE TABLE lines (id INTEGER PRIMARY KEY, name_ar TEXT NOT NULL, name_en TEXT NOT NULL, color_hex TEXT NOT NULL)',
          );
          await db.execute(
            'CREATE TABLE stations (id TEXT PRIMARY KEY, name_ar TEXT NOT NULL, name_en TEXT NOT NULL)',
          );
          await db.execute(
            'CREATE TABLE line_branches (line_id INTEGER NOT NULL REFERENCES lines(id), branch TEXT NOT NULL, starts_after TEXT NOT NULL REFERENCES stations(id), PRIMARY KEY (line_id, branch))',
          );
          await db.execute(
            'CREATE TABLE line_stations (line_id INTEGER NOT NULL REFERENCES lines(id), station_id TEXT NOT NULL REFERENCES stations(id), branch TEXT NOT NULL, seq INTEGER NOT NULL, PRIMARY KEY (line_id, branch, seq), UNIQUE (line_id, station_id))',
          );
          await db.execute(
            'CREATE TABLE fares (max_stations INTEGER PRIMARY KEY, price_egp INTEGER NOT NULL)',
          );
          await db.execute(
            'CREATE TABLE favorites (id INTEGER PRIMARY KEY AUTOINCREMENT, from_id TEXT NOT NULL REFERENCES stations(id), to_id TEXT NOT NULL REFERENCES stations(id), created_at TEXT NOT NULL, UNIQUE (from_id, to_id))',
          );
          await db.execute(
            'CREATE TABLE history (id INTEGER PRIMARY KEY AUTOINCREMENT, from_id TEXT NOT NULL REFERENCES stations(id), to_id TEXT NOT NULL REFERENCES stations(id), searched_at TEXT NOT NULL)',
          );
        },
      );
      await old.insert('stations', {
        'id': 's1',
        'name_ar': 'واحدة',
        'name_en': 'One',
      });
      await old.insert('stations', {
        'id': 's2',
        'name_ar': 'اثنتان',
        'name_en': 'Two',
      });
      await old.insert('favorites', {
        'from_id': 's1',
        'to_id': 's2',
        'created_at': '2026-01-01',
      });
      await old.close();

      final upgraded = DbHelper(path: path);
      final db = await upgraded.database;
      final lineColumns = await db.rawQuery('PRAGMA table_info(lines)');
      final fareColumns = await db.rawQuery('PRAGMA table_info(fares)');
      expect(
        lineColumns.map((row) => row['name']),
        containsAll(<String>['terminus_a_en', 'terminus_b_ar']),
      );
      expect(fareColumns.map((row) => row['name']), contains('ticket_color'));
      expect(await db.query('favorites'), hasLength(1));

      await upgraded.close();
      final file = File(path);
      if (await file.exists()) await file.delete();
    });

    test('opens once and can be closed and used again', () async {
      final first = await helper.database;
      final second = await helper.database;

      expect(identical(first, second), isTrue);

      await helper.close();

      final reopened = await helper.database;
      expect(identical(first, reopened), isFalse);
      expect(await reopened.rawQuery('PRAGMA foreign_keys'), isNotEmpty);
    });
  });
}
