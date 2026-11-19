import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maak_metro/app.dart';
import 'package:maak_metro/providers/library_provider.dart';
import 'package:maak_metro/providers/route_provider.dart';
import 'package:maak_metro/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/pump_screen.dart';

Future<void> _pumpApp(WidgetTester tester, SettingsProvider settings) async {
  tester.view.physicalSize = const Size(780, 1688);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  final repository = TestRepository();
  final library = LibraryProvider(repository: repository);
  final route = RouteProvider(repository: repository, library: library);
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
}

void main() {
  testWidgets('a fresh install configures language and theme first', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final settings = SettingsProvider();
    await settings.load();
    expect(settings.onboarded, isFalse);

    await _pumpApp(tester, settings);

    expect(find.text('أهلاً بيك في معاك'), findsOneWidget);
    expect(find.text('يلا نبدأ'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.tap(find.text('يلا نبدأ'));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(settings.onboarded, isTrue);
  });

  testWidgets('a returning user goes straight to the tabs', (tester) async {
    SharedPreferences.setMockInitialValues({'onboarded': true});
    final settings = SettingsProvider();
    await settings.load();
    expect(settings.onboarded, isTrue);

    await _pumpApp(tester, settings);

    expect(find.text('أهلاً بيك في معاك'), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
