import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maak_metro/screens/lines_screen.dart';
import 'package:maak_metro/screens/metro_map_screen.dart';

import '../support/pump_screen.dart';

void main() {
  testWidgets('tapping a line lights it up and tapping again clears', (
    tester,
  ) async {
    await pumpScreen(tester, screen: const MetroMapScreen());

    expect(find.byType(ChoiceChip), findsNWidgets(3));

    ChoiceChip chip(int index) =>
        tester.widget<ChoiceChip>(find.byType(ChoiceChip).at(index));

    await tester.tap(find.text('الخط الثاني'));
    await tester.pump(const Duration(milliseconds: 200));

    expect(chip(1).selected, isTrue);
    expect(chip(0).selected, isFalse);
    expect(chip(2).selected, isFalse);

    await tester.tap(find.text('الخط الثاني'));
    await tester.pump(const Duration(milliseconds: 200));

    expect(chip(1).selected, isFalse);
  });

  testWidgets('the map opens from a button on the lines tab', (tester) async {
    await pumpScreen(tester, screen: const LinesScreen());

    await tester.tap(find.text('خريطة المترو'));
    await tester.pumpAndSettle();

    expect(find.byType(MetroMapScreen), findsOneWidget);
  });

  testWidgets('the whole network is drawn inside the viewport', (tester) async {
    await pumpScreen(tester, screen: const MetroMapScreen());

    final viewer = find.byType(InteractiveViewer);
    expect(viewer, findsOneWidget);
    expect(tester.getSize(viewer).width, greaterThan(0));
    expect(find.byType(CustomPaint), findsWidgets);
  });
}
