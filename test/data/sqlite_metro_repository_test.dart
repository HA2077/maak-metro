import 'package:flutter_test/flutter_test.dart';
import 'package:maak_metro/data/db_helper.dart';
import 'package:maak_metro/data/metro_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late DbHelper helper;
  late SqliteMetroRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    helper = DbHelper(path: inMemoryDatabasePath);
    repository = await SqliteMetroRepository.create(
      helper: helper,
      prefs: prefs,
    );
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
      for (var i = 0; i < 60; i++) {
        await repository.addHistory('sadat', 'nasser');
      }

      final history = await repository.getHistory();
      expect(history, hasLength(50));
    });

    test('lists history newest first by id', () async {
      for (var i = 0; i < 3; i++) {
        await repository.addHistory('sadat', 'nasser');
      }

      final history = await repository.getHistory();
      final ids = [for (final entry in history) entry.id];
      expect(ids, [...ids]..sort((a, b) => b.compareTo(a)));
    });

    test('respects the limit parameter', () async {
      for (var i = 0; i < 10; i++) {
        await repository.addHistory('sadat', 'nasser');
      }

      final all = await repository.getHistory();
      final three = await repository.getHistory(limit: 3);

      expect(all, hasLength(10));
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
