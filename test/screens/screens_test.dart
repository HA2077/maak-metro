import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:maak_metro/core/l10n/app_localizations.dart';
import 'package:maak_metro/core/theme/app_theme.dart';
import 'package:maak_metro/features/library/presentation/library_cubit.dart';
import 'package:maak_metro/features/library/presentation/library_screen.dart';
import 'package:maak_metro/features/network/domain/models/models.dart';
import 'package:maak_metro/features/network/domain/network_repository.dart';
import 'package:maak_metro/features/network/presentation/lines_screen.dart';
import 'package:maak_metro/features/network/presentation/network_cubit.dart';
import 'package:maak_metro/features/network/presentation/widgets/line_chip.dart';
import 'package:maak_metro/features/planner/domain/domain.dart';
import 'package:maak_metro/features/planner/presentation/planner_cubit.dart';
import 'package:maak_metro/features/planner/presentation/planner_screen.dart';
import 'package:maak_metro/features/planner/presentation/route_result_screen.dart';
import 'package:maak_metro/features/planner/presentation/widgets/count_up.dart';
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

NetworkData _withTermini(NetworkData base) => NetworkData(
  lines: [
    for (final line in base.lines)
      Line(
        id: line.id,
        nameAr: line.nameAr,
        nameEn: line.nameEn,
        colorHex: line.colorHex,
        terminusAAr: 'طرف أ',
        terminusAEn: 'Terminus A',
        terminusBAr: 'طرف ب',
        terminusBEn: 'Terminus B',
      ),
  ],
  stations: base.stations,
  branches: [
    for (final branch in base.branches)
      LineBranch(
        lineId: branch.lineId,
        branch: branch.branch,
        startsAfter: branch.startsAfter,
        terminusAr: 'طرف فرع',
        terminusEn: 'Branch terminus',
      ),
  ],
  lineStations: base.lineStations,
  fares: [
    for (final fare in base.fares)
      FareBracket(
        maxStations: fare.maxStations,
        priceEgp: fare.priceEgp,
        ticketColor: 'green',
      ),
  ],
  snapshotDate: base.snapshotDate,
);

Future<String? Function()> _mockClipboard() async {
  String? copied;
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
    if (call.method == 'Clipboard.setData') {
      copied = (call.arguments as Map)['text'] as String?;
    }
    return null;
  });
  addTearDown(
    () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
  );
  return () => copied;
}

/// Wraps a screen with its Cubits and an Arabic MaterialApp by default.
Future<void> _pumpScreen(
  WidgetTester tester,
  Widget screen, {
  Locale locale = const Locale('ar'),
  Size size = const Size(360, 800),
  double textScale = 1,
  NetworkData? network,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues(<String, Object>{});
  final prefs = await SharedPreferences.getInstance();
  final settings = SettingsCubit(PreferencesSettingsRepository(prefs));
  await settings.setLocale(locale);

  final repo = _FakeNetworkRepository(network ?? buildFixtureNetwork());
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

    testWidgets('picker does not grab focus and leads on to the To field', (
      tester,
    ) async {
      await _pumpScreen(tester, const PlannerScreen());
      final l10n = AppLocalizations.of(
        tester.element(find.byType(PlannerScreen)),
      );
      await tester.tap(find.text(l10n.fromLabel));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).autofocus,
        isFalse,
      );

      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();
      final cubit = BlocProvider.of<PlannerCubit>(
        tester.element(find.byType(PlannerScreen)),
      );
      expect(cubit.state.from, isNotNull);
      expect(cubit.state.to, isNull);
      expect(find.text(l10n.toLabel), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });

    for (final entry in [
      (DateTime(2026, 1, 1, 2, 30), true),
      (DateTime(2026, 1, 1, 12, 0), false),
    ]) {
      testWidgets('advisory visibility follows the injected time', (
        tester,
      ) async {
        await _pumpScreen(tester, PlannerScreen(now: entry.$1));
        final l10n = AppLocalizations.of(
          tester.element(find.byType(PlannerScreen)),
        );
        expect(
          find.text(l10n.closedHoursAdvisory),
          entry.$2 ? findsOneWidget : findsNothing,
        );
        expect(
          find.byKey(const Key('plannerGreeting')),
          entry.$2 ? findsNothing : findsOneWidget,
        );
        expect(
          find.text(l10n.plannerHint),
          entry.$2 ? findsNothing : findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('opens the metro map from the header', (tester) async {
      await _pumpScreen(tester, const PlannerScreen());
      final l10n = AppLocalizations.of(
        tester.element(find.byType(PlannerScreen)),
      );
      await tester.tap(find.byTooltip(l10n.openMetroMap));
      await tester.pumpAndSettle();
      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('separates the From and To fields with a divider', (
      tester,
    ) async {
      await _pumpScreen(tester, const PlannerScreen());
      expect(find.byType(Divider), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps Show route disabled for identical stations', (
      tester,
    ) async {
      await _pumpScreen(tester, const PlannerScreen());
      final cubit = BlocProvider.of<PlannerCubit>(
        tester.element(find.byType(PlannerScreen)),
      );
      cubit.setPair(network.stationById('s1'), network.stationById('s1'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).enabled,
        isFalse,
      );
      expect(tester.takeException(), isNull);
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

    testWidgets('opens the zoomable metro map', (tester) async {
      await _pumpScreen(
        tester,
        LinesScreen(onStationSelected: (_, {required from}) {}),
      );
      final l10n = AppLocalizations.of(
        tester.element(find.byType(LinesScreen)),
      );
      expect(find.text(l10n.metroMap), findsOneWidget);
      await tester.tap(find.text(l10n.metroMap));
      await tester.pumpAndSettle();
      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows bidirectional terminus headers', (tester) async {
      await _pumpScreen(
        tester,
        LinesScreen(onStationSelected: (_, {required from}) {}),
        locale: const Locale('en'),
        network: _withTermini(network),
      );
      expect(
        find.text('Terminus A ↔ Terminus B'),
        findsNWidgets(network.lines.length),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('LibraryScreen', () {
    testWidgets('shows the empty state when nothing is stored', (tester) async {
      await _pumpScreen(tester, LibraryScreen(onOpenPlanner: () {}));
      expect(find.byType(TabBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps the clear-history action slightly inset', (
      tester,
    ) async {
      await _pumpScreen(tester, LibraryScreen(onOpenPlanner: () {}));
      final l10n = AppLocalizations.of(
        tester.element(find.byType(LibraryScreen)),
      );
      final inset = find.ancestor(
        of: find.byTooltip(l10n.clearHistory),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Padding &&
              widget.padding is EdgeInsetsDirectional &&
              (widget.padding as EdgeInsetsDirectional).end == AppSpace.sm,
        ),
      );
      expect(inset, findsOneWidget);
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

    testWidgets('shows version 1.0.7 in English', (tester) async {
      await _pumpScreen(
        tester,
        const SettingsScreen(),
        locale: const Locale('en'),
      );
      expect(find.textContaining('1.0.7'), findsOneWidget);
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

    testWidgets('shows direction and ticket color badge', (tester) async {
      await _pumpScreen(
        tester,
        RouteResultScreen(result: result, network: _withTermini(network)),
        locale: const Locale('en'),
      );
      expect(find.textContaining('Direction: Terminus'), findsWidgets);
      expect(find.textContaining('Green ticket'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows route context, next-stop cue and one chip per leg', (
      tester,
    ) async {
      await _pumpScreen(tester, screen, locale: const Locale('en'));
      expect(find.text('Station t1 → Station s4'), findsOneWidget);
      expect(find.text('1 stop (next station)'), findsOneWidget);
      expect(find.byType(LineChip), findsNWidgets(result.legs.length));
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows a deterministic estimated arrival', (tester) async {
      await _pumpScreen(
        tester,
        RouteResultScreen(
          result: result,
          network: network,
          now: DateTime(2026, 1, 1, 15, 2),
        ),
        locale: const Locale('en'),
      );
      expect(find.textContaining('Arrive ~3:17 PM'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('copies a localized trip summary', (tester) async {
      final copied = await _mockClipboard();
      await _pumpScreen(
        tester,
        RouteResultScreen(
          result: result,
          network: _withTermini(network),
          now: DateTime(2026, 1, 1, 15, 2),
        ),
        locale: const Locale('en'),
      );
      final l10n = AppLocalizations.of(
        tester.element(find.byType(RouteResultScreen)),
      );
      await tester.tap(find.byTooltip(l10n.copyTrip));
      await tester.pumpAndSettle();
      expect(copied(), contains('Station t1 → Station s4'));
      expect(copied(), contains('Terminus B'));
      expect(copied(), contains('Green ticket'));
      expect(find.text(l10n.routeCopied), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('reverse trip swaps the displayed endpoints', (tester) async {
      final copied = await _mockClipboard();
      await _pumpScreen(tester, screen, locale: const Locale('en'));
      final l10n = AppLocalizations.of(
        tester.element(find.byType(RouteResultScreen)),
      );
      await tester.drag(find.byType(ListView), const Offset(0, -1000));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.reverseTrip));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(l10n.copyTrip));
      await tester.pumpAndSettle();
      expect(copied(), startsWith('Station s4 → Station t1'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('checks off an intermediate stop and toggles it back', (
      tester,
    ) async {
      await _pumpScreen(tester, screen, locale: const Locale('en'));
      final l10n = AppLocalizations.of(
        tester.element(find.byType(RouteResultScreen)),
      );
      final semantics = tester.ensureSemantics();
      await tester.tap(find.byType(ExpansionTile).first);
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel(l10n.stopUpcoming), findsOneWidget);
      await tester.tap(find.bySemanticsLabel(l10n.stopUpcoming));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel(l10n.stopPassed), findsOneWidget);
      await tester.tap(find.bySemanticsLabel(l10n.stopPassed));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel(l10n.stopUpcoming), findsOneWidget);
      expect(tester.takeException(), isNull);
      semantics.dispose();
    });

    testWidgets('leaves gesture-bar clearance below the list', (tester) async {
      await _pumpScreen(tester, screen);
      final padding =
          tester.widget<ListView>(find.byType(ListView)).padding
              as EdgeInsetsDirectional;
      expect(padding.bottom, greaterThanOrEqualTo(16));
      expect(tester.takeException(), isNull);
    });

    for (final locale in [const Locale('ar'), const Locale('en')]) {
      testWidgets(
        'keeps the duration and its unit on one line in ${locale.languageCode}',
        (tester) async {
          await _pumpScreen(tester, screen, locale: locale, textScale: 1.5);
          final l10n = AppLocalizations.of(
            tester.element(find.byType(RouteResultScreen)),
          );
          final row = find.ancestor(
            of: find.byType(CountUp),
            matching: find.byType(Row),
          );
          expect(row, findsOneWidget);
          final rowWidget = tester.widget<Row>(row);
          expect(rowWidget.crossAxisAlignment, CrossAxisAlignment.baseline);
          expect(rowWidget.textBaseline, TextBaseline.alphabetic);
          expect(
            find.descendant(of: row, matching: find.text(l10n.minutesShort)),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }

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
