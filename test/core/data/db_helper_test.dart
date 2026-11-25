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
