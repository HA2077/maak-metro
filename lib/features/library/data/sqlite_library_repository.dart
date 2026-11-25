import 'package:sqflite/sqflite.dart';

import 'package:maak_metro/features/library/domain/library_repository.dart';
import 'package:maak_metro/features/library/domain/models/favorite_route.dart';
import 'package:maak_metro/features/library/domain/models/history_entry.dart';

class SqliteLibraryRepository implements LibraryRepository {
  SqliteLibraryRepository(this._db);

  final Database _db;

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
    // One row per pair: searching the same trip again moves it to the top
    // instead of filling the list with copies.
    await _db.delete(
      'history',
      where: 'from_id = ? AND to_id = ?',
      whereArgs: [fromId, toId],
    );
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
