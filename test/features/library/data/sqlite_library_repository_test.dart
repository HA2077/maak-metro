import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:maak_metro/core/data/db_helper.dart';
import 'package:maak_metro/features/library/data/sqlite_library_repository.dart';
import 'package:maak_metro/features/network/data/seed_loader.dart';

/// Ten stations from the seed; any ordered pair of them is a valid trip.
const _historyStations = [
  'helwan',
  'ain_helwan',
  'helwan_university',
  'wadi_hof',
  'hadayek_helwan',
  'el_maasara',
  'tora_el_asmant',
  'kotsika',
  'tora_el_balad',
  'maadi_barracks',
];

/// History keeps one row per pair, so a test that needs many rows has to
/// search many different trips.
Future<void> addDistinctHistory(
  SqliteLibraryRepository repository,
  int count,
) async {
  var added = 0;
  for (final from in _historyStations) {
    for (final to in _historyStations) {
      if (from == to) continue;
      await repository.addHistory(from, to);
      if (++added == count) return;
    }
  }
  fail(
    'only ${_historyStations.length * (_historyStations.length - 1)} '
    'distinct pairs exist, asked for $count',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late DbHelper helper;
  late SqliteLibraryRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    helper = DbHelper(path: inMemoryDatabasePath);
    final db = await helper.database;
    await SeedLoader(db, prefs).seedIfNeeded();
    repository = SqliteLibraryRepository(db);
  });

  tearDown(() async {
    await helper.close();
  });

  group('favorites', () {
    test('saving the same pair twice does nothing', () async {
      await repository.addFavorite('sadat', 'nasser');
      await repository.addFavorite('sadat', 'nasser');

      expect(await repository.isFavorite('sadat', 'nasser'), isTrue);
      expect(await repository.getFavorites(), hasLength(1));
    });

    test('the pair is ordered, not the direction', () async {
      await repository.addFavorite('sadat', 'nasser');
      await repository.addFavorite('nasser', 'sadat');

      expect(await repository.getFavorites(), hasLength(2));
    });

    test('lists favorites newest first', () async {
      await repository.addFavorite('sadat', 'nasser');
      await repository.addFavorite('nasser', 'sadat');

      final favorites = await repository.getFavorites();
      expect(favorites.first.id, greaterThan(favorites.last.id));
      expect(
        favorites.first.createdAt.isBefore(favorites.last.createdAt),
        isFalse,
      );
    });

    test('removes by id and by pair', () async {
      await repository.addFavorite('sadat', 'nasser');
      await repository.addFavorite('nasser', 'sadat');

      final favorites = await repository.getFavorites();
      await repository.removeFavorite(favorites.first.id);
      expect(await repository.getFavorites(), hasLength(1));

      await repository.removeFavoriteByPair('sadat', 'nasser');
      expect(await repository.getFavorites(), isEmpty);
      expect(await repository.isFavorite('sadat', 'nasser'), isFalse);
    });

    test('removing something that does not exist is a no-op', () async {
      await repository.removeFavoriteByPair('sadat', 'nasser');
      await repository.removeFavorite(999);

      expect(await repository.getFavorites(), isEmpty);
    });

    test('an unknown station id throws', () async {
      await expectLater(
        repository.addFavorite('sadat', 'no_such_station'),
        throwsA(isA<DatabaseException>()),
      );
      expect(await repository.getFavorites(), isEmpty);
    });
  });

  group('history', () {
    test('keeps the newest 50 entries when 60 are added', () async {
      await addDistinctHistory(repository, 60);

      final history = await repository.getHistory(limit: 100);
      expect(history, hasLength(50));
    });

    test('lists history newest first by id', () async {
      await addDistinctHistory(repository, 3);

      final history = await repository.getHistory();
      final ids = [for (final entry in history) entry.id];
      expect(ids, [...ids]..sort((a, b) => b.compareTo(a)));
    });

    test('keeps one row per pair and moves it to the top', () async {
      await repository.addHistory('sadat', 'nasser');
      await repository.addHistory('helwan', 'maadi');
      await repository.addHistory('sadat', 'nasser');

      final rows = await repository.getHistory();

      expect(rows, hasLength(2));
      expect(rows.first.fromId, 'sadat');
      expect(rows.first.toId, 'nasser');
      // Direction still counts as a different trip.
      await repository.addHistory('nasser', 'sadat');
      expect(await repository.getHistory(), hasLength(3));
    });

    test('respects the limit parameter', () async {
      await addDistinctHistory(repository, 55);

      final all = await repository.getHistory(limit: 100);
      final three = await repository.getHistory(limit: 3);

      expect(all, hasLength(50));
      expect(three, hasLength(3));
      expect(three.first.id, all.first.id);
    });

    test('removes one row and leaves the rest', () async {
      await repository.addHistory('sadat', 'nasser');
      await repository.addHistory('nasser', 'sadat');
      final rows = await repository.getHistory();
      final older = rows.last;

      await repository.removeHistory(older.id);

      final left = await repository.getHistory();
      expect(left, hasLength(1));
      expect(left.single.id, isNot(older.id));
    });

    test('clears every row', () async {
      await repository.addHistory('sadat', 'nasser');

      await repository.clearHistory();

      expect(await repository.getHistory(), isEmpty);
    });

    test('an unknown station id throws and keeps the history', () async {
      await repository.addHistory('sadat', 'nasser');

      await expectLater(
        repository.addHistory('no_such_station', 'sadat'),
        throwsA(isA<DatabaseException>()),
      );
      expect(await repository.getHistory(), hasLength(1));
    });
  });
}
