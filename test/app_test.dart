import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:maak_metro/app.dart';
import 'package:maak_metro/features/library/presentation/library_cubit.dart';
import 'package:maak_metro/features/network/domain/models/network_data.dart';
import 'package:maak_metro/features/network/domain/network_repository.dart';
import 'package:maak_metro/features/network/presentation/network_cubit.dart';
import 'package:maak_metro/features/planner/presentation/planner_cubit.dart';
import 'package:maak_metro/features/planner/presentation/planner_screen.dart';
import 'package:maak_metro/features/settings/data/preferences_settings_repository.dart';
import 'package:maak_metro/features/settings/presentation/onboarding_screen.dart';
import 'package:maak_metro/features/settings/presentation/settings_cubit.dart';
import 'package:maak_metro/home_shell.dart';

import 'fixtures/fake_library_repository.dart';
import 'fixtures/fixture_network.dart';

class _FakeNetworkRepository implements NetworkRepository {
  _FakeNetworkRepository(this.network, {this.failures = 0});

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
}

Widget _appWith(
  SettingsCubit settings,
  LibraryCubit library,
  NetworkCubit route, {
  PlannerCubit? planner,
}) {
  addTearDown(settings.close);
  addTearDown(library.close);
  addTearDown(route.close);
  if (planner != null) addTearDown(planner.close);
  return MultiBlocProvider(
    providers: [
      BlocProvider<SettingsCubit>.value(value: settings),
      BlocProvider<LibraryCubit>.value(value: library),
      BlocProvider<NetworkCubit>.value(value: route),
      if (planner case final planner?)
        BlocProvider<PlannerCubit>.value(value: planner)
      else
        BlocProvider(create: (_) => PlannerCubit()),
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

void _useSmallViewportWithLargeText(WidgetTester tester) {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = 1.5;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('locale and direction follow SettingsCubit', (tester) async {
    _useSmallViewportWithLargeText(tester);
    final prefs = await SharedPreferences.getInstance();
    final settings = SettingsCubit(PreferencesSettingsRepository(prefs));
    await settings.completeOnboarding();
    final repo = _FakeNetworkRepository(buildFixtureNetwork());
    final library = LibraryCubit(FakeLibraryRepository());
    await library.refresh();
    final route = NetworkCubit(repo);
    await route.load();

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
    final settings = SettingsCubit(PreferencesSettingsRepository(prefs));
    await settings.setLocale(const Locale('en'));
    await settings.completeOnboarding();
    final repo = _FakeNetworkRepository(buildFixtureNetwork(), failures: 1);
    final library = LibraryCubit(FakeLibraryRepository());
    await library.refresh();
    final route = NetworkCubit(repo);
    await route.load();
    expect(route.state.error, isNotNull);

    await tester.pumpWidget(_appWith(settings, library, route));

    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(route.state.error, isNull);
    expect(find.byType(HomeShell), findsOneWidget);
  });

  testWidgets('first run asks for language and theme before the tabs', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final settings = SettingsCubit(PreferencesSettingsRepository(prefs));
    final repo = _FakeNetworkRepository(buildFixtureNetwork());
    final library = LibraryCubit(FakeLibraryRepository());
    await library.refresh();
    final route = NetworkCubit(repo);
    await route.load();

    await tester.pumpWidget(_appWith(settings, library, route));

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.byType(HomeShell), findsNothing);
    expect(find.byType(SegmentedButton<Locale>), findsOneWidget);
    expect(find.byType(SegmentedButton<ThemeMode>), findsOneWidget);

    await tester.tap(find.text('غامق'));
    await tester.pumpAndSettle();
    expect(settings.state.themeMode, ThemeMode.dark);

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(settings.state.onboarded, isTrue);
    expect(find.byType(HomeShell), findsOneWidget);
  });

  testWidgets(
    'Lines sets the planner endpoint and Saved reopens the starred route',
    (tester) async {
      _useSmallViewportWithLargeText(tester);
      final prefs = await SharedPreferences.getInstance();
      final settings = SettingsCubit(PreferencesSettingsRepository(prefs));
      await settings.setLocale(const Locale('en'));
      await settings.completeOnboarding();
      final network = buildFixtureNetwork();
      final networkCubit = NetworkCubit(_FakeNetworkRepository(network));
      await networkCubit.load();
      final repository = FakeLibraryRepository();
      final library = LibraryCubit(repository);
      await library.refresh();
      final planner = PlannerCubit();
      await tester.pumpWidget(
        _appWith(settings, library, networkCubit, planner: planner),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lines'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ExpansionTile).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Station s1'));
      await tester.pumpAndSettle();
      final start = find.text('Start here');
      await tester.ensureVisible(start);
      await tester.tap(start);
      await tester.pumpAndSettle();
      expect(planner.state.from?.id, 's1');

      planner.setTo(network.stationById('s4'));
      await tester.pumpAndSettle();
      final showRoute = find.text('Show route');
      final plannerScrollable = find.descendant(
        of: find.byType(PlannerScreen),
        matching: find.byType(Scrollable),
      );
      await tester.scrollUntilVisible(
        showRoute,
        200,
        scrollable: plannerScrollable,
      );
      await tester.drag(plannerScrollable, const Offset(0, -80));
      await tester.pumpAndSettle();
      await tester.tap(showRoute);
      await tester.pumpAndSettle();
      expect(find.byTooltip('Add to favorites'), findsOneWidget);
      expect(repository.recordedPairs, [('s1', 's4')]);

      // Changing the planner cannot change the trip displayed by this result.
      planner.setFrom(network.stationById('s5'));
      await tester.tap(find.byTooltip('Add to favorites'));
      await tester.pumpAndSettle();
      expect(library.state.isFavorite('s1', 's4'), isTrue);
      expect(library.state.isFavorite('s5', 's4'), isFalse);
      expect(find.byTooltip('Remove from favorites'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Saved'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Station s1'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Remove from favorites'), findsOneWidget);
      expect(repository.recordedPairs, [('s1', 's4')]);
    },
  );

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
