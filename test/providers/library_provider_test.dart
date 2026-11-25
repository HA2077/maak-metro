import 'package:flutter_test/flutter_test.dart';
import 'package:maak_metro/domain/domain.dart';
import 'package:maak_metro/domain/metro_repository.dart';
import 'package:maak_metro/providers/library_provider.dart';

class _FakeRepository implements MetroRepository {
  _FakeRepository({
    List<FavoriteRoute> favorites = const <FavoriteRoute>[],
    List<HistoryEntry> history = const <HistoryEntry>[],
  }) : _favorites = [...favorites],
       _history = [...history];

  final List<FavoriteRoute> _favorites;
  final List<HistoryEntry> _history;
  int getFavoritesCalls = 0;
  int getHistoryCalls = 0;
  int clearHistoryCalls = 0;
  final removedIds = <int>[];
  final removeHistoryIds = <int>[];

  @override
  Future<NetworkData> loadNetwork() => throw UnimplementedError();

  @override
  Future<List<FavoriteRoute>> getFavorites() async {
    getFavoritesCalls++;
    return _favorites;
  }

  @override
  Future<bool> isFavorite(String fromId, String toId) =>
      throw UnimplementedError();

  @override
  Future<void> addFavorite(String fromId, String toId) =>
      throw UnimplementedError();

  @override
  Future<void> removeFavorite(int id) async {
    removedIds.add(id);
    _favorites.removeWhere((favorite) => favorite.id == id);
  }

  @override
  Future<void> removeFavoriteByPair(String fromId, String toId) =>
      throw UnimplementedError();

  @override
  Future<List<HistoryEntry>> getHistory({int limit = 50}) async {
    getHistoryCalls++;
    return _history;
  }

  @override
  Future<void> addHistory(String fromId, String toId) =>
      throw UnimplementedError();

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

FavoriteRoute _favorite(int id) => FavoriteRoute(
  id: id,
  fromId: 'from$id',
  toId: 'to$id',
  createdAt: DateTime(2026),
);

HistoryEntry _entry(int id) => HistoryEntry(
  id: id,
  fromId: 'from$id',
  toId: 'to$id',
  searchedAt: DateTime(2026),
);

void main() {
  group('LibraryProvider', () {
    test('starts with empty lists until refreshed', () {
      final provider = LibraryProvider(
        _FakeRepository(favorites: [_favorite(1)], history: [_entry(1)]),
      );

      expect(provider.favorites, isEmpty);
      expect(provider.history, isEmpty);
    });

    test('refresh fills both lists and notifies once', () async {
      final repo = _FakeRepository(
        favorites: [_favorite(1), _favorite(2)],
        history: [_entry(1)],
      );
      final provider = LibraryProvider(repo);
      var notifications = 0;
      provider.addListener(() => notifications++);

      await provider.refresh();

      expect(provider.favorites.map((favorite) => favorite.id), [1, 2]);
      expect(provider.history.map((entry) => entry.id), [1]);
      expect(repo.getFavoritesCalls, 1);
      expect(repo.getHistoryCalls, 1);
      expect(notifications, 1);
    });

    test('removing a favorite refreshes the cached list', () async {
      final repo = _FakeRepository(favorites: [_favorite(1), _favorite(2)]);
      final provider = LibraryProvider(repo);
      await provider.refresh();
      var notifications = 0;
      provider.addListener(() => notifications++);

      await provider.removeFavorite(1);

      expect(repo.removedIds, [1]);
      expect(provider.favorites.map((favorite) => favorite.id), [2]);
      expect(repo.getFavoritesCalls, 2);
      expect(repo.getHistoryCalls, 2);
      expect(notifications, 1);
    });

    test('removing one history row keeps the rest', () async {
      final repo = _FakeRepository(
        favorites: [_favorite(1)],
        history: [_entry(1), _entry(2), _entry(3)],
      );
      final provider = LibraryProvider(repo);
      await provider.refresh();
      var notifications = 0;
      provider.addListener(() => notifications++);

      await provider.removeHistory(2);

      expect(repo.removeHistoryIds, [2]);
      expect(provider.history.map((entry) => entry.id), [1, 3]);
      expect(provider.favorites.map((favorite) => favorite.id), [1]);
      expect(notifications, 1);
    });

    test('clearing history refreshes the cached list', () async {
      final repo = _FakeRepository(
        favorites: [_favorite(1)],
        history: [_entry(1), _entry(2)],
      );
      final provider = LibraryProvider(repo);
      await provider.refresh();
      var notifications = 0;
      provider.addListener(() => notifications++);

      await provider.clearHistory();

      expect(repo.clearHistoryCalls, 1);
      expect(provider.history, isEmpty);
      expect(provider.favorites.map((favorite) => favorite.id), [1]);
      expect(notifications, 1);
    });
  });
}
