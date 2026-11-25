import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

/// Asset that holds the single source of truth for metro data.
const String seedAssetPath = 'assets/metro_seed.json';

/// SharedPreferences key holding the version of the seeded data.
const String seedVersionKey = 'seed_version';

/// SharedPreferences key holding the snapshot date of the seeded data.
const String seedSnapshotDateKey = 'seed_snapshot_date';

/// Reference tables, deleted in this order and inserted in reverse.
const List<String> _referenceTables = <String>[
  'line_stations',
  'line_branches',
  'fares',
  'stations',
  'lines',
];

/// Loads `assets/metro_seed.json` into SQLite when its version is newer than
/// the one already stored in [SharedPreferences].
class SeedLoader {
  SeedLoader(this._db, this._prefs, {AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  final Database _db;
  final SharedPreferences _prefs;
  final AssetBundle _bundle;

  /// Seeds the database if the asset version is greater than the stored one.
  ///
  /// A version of 0 (the stub seed) means "nothing to seed" and is a no-op.
  /// Any failure rolls the whole transaction back and is rethrown.
  Future<void> seedIfNeeded() async {
    final decoded = jsonDecode(await _bundle.loadString(seedAssetPath));
    final seed = decoded as Map<String, Object?>;
    final version = seed['version'] as int? ?? 0;
    if (version <= (_prefs.getInt(seedVersionKey) ?? 0)) return;

    final snapshotDate = seed['snapshot_date'] as String? ?? '';
    final lines = _rows(seed['lines']);
    final stations = _rows(seed['stations']);
    final branches = _rows(seed['line_branches']);
    final lineStations = _rows(seed['line_stations']);
    final fares = _rows(seed['fares']);
    final stationIds = <String>{
      for (final station in stations) station['id'] as String,
    };

    await _db.transaction((txn) async {
      // Reference tables are rebuilt while favorites and history may still
      // point at them, so the foreign key checks are deferred to commit.
      await txn.execute('PRAGMA defer_foreign_keys = ON');
      await _deleteOrphanedUserData(txn, stationIds);
      for (final table in _referenceTables) {
        await txn.delete(table);
      }

      final batch = txn.batch();
      _insertAll(batch, 'lines', lines);
      _insertAll(batch, 'stations', stations);
      _insertAll(batch, 'line_branches', branches);
      _insertAll(batch, 'line_stations', lineStations);
      _insertAll(batch, 'fares', fares);
      await batch.commit(noResult: true);
    });

    await _prefs.setInt(seedVersionKey, version);
    await _prefs.setString(seedSnapshotDateKey, snapshotDate);
  }

  /// Removes favorites and history rows that point at stations which no
  /// longer exist in the new seed. Other rows are left untouched.
  Future<void> _deleteOrphanedUserData(
    DatabaseExecutor txn,
    Set<String> stationIds,
  ) async {
    if (stationIds.isEmpty) {
      await txn.delete('favorites');
      await txn.delete('history');
      return;
    }

    final ids = stationIds.toList(growable: false);
    final placeholders = List.filled(ids.length, '?').join(', ');
    final where =
        'from_id NOT IN ($placeholders) OR to_id NOT IN ($placeholders)';
    final whereArgs = <Object?>[...ids, ...ids];
    await txn.delete('favorites', where: where, whereArgs: whereArgs);
    await txn.delete('history', where: where, whereArgs: whereArgs);
  }

  static void _insertAll(
    Batch batch,
    String table,
    List<Map<String, Object?>> rows,
  ) {
    for (final row in rows) {
      batch.insert(table, row);
    }
  }

  static List<Map<String, Object?>> _rows(Object? value) {
    if (value == null) return const <Map<String, Object?>>[];
    return (value as List<Object?>)
        .map((row) => row as Map<String, Object?>)
        .toList(growable: false);
  }
}
