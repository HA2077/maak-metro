import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maak_metro/app.dart';
import 'package:maak_metro/domain/domain.dart';
import 'package:maak_metro/domain/metro_repository.dart';
import 'package:maak_metro/providers/library_provider.dart';
import 'package:maak_metro/providers/route_provider.dart';
import 'package:maak_metro/providers/settings_provider.dart';
import 'package:maak_metro/screens/home_shell.dart';
import 'package:maak_metro/screens/onboarding_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fixtures/fixture_network.dart';

class _FakeRepository implements MetroRepository {
  _FakeRepository(this.network, {this.failures = 0});

  final NetworkData network;
  int failures;

  @override
  Future<NetworkData> loadNetwork() async {
    if (failures > 0) {
      failures--;
      throw Exception('seed boom');
    }
    return network;
  }

  @override
  Future<List<FavoriteRoute>> getFavorites() async => const <FavoriteRoute>[];

  @override
  Future<bool> isFavorite(String fromId, String toId) async => false;

  @override
  Future<void> addFavorite(String fromId, String toId) async {}

  @override
  Future<void> removeFavorite(int id) async {}

  @override
  Future<void> removeFavoriteByPair(String fromId, String toId) async {}

  @override
  Future<List<HistoryEntry>> getHistory({int limit = 50}) async =>
      const <HistoryEntry>[];

  @override
  Future<void> addHistory(String fromId, String toId) async {}

  @override
  Future<void> removeHistory(int id) async {}
  @override
  Future<void> clearHistory() async {}
}

Widget _appWith(
  SettingsProvider settings,
  LibraryProvider library,
  RouteProvider route,
) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<SettingsProvider>.value(value: settings),
      ChangeNotifierProvider<LibraryProvider>.value(value: library),
      ChangeNotifierProvider<RouteProvider>.value(value: route),
    ],
    child: const MaakMetroApp(),
  );
}

Directionality _shellDirectionality(WidgetTester tester) =>
    tester.widget<Directionality>(
      find
          .ancestor(
            of: find.byType(HomeShell),
            matching: find.byType(Directionality),
          )
          .first,
    );

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('locale and direction follow SettingsProvider', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final settings = SettingsProvider(prefs);
    await settings.load();
    await settings.completeOnboarding();
    final repo = _FakeRepository(buildFixtureNetwork());
    final library = LibraryProvider(repo);
    await library.refresh();
    final route = RouteProvider(repo, onLibraryChanged: library.refresh);
    await route.init();

    await tester.pumpWidget(_appWith(settings, library, route));

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).locale,
      const Locale('ar'),
    );
    expect(_shellDirectionality(tester).textDirection, TextDirection.rtl);

    await settings.setLocale(const Locale('en'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).locale,
      const Locale('en'),
    );
    expect(_shellDirectionality(tester).textDirection, TextDirection.ltr);
  });

  testWidgets('init error shows the error screen and retry re-initializes', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final settings = SettingsProvider(prefs);
    await settings.setLocale(const Locale('en'));
    await settings.completeOnboarding();
    final repo = _FakeRepository(buildFixtureNetwork(), failures: 1);
    final library = LibraryProvider(repo);
    await library.refresh();
    final route = RouteProvider(repo, onLibraryChanged: library.refresh);
    await route.init();
    expect(route.initError, isNotNull);

    await tester.pumpWidget(_appWith(settings, library, route));

    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(route.initError, isNull);
    expect(find.byType(HomeShell), findsOneWidget);
  });

  testWidgets('first run asks for language and theme before the tabs', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final settings = SettingsProvider(prefs);
    await settings.load();
    final repo = _FakeRepository(buildFixtureNetwork());
    final library = LibraryProvider(repo);
    await library.refresh();
    final route = RouteProvider(repo, onLibraryChanged: library.refresh);
    await route.init();

    await tester.pumpWidget(_appWith(settings, library, route));

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.byType(HomeShell), findsNothing);
    expect(find.byType(SegmentedButton<Locale>), findsOneWidget);
    expect(find.byType(SegmentedButton<ThemeMode>), findsOneWidget);

    await tester.tap(find.text('غامق'));
    await tester.pumpAndSettle();
    expect(settings.themeMode, ThemeMode.dark);

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(settings.onboarded, isTrue);
    expect(find.byType(HomeShell), findsOneWidget);
  });

  testWidgets('startup error shows the error screen and fires retry', (
    tester,
  ) async {
    var retries = 0;

    await tester.pumpWidget(
      MaakMetroApp(
        startupError: Exception('seed boom'),
        onRetry: () async {
          retries++;
        },
      ),
    );

    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.textContaining('seed boom'), findsOneWidget);

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(retries, 1);
  });
}
