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
  Future<List<FavoriteRoute>> getFavorites() => throw UnimplementedError();

  @override
  Future<bool> isFavorite(String fromId, String toId) =>
      throw UnimplementedError();

  @override
  Future<void> addFavorite(String fromId, String toId) =>
      throw UnimplementedError();

  @override
  Future<void> removeFavorite(int id) => throw UnimplementedError();

  @override
  Future<void> removeFavoriteByPair(String fromId, String toId) =>
      throw UnimplementedError();

  @override
  Future<List<HistoryEntry>> getHistory({int limit = 50}) =>
      throw UnimplementedError();

  @override
  Future<void> addHistory(String fromId, String toId) =>
      throw UnimplementedError();

  @override
  Future<void> clearHistory() => throw UnimplementedError();
}
