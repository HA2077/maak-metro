import 'package:flutter_test/flutter_test.dart';

import 'package:maak_metro/features/library/domain/models/favorite_route.dart';
import 'package:maak_metro/features/library/domain/models/history_entry.dart';
import 'package:maak_metro/features/library/presentation/library_cubit.dart';

import '../../../fixtures/fake_library_repository.dart';

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
  group('LibraryCubit', () {
    test(
      'records successful searches in order and refreshes the recent list',
      () async {
        final repository = FakeLibraryRepository();
        final cubit = LibraryCubit(repository);
        addTearDown(cubit.close);

        await Future.wait([
          cubit.recordSearch('s1', 's5'),
          cubit.recordSearch('s5', 's1'),
          cubit.recordSearch('s1', 's5'),
        ]);

        expect(repository.recordedPairs, [
          ('s1', 's5'),
          ('s5', 's1'),
          ('s1', 's5'),
        ]);
        expect(cubit.state.history.map((entry) => (entry.fromId, entry.toId)), [
          ('s1', 's5'),
          ('s5', 's1'),
        ]);
      },
    );

    test('shows the three most recent distinct trips', () async {
      final recent = _entry(1);
      final duplicate = HistoryEntry(
        id: 5,
        fromId: recent.fromId,
        toId: recent.toId,
        searchedAt: DateTime(2025),
      );
      final cubit = LibraryCubit(
        FakeLibraryRepository(
          history: [recent, duplicate, _entry(2), _entry(3), _entry(4)],
        ),
      );
      addTearDown(cubit.close);

      await cubit.refresh();

      expect(cubit.state.recentSearches.map((entry) => entry.id), [1, 2, 3]);
    });

    test('toggles favorites in the selected direction only', () async {
      final cubit = LibraryCubit(FakeLibraryRepository());
      addTearDown(cubit.close);

      await cubit.toggleFavorite('s1', 's1');
      expect(cubit.state.favorites, isEmpty);
      expect(cubit.state.isFavorite('s1', 't4'), isFalse);

      await cubit.toggleFavorite('s1', 't4');
      expect(cubit.state.isFavorite('s1', 't4'), isTrue);
      expect(cubit.state.isFavorite('t4', 's1'), isFalse);

      await cubit.toggleFavorite('s1', 't4');
      expect(cubit.state.favorites, isEmpty);
    });

    test('starts with empty lists until refreshed', () {
      final cubit = LibraryCubit(
        FakeLibraryRepository(favorites: [_favorite(1)], history: [_entry(1)]),
      );

      addTearDown(cubit.close);
      expect(cubit.state.favorites, isEmpty);
      expect(cubit.state.history, isEmpty);
    });

    test('refresh fills both lists and notifies once', () async {
      final repo = FakeLibraryRepository(
        favorites: [_favorite(1), _favorite(2)],
        history: [_entry(1)],
      );
      final cubit = LibraryCubit(repo);
      addTearDown(cubit.close);
      var notifications = 0;
      final subscription = cubit.stream.listen((_) => notifications++);
      addTearDown(subscription.cancel);

      await cubit.refresh();

      expect(cubit.state.favorites.map((favorite) => favorite.id), [1, 2]);
      expect(cubit.state.history.map((entry) => entry.id), [1]);
      expect(repo.getFavoritesCalls, 1);
      expect(repo.getHistoryCalls, 1);
      await Future<void>.delayed(Duration.zero);
      expect(notifications, 1);
    });

    test('removing a favorite refreshes the cached list', () async {
      final repo = FakeLibraryRepository(
        favorites: [_favorite(1), _favorite(2)],
      );
      final cubit = LibraryCubit(repo);
      addTearDown(cubit.close);
      await cubit.refresh();
      var notifications = 0;
      final subscription = cubit.stream.listen((_) => notifications++);
      addTearDown(subscription.cancel);

      await cubit.removeFavorite(1);

      expect(repo.removedIds, [1]);
      expect(cubit.state.favorites.map((favorite) => favorite.id), [2]);
      expect(repo.getFavoritesCalls, 2);
      expect(repo.getHistoryCalls, 2);
      await Future<void>.delayed(Duration.zero);
      expect(notifications, 1);
    });

    test('removing one history row keeps the rest', () async {
      final repo = FakeLibraryRepository(
        favorites: [_favorite(1)],
        history: [_entry(1), _entry(2), _entry(3)],
      );
      final cubit = LibraryCubit(repo);
      addTearDown(cubit.close);
      await cubit.refresh();
      var notifications = 0;
      final subscription = cubit.stream.listen((_) => notifications++);
      addTearDown(subscription.cancel);

      await cubit.removeHistory(2);

      expect(repo.removeHistoryIds, [2]);
      expect(cubit.state.history.map((entry) => entry.id), [1, 3]);
      expect(cubit.state.favorites.map((favorite) => favorite.id), [1]);
      await Future<void>.delayed(Duration.zero);
      expect(notifications, 1);
    });

    test('clearing history refreshes the cached list', () async {
      final repo = FakeLibraryRepository(
        favorites: [_favorite(1)],
        history: [_entry(1), _entry(2)],
      );
      final cubit = LibraryCubit(repo);
      addTearDown(cubit.close);
      await cubit.refresh();
      var notifications = 0;
      final subscription = cubit.stream.listen((_) => notifications++);
      addTearDown(subscription.cancel);

      await cubit.clearHistory();

      expect(repo.clearHistoryCalls, 1);
      expect(cubit.state.history, isEmpty);
      expect(cubit.state.favorites.map((favorite) => favorite.id), [1]);
      await Future<void>.delayed(Duration.zero);
      expect(notifications, 1);
    });
  });
}
