import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:maak_metro/core/data/db_helper.dart';
import 'package:maak_metro/features/network/data/seed_loader.dart';

/// Serves a seed JSON string as the bundled asset.
class _StringBundle extends AssetBundle {
  _StringBundle(this.content);

  final String content;

  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(Uint8List.fromList(utf8.encode(content)));
}

/// Builds a minimal seed with one line and the given stations.
String _seed({
  required int version,
  required List<String> stationIds,
  String snapshotDate = '2026-11-18',
}) {
  return jsonEncode(<String, Object?>{
    'version': version,
    'snapshot_date': snapshotDate,
    'lines': <Object?>[
      <String, Object?>{
        'id': 1,
        'name_ar': 'الخط الأول',
        'name_en': 'Line 1',
        'color_hex': '#1E63B8',
      },
    ],
    'stations': <Object?>[
      for (final id in stationIds)
        <String, Object?>{
          'id': id,
          'name_ar': 'اسم $id',
          'name_en': 'Name $id',
        },
    ],
    'line_branches': <Object?>[],
    'line_stations': <Object?>[
      for (var i = 0; i < stationIds.length; i++)
        <String, Object?>{
          'line_id': 1,
          'station_id': stationIds[i],
          'branch': 'main',
          'seq': i + 1,
        },
    ],
    'fares': <Object?>[
      <String, Object?>{'max_stations': 9, 'price_egp': 10},
    ],
  });
}

Future<int> _count(Database db, String table) async {
  final rows = await db.rawQuery('SELECT COUNT(*) AS total FROM $table');
  return rows.single['total'] as int;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late DbHelper helper;
  late Database db;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    prefs = await SharedPreferences.getInstance();
    helper = DbHelper(path: inMemoryDatabasePath);
    db = await helper.database;
  });

  tearDown(() async {
    await helper.close();
  });

  Future<void> seed(String json) =>
      SeedLoader(db, prefs, bundle: _StringBundle(json)).seedIfNeeded();

  test(
    'first run inserts every row and stores version and snapshot date',
    () async {
      await seed(_seed(version: 1, stationIds: ['a', 'b']));

      expect(await _count(db, 'lines'), 1);
      expect(await _count(db, 'stations'), 2);
      expect(await _count(db, 'line_stations'), 2);
      expect(await _count(db, 'fares'), 1);
      expect(prefs.getInt(seedVersionKey), 1);
      expect(prefs.getString(seedSnapshotDateKey), '2026-11-18');
    },
  );

  test('a second run with the same version does nothing', () async {
    final json = _seed(version: 1, stationIds: ['a', 'b']);
    await seed(json);
    await db.insert('fares', <String, Object?>{
      'max_stations': 99,
      'price_egp': 99,
    });

    await seed(json);

    expect(await _count(db, 'fares'), 2);
    expect(prefs.getInt(seedVersionKey), 1);
  });

  test('a higher version replaces data and keeps valid user rows', () async {
    await seed(_seed(version: 1, stationIds: ['a', 'b']));
    await db.insert('favorites', <String, Object?>{
      'from_id': 'a',
      'to_id': 'b',
      'created_at': '2026-11-18T00:00:00.000Z',
    });
    await db.insert('history', <String, Object?>{
      'from_id': 'a',
      'to_id': 'b',
      'searched_at': '2026-11-18T00:00:00.000Z',
    });

    // 'b' disappears and 'c' appears, so the saved pair becomes orphaned.
    await seed(
      _seed(version: 2, stationIds: ['a', 'c'], snapshotDate: '2026-11-20'),
    );

    expect(await _count(db, 'stations'), 2);
    expect(await _count(db, 'favorites'), 0);
    expect(await _count(db, 'history'), 0);
    expect(prefs.getInt(seedVersionKey), 2);
    expect(prefs.getString(seedSnapshotDateKey), '2026-11-20');
  });

  test('a higher version keeps rows whose stations still exist', () async {
    await seed(_seed(version: 1, stationIds: ['a', 'b']));
    await db.insert('favorites', <String, Object?>{
      'from_id': 'a',
      'to_id': 'b',
      'created_at': '2026-11-18T00:00:00.000Z',
    });
    await db.insert('history', <String, Object?>{
      'from_id': 'b',
      'to_id': 'a',
      'searched_at': '2026-11-18T00:00:00.000Z',
    });

    await seed(_seed(version: 2, stationIds: ['a', 'b', 'c']));

    expect(await _count(db, 'favorites'), 1);
    expect(await _count(db, 'history'), 1);
  });

  test('malformed JSON leaves the previous data intact', () async {
    await seed(_seed(version: 1, stationIds: ['a', 'b']));

    await expectLater(seed('{not json'), throwsA(isA<FormatException>()));

    expect(await _count(db, 'stations'), 2);
    expect(await _count(db, 'fares'), 1);
    expect(prefs.getInt(seedVersionKey), 1);
  });

  test('a version 0 stub is a no-op and does not crash', () async {
    await seed(_seed(version: 0, stationIds: <String>[]));

    expect(await _count(db, 'lines'), 0);
    expect(prefs.getInt(seedVersionKey), isNull);
  });
}
