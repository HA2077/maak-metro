import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:maak_metro/domain/metro_repository.dart';
import 'package:maak_metro/domain/models/metro_models.dart';

/// scaffold: in-memory stand-in for `SqliteMetroRepository` (DB-1..DB-4). It
/// reads the real seed asset and implements the same interface, so replacing
/// it later touches `main.dart` only. Favorites and history are not persisted.
class InMemoryMetroRepository implements MetroRepository {
  NetworkData? _network;
  final List<FavoriteRoute> _favorites = [];
  final List<HistoryEntry> _history = [];
  int _nextId = 1;

  @override
  Future<NetworkData> loadNetwork() async {
    final cached = _network;
    if (cached != null) return cached;
    final raw = await rootBundle.loadString('assets/metro_seed.json');
    final json = jsonDecode(raw) as Map<String, Object?>;
    return _network = NetworkData(
      snapshotDate: json['snapshot_date'] as String? ?? '',
      lines: _rows(
        json['lines'],
        (row) => Line(
          id: row['id'] as int,
          nameAr: row['name_ar'] as String? ?? '',
          nameEn: row['name_en'] as String? ?? '',
          colorHex: row['color_hex'] as String? ?? '',
        ),
      ),
      stations: _rows(
        json['stations'],
        (row) => Station(
          id: row['id'] as String,
          nameAr: row['name_ar'] as String? ?? '',
          nameEn: row['name_en'] as String? ?? '',
        ),
      ),
      branches: _rows(
        json['line_branches'],
        (row) => LineBranch(
          lineId: row['line_id'] as int,
          branch: row['branch'] as String,
          startsAfter: row['starts_after'] as String,
        ),
      ),
      lineStations: _rows(
        json['line_stations'],
        (row) => LineStation(
          lineId: row['line_id'] as int,
          stationId: row['station_id'] as String,
          branch: row['branch'] as String? ?? 'main',
          seq: row['seq'] as int,
        ),
      ),
      fares: _rows(
        json['fares'],
        (row) => FareBracket(
          maxStations: row['max_stations'] as int,
          priceEgp: row['price_egp'] as int,
        ),
      ),
    );
  }

  List<T> _rows<T>(Object? value, T Function(Map<String, Object?> row) parse) =>
      [
        for (final row in value as List<Object?>? ?? const <Object?>[])
          parse(row as Map<String, Object?>),
      ];

  @override
  Future<List<FavoriteRoute>> getFavorites() async =>
      List.unmodifiable(_favorites);

  @override
  Future<void> addFavorite(String fromId, String toId) async {
    if (_favorites.any((f) => f.fromId == fromId && f.toId == toId)) return;
    _favorites.insert(
      0,
      FavoriteRoute(
        id: _nextId++,
        fromId: fromId,
        toId: toId,
        createdAt: DateTime.now().toIso8601String(),
      ),
    );
  }

  @override
  Future<void> removeFavorite(int id) async {
    _favorites.removeWhere((favorite) => favorite.id == id);
  }

  @override
  Future<List<HistoryEntry>> getHistory({int limit = 50}) async =>
      List.unmodifiable(_history.take(limit));

  @override
  Future<void> addHistory(String fromId, String toId) async {
    _history.insert(
      0,
      HistoryEntry(
        id: _nextId++,
        fromId: fromId,
        toId: toId,
        searchedAt: DateTime.now().toIso8601String(),
      ),
    );
    if (_history.length > 50) {
      _history.removeRange(50, _history.length);
    }
  }

  @override
  Future<void> clearHistory() async => _history.clear();
}
