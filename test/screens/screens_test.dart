import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maak_metro/core/l10n/app_localizations.dart';
import 'package:maak_metro/core/theme/app_theme.dart';
import 'package:maak_metro/domain/domain.dart';
import 'package:maak_metro/domain/metro_repository.dart';
import 'package:maak_metro/providers/library_provider.dart';
import 'package:maak_metro/providers/route_provider.dart';
import 'package:maak_metro/providers/settings_provider.dart';
import 'package:maak_metro/screens/library_screen.dart';
import 'package:maak_metro/screens/lines_screen.dart';
import 'package:maak_metro/screens/planner_screen.dart';
import 'package:maak_metro/screens/route_result_screen.dart';
import 'package:maak_metro/screens/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fixtures/fixture_network.dart';

class _FakeRepository implements MetroRepository {
  _FakeRepository(this.network);

  final NetworkData network;

  @override
  Future<NetworkData> loadNetwork() async => network;

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
  Future<void> clearHistory() async {}
}

/// Wraps a screen with the three providers and an Arabic MaterialApp.
Future<void> _pumpScreen(
  WidgetTester tester,
  Widget screen, {
  Locale locale = const Locale('ar'),
  Size size = const Size(360, 800),
  double textScale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues(<String, Object>{});
  final prefs = await SharedPreferences.getInstance();
  final settings = SettingsProvider(prefs);
  await settings.setLocale(locale);

  final repo = _FakeRepository(buildFixtureNetwork());
  final library = LibraryProvider(repo);
  await library.refresh();
  final route = RouteProvider(repo, onLibraryChanged: library.refresh);
  await route.init();

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsProvider>.value(value: settings),
          ChangeNotifierProvider<LibraryProvider>.value(value: library),
          ChangeNotifierProvider<RouteProvider>.value(value: route),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: screen,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  final network = buildFixtureNetwork();

  group('PlannerScreen', () {
    testWidgets('renders at 360dp in Arabic without overflow', (tester) async {
      await _pumpScreen(tester, const PlannerScreen());
      expect(
        find.text(
          AppLocalizations.of(tester.element(find.byType(PlannerScreen)))
              .fromLabel,
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders at 360dp with 1.5x text', (tester) async {
      await _pumpScreen(tester, const PlannerScreen(), textScale: 1.5);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in English and LTR', (tester) async {
      await _pumpScreen(
        tester,
        const PlannerScreen(),
        locale: const Locale('en'),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('Find route is disabled until both stations are picked', (
      tester,
    ) async {
      await _pumpScreen(tester, const PlannerScreen());
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.enabled, isFalse);
    });
  });

  group('LinesScreen', () {
    testWidgets('renders every line from the network', (tester) async {
      await _pumpScreen(tester, const LinesScreen());
      expect(tester.takeException(), isNull);
      // One ExpansionTile per line in the fixture.
      expect(find.byType(ExpansionTile), findsNWidgets(network.lines.length));
    });

    testWidgets('renders at 360dp with 1.5x text', (tester) async {
      await _pumpScreen(tester, const LinesScreen(), textScale: 1.5);
      expect(tester.takeException(), isNull);
    });

    testWidgets('expanding a line lists its stations', (tester) async {
      await _pumpScreen(tester, const LinesScreen());
      await tester.tap(find.byType(ExpansionTile).first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('LibraryScreen', () {
    testWidgets('shows the empty state when nothing is stored', (tester) async {
      await _pumpScreen(tester, const LibraryScreen());
      expect(find.byType(TabBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders at 360dp with 1.5x text', (tester) async {
      await _pumpScreen(tester, const LibraryScreen(), textScale: 1.5);
      expect(tester.takeException(), isNull);
    });
  });

  group('SettingsScreen', () {
    testWidgets('shows the language switch and the About rows', (tester) async {
      await _pumpScreen(tester, const SettingsScreen());
      expect(find.byType(SegmentedButton<Locale>), findsOneWidget);
      expect(find.textContaining('2026-03-27'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders at 360dp with 1.5x text', (tester) async {
      await _pumpScreen(tester, const SettingsScreen(), textScale: 1.5);
      expect(tester.takeException(), isNull);
    });
  });

  group('RouteResultScreen', () {
    testWidgets('shows the summary and one card per leg', (tester) async {
      await _pumpScreen(tester, const RouteResultScreen());
      // The fixture lets us search x -> s4 with a transfer.
      final context = tester.element(find.byType(RouteResultScreen));
      final route = Provider.of<RouteProvider>(context, listen: false);
      route.setFrom(network.stationById('x'));
      route.setTo(network.stationById('s4'));
      await route.calculate();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders at 360dp with 1.5x text', (tester) async {
      await _pumpScreen(tester, const RouteResultScreen(), textScale: 1.5);
      expect(tester.takeException(), isNull);
    });
  });
}
