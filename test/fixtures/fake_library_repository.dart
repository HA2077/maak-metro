import 'package:maak_metro/features/library/domain/library_repository.dart';
import 'package:maak_metro/features/library/domain/models/favorite_route.dart';
import 'package:maak_metro/features/library/domain/models/history_entry.dart';

class FakeLibraryRepository implements LibraryRepository {
  FakeLibraryRepository({
    List<FavoriteRoute> favorites = const <FavoriteRoute>[],
    List<HistoryEntry> history = const <HistoryEntry>[],
  }) : _favorites = [...favorites],
       _history = [...history];

  final List<FavoriteRoute> _favorites;
  final List<HistoryEntry> _history;
  int getFavoritesCalls = 0;
  int getHistoryCalls = 0;
  int clearHistoryCalls = 0;
  int _nextId = 100;
  final recordedPairs = <(String, String)>[];
  final removedIds = <int>[];
  final removeHistoryIds = <int>[];

  @override
  Future<List<FavoriteRoute>> getFavorites() async {
    getFavoritesCalls++;
    return _favorites;
  }

  @override
  Future<bool> isFavorite(String fromId, String toId) async =>
      _favorites.any((entry) => entry.fromId == fromId && entry.toId == toId);

  @override
  Future<void> addFavorite(String fromId, String toId) async {
    _favorites.insert(
      0,
      FavoriteRoute(
        id: _nextId++,
        fromId: fromId,
        toId: toId,
        createdAt: DateTime.utc(2026),
      ),
    );
  }

  @override
  Future<void> removeFavorite(int id) async {
    removedIds.add(id);
    _favorites.removeWhere((favorite) => favorite.id == id);
  }

  @override
  Future<void> removeFavoriteByPair(String fromId, String toId) async {
    _favorites.removeWhere(
      (entry) => entry.fromId == fromId && entry.toId == toId,
    );
  }

  @override
  Future<List<HistoryEntry>> getHistory({int limit = 50}) async {
    getHistoryCalls++;
    return _history;
  }

  @override
  Future<void> addHistory(String fromId, String toId) async {
    recordedPairs.add((fromId, toId));
    _history.removeWhere(
      (entry) => entry.fromId == fromId && entry.toId == toId,
    );
    _history.insert(
      0,
      HistoryEntry(
        id: _nextId++,
        fromId: fromId,
        toId: toId,
        searchedAt: DateTime.utc(2026),
      ),
    );
  }

  @override
  Future<void> removeHistory(int id) async {
    removeHistoryIds.add(id);
    _history.removeWhere((entry) => entry.id == id);
  }

  @override
  Future<void> clearHistory() async {
    clearHistoryCalls++;
    _history.clear();
  }
}
