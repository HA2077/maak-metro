import 'package:maak_metro/domain/metro_repository.dart';
import 'package:maak_metro/domain/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'db_helper.dart';
import 'seed_loader.dart';

/// [MetroRepository] backed by the SQLite database filled from the seed asset.
class SqliteMetroRepository implements MetroRepository {
  SqliteMetroRepository._(this._db, this._prefs);

  final Database _db;
  final SharedPreferences _prefs;

  /// Opens the database, seeds it when needed and returns the repository.
  static Future<SqliteMetroRepository> create({
    DbHelper? helper,
    SharedPreferences? prefs,
  }) async {
    final dbHelper = helper ?? DbHelper();
    final preferences = prefs ?? await SharedPreferences.getInstance();
    final db = await dbHelper.database;
    await SeedLoader(db, preferences).seedIfNeeded();
    return SqliteMetroRepository._(db, preferences);
  }

  @override
  Future<NetworkData> loadNetwork() async {
    final lineRows = await _db.query('lines', orderBy: 'id');
    final stationRows = await _db.query('stations', orderBy: 'id');
    final branchRows = await _db.query(
      'line_branches',
      orderBy: 'line_id, branch',
    );
    final lineStationRows = await _db.query(
      'line_stations',
      orderBy: 'line_id, branch, seq',
    );
    final fareRows = await _db.query('fares', orderBy: 'max_stations');

    return NetworkData(
      lines: lineRows.map(Line.fromJson).toList(),
      stations: stationRows.map(Station.fromJson).toList(),
      branches: branchRows.map(LineBranch.fromJson).toList(),
      lineStations: lineStationRows.map(LineStation.fromJson).toList(),
      fares: fareRows.map(FareBracket.fromJson).toList(),
      snapshotDate: _prefs.getString(seedSnapshotDateKey) ?? '',
    );
  }

  @override
  Future<List<FavoriteRoute>> getFavorites() async {
    final rows = await _db.query(
      'favorites',
      orderBy: 'created_at DESC, id DESC',
    );
    return [for (final row in rows) _favoriteFromRow(row)];
  }

  @override
  Future<bool> isFavorite(String fromId, String toId) async {
    final rows = await _db.query(
      'favorites',
      columns: const ['id'],
      where: 'from_id = ? AND to_id = ?',
      whereArgs: [fromId, toId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  @override
  Future<void> addFavorite(String fromId, String toId) async {
    await _db.insert('favorites', <String, Object?>{
      'from_id': fromId,
      'to_id': toId,
      'created_at': _nowUtc(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  @override
  Future<void> removeFavorite(int id) async {
    await _db.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> removeFavoriteByPair(String fromId, String toId) async {
    await _db.delete(
      'favorites',
      where: 'from_id = ? AND to_id = ?',
      whereArgs: [fromId, toId],
    );
  }

  @override
  Future<List<HistoryEntry>> getHistory({int limit = 50}) async {
    final rows = await _db.query('history', orderBy: 'id DESC', limit: limit);
    return [for (final row in rows) _historyFromRow(row)];
  }

  @override
  Future<void> addHistory(String fromId, String toId) async {
    await _db.insert('history', <String, Object?>{
      'from_id': fromId,
      'to_id': toId,
      'searched_at': _nowUtc(),
    });
    await _db.delete(
      'history',
      where: 'id NOT IN (SELECT id FROM history ORDER BY id DESC LIMIT 50)',
    );
  }

  @override
  Future<void> removeHistory(int id) async {
    await _db.delete('history', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> clearHistory() async {
    await _db.delete('history');
  }

  static String _nowUtc() => DateTime.now().toUtc().toIso8601String();

  static FavoriteRoute _favoriteFromRow(Map<String, Object?> row) =>
      FavoriteRoute(
        id: row['id'] as int,
        fromId: row['from_id'] as String,
        toId: row['to_id'] as String,
        createdAt: DateTime.parse(row['created_at'] as String),
      );

  static HistoryEntry _historyFromRow(Map<String, Object?> row) => HistoryEntry(
    id: row['id'] as int,
    fromId: row['from_id'] as String,
    toId: row['to_id'] as String,
    searchedAt: DateTime.parse(row['searched_at'] as String),
  );
}
