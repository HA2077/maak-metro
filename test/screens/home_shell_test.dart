import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maak_metro/app.dart';
import 'package:maak_metro/domain/metro_repository.dart';
import 'package:maak_metro/domain/models/metro_models.dart';
import 'package:maak_metro/providers/library_provider.dart';
import 'package:maak_metro/providers/route_provider.dart';
import 'package:maak_metro/providers/settings_provider.dart';
import 'package:provider/provider.dart';

class _EmptyRepository implements MetroRepository {
  @override
  Future<NetworkData> loadNetwork() async => NetworkData.empty;

  @override
  Future<List<FavoriteRoute>> getFavorites() async => const [];

  @override
  Future<void> addFavorite(String fromId, String toId) async {}

  @override
  Future<void> removeFavorite(int id) async {}

  @override
  Future<List<HistoryEntry>> getHistory({int limit = 50}) async => const [];

  @override
  Future<void> addHistory(String fromId, String toId) async {}

  @override
  Future<void> clearHistory() async {}
}

void main() {
  testWidgets('the four tabs switch and the app starts in Arabic', (
    tester,
  ) async {
    final repository = _EmptyRepository();
    final library = LibraryProvider(repository: repository);
    final route = RouteProvider(repository: repository, library: library);
    final settings = SettingsProvider();
    await route.load();
    await library.refresh();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settings),
          ChangeNotifierProvider.value(value: library),
          ChangeNotifierProvider.value(value: route),
        ],
        child: const MaakMetroApp(),
      ),
    );
    await tester.pumpAndSettle();

    NavigationBar bar() =>
        tester.widget<NavigationBar>(find.byType(NavigationBar));

    expect(find.text('خطّط مشوارك'), findsOneWidget);
    expect(bar().selectedIndex, 0);
    expect(
      Directionality.of(tester.element(find.byType(NavigationBar))),
      TextDirection.rtl,
    );

    for (final (icon, index) in [
      (Icons.subway_outlined, 1),
      (Icons.bookmark_border, 2),
      (Icons.settings_outlined, 3),
      (Icons.alt_route, 0),
    ]) {
      await tester.tap(find.byIcon(icon));
      await tester.pumpAndSettle();
      expect(bar().selectedIndex, index);
    }
  });
}
