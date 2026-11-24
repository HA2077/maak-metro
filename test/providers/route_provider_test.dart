import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:maak_metro/domain/domain.dart';
import 'package:maak_metro/domain/metro_repository.dart';
import 'package:maak_metro/providers/route_provider.dart';

import '../fixtures/fixture_network.dart';

class _FakeRepository implements MetroRepository {
  _FakeRepository(this.network);

  final NetworkData network;
  Object? loadError;
  Future<NetworkData>? pendingLoad;
  final history = <List<String>>[];
  final favorites = <String>{};

  static String _key(String fromId, String toId) => '$fromId:$toId';

  @override
  Future<NetworkData> loadNetwork() async {
    final pending = pendingLoad;
    if (pending != null) return pending;
    final failure = loadError;
    if (failure != null) throw failure;
    return network;
  }

  @override
  Future<List<FavoriteRoute>> getFavorites() async => const <FavoriteRoute>[];

  @override
  Future<bool> isFavorite(String fromId, String toId) async =>
      favorites.contains(_key(fromId, toId));

  @override
  Future<void> addFavorite(String fromId, String toId) async {
    favorites.add(_key(fromId, toId));
  }

  @override
  Future<void> removeFavorite(int id) async {}

  @override
  Future<void> removeFavoriteByPair(String fromId, String toId) async {
    favorites.remove(_key(fromId, toId));
  }

  @override
  Future<List<HistoryEntry>> getHistory({int limit = 50}) async =>
      const <HistoryEntry>[];

  @override
  Future<void> addHistory(String fromId, String toId) async {
    history.add([fromId, toId]);
  }

  @override
  Future<void> removeHistory(int id) async => throw UnimplementedError();

  @override
  Future<void> clearHistory() async => history.clear();
}

void main() {
  late NetworkData data;
  late _FakeRepository repo;
  late int libraryChanges;

  RouteProvider provider() => RouteProvider(
    repo,
    onLibraryChanged: () async {
      libraryChanges++;
    },
  );

  Station station(String id) {
    final station = data.stationById(id);
    if (station == null) throw ArgumentError('Unknown station $id');
    return station;
  }

  setUp(() {
    data = buildFixtureNetwork();
    repo = _FakeRepository(data);
    libraryChanges = 0;
  });

  group('RouteProvider init', () {
    test('loads the network and exposes its stations', () async {
      final routeProvider = provider();
      var notifications = 0;
      routeProvider.addListener(() => notifications++);

      await routeProvider.init();

      expect(routeProvider.network, same(data));
      expect(routeProvider.stations, data.stations);
      expect(routeProvider.initError, isNull);
      expect(routeProvider.loading, isFalse);
      expect(notifications, greaterThanOrEqualTo(2));
    });

    test('loading is true while the network load is pending', () async {
      final completer = Completer<NetworkData>();
      repo.pendingLoad = completer.future;
      final routeProvider = provider();

      final pending = routeProvider.init();
      expect(routeProvider.loading, isTrue);

      completer.complete(data);
      await pending;
      expect(routeProvider.loading, isFalse);
    });

    test('stores a load failure without throwing', () async {
      final failure = Exception('seed failed');
      repo.loadError = failure;
      final routeProvider = provider();

      await routeProvider.init();

      expect(routeProvider.initError, same(failure));
      expect(routeProvider.network, isNull);
      expect(routeProvider.loading, isFalse);
    });
  });

  group('RouteProvider calculate', () {
    test('returns a route and writes one history entry', () async {
      final routeProvider = provider();
      await routeProvider.init();
      routeProvider.setFrom(station('t1'));
      routeProvider.setTo(station('p2'));
      expect(routeProvider.canSearch, isTrue);

      expect(await routeProvider.calculate(), isTrue);

      final result = routeProvider.result;
      expect(result, isNotNull);
      expect(result!.fromId, 't1');
      expect(result.toId, 'p2');
      expect(result.legs.map((leg) => leg.lineId), [2, 1, 3]);
      expect(result.stationCount, 6);
      expect(result.transfers, 2);
      expect(result.estimatedMinutes, 30.0);
      expect(result.fareEgp, 10);
      expect(routeProvider.error, RouteError.none);
      expect(routeProvider.loading, isFalse);
      expect(repo.history, [
        ['t1', 'p2'],
      ]);
      expect(libraryChanges, 1);
    });

    test('writes history once per successful calculate', () async {
      final routeProvider = provider();
      await routeProvider.init();
      routeProvider.setFrom(station('s1'));
      routeProvider.setTo(station('s5'));

      expect(await routeProvider.calculate(), isTrue);
      expect(await routeProvider.calculate(), isTrue);

      expect(repo.history, [
        ['s1', 's5'],
        ['s1', 's5'],
      ]);
      expect(libraryChanges, 2);
    });

    test('skipping history still returns the route and calls back', () async {
      final routeProvider = provider();
      await routeProvider.init();
      routeProvider.setFrom(station('s1'));
      routeProvider.setTo(station('s5'));

      expect(await routeProvider.calculate(saveToHistory: false), isTrue);

      expect(routeProvider.result, isNotNull);
      expect(repo.history, isEmpty);
      expect(libraryChanges, 1);
    });

    test('same station reports sameStation without side effects', () async {
      final routeProvider = provider();
      await routeProvider.init();
      routeProvider.setFrom(station('s1'));
      routeProvider.setTo(station('s1'));
      expect(routeProvider.canSearch, isFalse);

      expect(await routeProvider.calculate(), isFalse);

      expect(routeProvider.error, RouteError.sameStation);
      expect(routeProvider.result, isNull);
      expect(repo.history, isEmpty);
      expect(libraryChanges, 0);
    });

    test('no path reports noRoute without side effects', () async {
      final routeProvider = provider();
      await routeProvider.init();
      routeProvider.setFrom(station('s1'));
      routeProvider.setTo(station('iso'));

      expect(await routeProvider.calculate(), isFalse);

      expect(routeProvider.error, RouteError.noRoute);
      expect(routeProvider.result, isNull);
      expect(repo.history, isEmpty);
      expect(libraryChanges, 0);
    });

    test(
      'missing selection or uninitialized network reports noRoute',
      () async {
        final routeProvider = provider();
        expect(await routeProvider.calculate(), isFalse);
        expect(routeProvider.error, RouteError.noRoute);

        routeProvider.setFrom(station('s1'));
        expect(await routeProvider.calculate(), isFalse);
        expect(routeProvider.error, RouteError.noRoute);
        expect(repo.history, isEmpty);
        expect(libraryChanges, 0);
      },
    );

    test('selection changes and swap clear result and error', () async {
      final routeProvider = provider();
      await routeProvider.init();
      routeProvider.setFrom(station('t1'));
      routeProvider.setTo(station('p2'));
      await routeProvider.calculate();
      expect(routeProvider.result, isNotNull);

      routeProvider.swap();
      expect(routeProvider.from?.id, 'p2');
      expect(routeProvider.to?.id, 't1');
      expect(routeProvider.result, isNull);
      expect(routeProvider.error, RouteError.none);

      routeProvider.setFrom(station('s1'));
      routeProvider.setTo(station('s1'));
      await routeProvider.calculate();
      expect(routeProvider.error, RouteError.sameStation);

      routeProvider.setTo(station('t4'));
      expect(routeProvider.error, RouteError.none);
      expect(routeProvider.result, isNull);
    });
  });

  group('RouteProvider favorites', () {
    test('toggle adds, removes and notifies the library', () async {
      final routeProvider = provider();
      await routeProvider.init();
      routeProvider.setFrom(station('s1'));
      routeProvider.setTo(station('t4'));

      expect(await routeProvider.isCurrentFavorite(), isFalse);
      await routeProvider.toggleFavorite();
      expect(repo.favorites, contains('s1:t4'));
      expect(await routeProvider.isCurrentFavorite(), isTrue);
      expect(libraryChanges, 1);

      await routeProvider.toggleFavorite();
      expect(repo.favorites, isEmpty);
      expect(await routeProvider.isCurrentFavorite(), isFalse);
      expect(libraryChanges, 2);
    });

    test('favorites are direction sensitive', () async {
      final routeProvider = provider();
      await routeProvider.init();
      routeProvider.setFrom(station('s1'));
      routeProvider.setTo(station('t4'));
      await routeProvider.toggleFavorite();

      routeProvider.swap();

      expect(await routeProvider.isCurrentFavorite(), isFalse);
    });

    test('favorite actions do nothing without a valid pair', () async {
      final routeProvider = provider();

      expect(await routeProvider.isCurrentFavorite(), isFalse);
      await routeProvider.toggleFavorite();

      expect(repo.favorites, isEmpty);
      expect(libraryChanges, 0);
    });
  });
}
