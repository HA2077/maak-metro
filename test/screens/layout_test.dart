import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maak_metro/screens/home_shell.dart';
import 'package:maak_metro/screens/route_result_screen.dart';

import '../support/pump_screen.dart';
import '../support/sample_network.dart';

void main() {
  testWidgets('every tab holds at 360dp with 1.5x text', (tester) async {
    await pumpScreen(
      tester,
      screen: const HomeShell(),
      size: const Size(360, 800),
      textScale: 1.5,
    );

    for (final icon in [
      Icons.subway_outlined,
      Icons.bookmark_border,
      Icons.settings_outlined,
      Icons.alt_route,
    ]) {
      await tester.tap(find.byIcon(icon));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('the result screen holds at 360dp with 1.5x text', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      screen: const RouteResultScreen(),
      result: sampleResult(),
      size: const Size(360, 800),
      textScale: 1.5,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('a wide window uses the rail and a bounded column', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      screen: const HomeShell(),
      size: const Size(1024, 800),
    );

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
