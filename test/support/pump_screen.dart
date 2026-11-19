import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maak_metro/core/l10n/app_localizations.dart';
import 'package:maak_metro/core/theme/app_theme.dart';
import 'package:maak_metro/domain/metro_repository.dart';
import 'package:maak_metro/domain/models/metro_models.dart';
import 'package:maak_metro/providers/library_provider.dart';
import 'package:maak_metro/providers/route_provider.dart';
import 'package:maak_metro/providers/settings_provider.dart';
import 'package:maak_metro/screens/planner_screen.dart';
import 'package:provider/provider.dart';

import 'sample_network.dart';

class TestRepository implements MetroRepository {
  TestRepository({NetworkData? network}) : network = network ?? sampleNetwork();

  final NetworkData network;
  final List<FavoriteRoute> favorites = [];
  final List<HistoryEntry> history = [];

  @override
  Future<NetworkData> loadNetwork() async => network;

  @override
  Future<List<FavoriteRoute>> getFavorites() async =>
      List.unmodifiable(favorites);

  @override
  Future<void> addFavorite(String fromId, String toId) async {
    if (favorites.any((f) => f.fromId == fromId && f.toId == toId)) return;
    favorites.insert(
      0,
      FavoriteRoute(
        id: favorites.length + 1,
        fromId: fromId,
        toId: toId,
        createdAt: '',
      ),
    );
  }

  @override
  Future<void> removeFavorite(int id) async =>
      favorites.removeWhere((f) => f.id == id);

  @override
  Future<List<HistoryEntry>> getHistory({int limit = 50}) async =>
      List.unmodifiable(history.take(limit));

  @override
  Future<void> addHistory(String fromId, String toId) async {
    history.insert(
      0,
      HistoryEntry(
        id: history.length + 1,
        fromId: fromId,
        toId: toId,
        searchedAt: '',
      ),
    );
  }

  @override
  Future<void> clearHistory() async => history.clear();
}

/// Pumps one screen with real providers and a fixture network, at an explicit
/// size and text scale, so overflow shows up as a test failure.
Future<void> pumpScreen(
  WidgetTester tester, {
  Widget screen = const PlannerScreen(),
  NetworkData? network,
  RouteResult? result,
  Size size = const Size(390, 844),
  double textScale = 1,
}) async {
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  final repository = TestRepository(network: network);
  final library = LibraryProvider(repository: repository);
  final settings = SettingsProvider();
  final route = RouteProvider(
    repository: repository,
    library: library,
    planner: ({required fromId, required toId, required data}) => result,
  );
  await route.load();
  await library.refresh();
  if (result != null) {
    route.setFrom(result.fromId);
    route.setTo(result.toId);
    await route.calculate(saveToHistory: false);
  }

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: library),
        ChangeNotifierProvider.value(value: route),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: settings.themeMode,
          locale: settings.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: screen,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
