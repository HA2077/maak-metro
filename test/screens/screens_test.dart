import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:maak_metro/core/l10n/app_localizations.dart';
import 'package:maak_metro/core/theme/app_theme.dart';
import 'package:maak_metro/features/library/presentation/library_cubit.dart';
import 'package:maak_metro/features/library/presentation/library_screen.dart';
import 'package:maak_metro/features/network/domain/models/network_data.dart';
import 'package:maak_metro/features/network/domain/network_repository.dart';
import 'package:maak_metro/features/network/presentation/lines_screen.dart';
import 'package:maak_metro/features/network/presentation/network_cubit.dart';
import 'package:maak_metro/features/planner/domain/domain.dart';
import 'package:maak_metro/features/planner/presentation/planner_cubit.dart';
import 'package:maak_metro/features/planner/presentation/planner_screen.dart';
import 'package:maak_metro/features/planner/presentation/route_result_screen.dart';
import 'package:maak_metro/features/planner/presentation/widgets/leg_card.dart';
import 'package:maak_metro/features/settings/data/preferences_settings_repository.dart';
import 'package:maak_metro/features/settings/presentation/settings_cubit.dart';
import 'package:maak_metro/features/settings/presentation/settings_screen.dart';
import 'package:maak_metro/features/settings/presentation/widgets/date_text.dart';

import '../fixtures/fake_library_repository.dart';
import '../fixtures/fixture_network.dart';

class _FakeNetworkRepository implements NetworkRepository {
  _FakeNetworkRepository(this.network);

  final NetworkData network;

  @override
  Future<NetworkData> loadNetwork() async => network;
}

/// Wraps a screen with its Cubits and an Arabic MaterialApp by default.
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
  final settings = SettingsCubit(PreferencesSettingsRepository(prefs));
  await settings.setLocale(locale);

  final repo = _FakeNetworkRepository(buildFixtureNetwork());
  final library = LibraryCubit(FakeLibraryRepository());
  await library.refresh();
  final route = NetworkCubit(repo);
  await route.load();
  addTearDown(settings.close);
  addTearDown(library.close);
  addTearDown(route.close);

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>.value(value: settings),
        BlocProvider<LibraryCubit>.value(value: library),
        BlocProvider<NetworkCubit>.value(value: route),
        BlocProvider(create: (_) => PlannerCubit()),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: screen,
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

    _testLargeTextLayouts(const PlannerScreen());

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
      await _pumpScreen(
        tester,
        LinesScreen(onStationSelected: (_, {required from}) {}),
      );
      expect(tester.takeException(), isNull);
      // One ExpansionTile per line in the fixture.
      expect(find.byType(ExpansionTile), findsNWidgets(network.lines.length));
    });

    _testLargeTextLayouts(
      LinesScreen(onStationSelected: (_, {required from}) {}),
    );

    testWidgets('expanding a line lists its stations', (tester) async {
      await _pumpScreen(
        tester,
        LinesScreen(onStationSelected: (_, {required from}) {}),
      );
      await tester.tap(find.byType(ExpansionTile).first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('LibraryScreen', () {
    testWidgets('shows the empty state when nothing is stored', (tester) async {
      await _pumpScreen(tester, LibraryScreen(onOpenPlanner: () {}));
      expect(find.byType(TabBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    _testLargeTextLayouts(LibraryScreen(onOpenPlanner: () {}));
  });

  group('SettingsScreen', () {
    testWidgets('shows the language switch and the About rows', (tester) async {
      await _pumpScreen(tester, const SettingsScreen());
      expect(find.byType(SegmentedButton<Locale>), findsOneWidget);
      expect(find.text('تاريخ البيانات'), findsOneWidget);
      expect(find.text('سريان الأجرة'), findsOneWidget);
      // Each date is three texts so bidi cannot reorder the fields; the second
      // row may sit below the fold, hence findsWidgets.
      expect(find.byType(DateText), findsWidgets);
      expect(find.text('٢٠٢٦'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    _testLargeTextLayouts(const SettingsScreen());
  });

  group('RouteResultScreen', () {
    final result = findRoute(
      fromId: 't1',
      toId: 's4',
      data: network,
      config: const RoutingConfig(),
    )!;
    final screen = RouteResultScreen(result: result, network: network);

    testWidgets('shows the summary and one card per leg', (tester) async {
      await _pumpScreen(tester, screen);
      expect(find.byType(LegCard), findsNWidgets(result.legs.length));
      expect(tester.takeException(), isNull);
    });

    _testLargeTextLayouts(screen);
  });
}

void _testLargeTextLayouts(Widget screen) {
  for (final locale in [const Locale('ar'), const Locale('en')]) {
    testWidgets('renders at 360dp with 1.5x text in ${locale.languageCode}', (
      tester,
    ) async {
      await _pumpScreen(tester, screen, locale: locale, textScale: 1.5);
      final context = tester.element(find.byWidget(screen));
      expect(
        Directionality.of(context),
        locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      );
    });
  }
}
