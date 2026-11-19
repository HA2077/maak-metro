import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maak_metro/core/l10n/app_localizations.dart';
import 'package:maak_metro/core/utils/greeting.dart';
import 'package:maak_metro/screens/planner_screen.dart';

import '../support/pump_screen.dart';

void main() {
  test('the parts of the day meet where they should', () {
    expect(dayPartFor(5), DayPart.morning);
    expect(dayPartFor(11), DayPart.morning);
    expect(dayPartFor(12), DayPart.afternoon);
    expect(dayPartFor(16), DayPart.afternoon);
    expect(dayPartFor(17), DayPart.evening);
    expect(dayPartFor(21), DayPart.evening);
    expect(dayPartFor(22), DayPart.night);
    expect(dayPartFor(0), DayPart.night);
    expect(dayPartFor(4), DayPart.night);
  });

  testWidgets('each part of the day offers four different greetings', (
    tester,
  ) async {
    await pumpScreen(tester, screen: const PlannerScreen());

    final l10n = AppLocalizations.of(
      tester.element(find.byType(PlannerScreen)),
    );
    for (final part in DayPart.values) {
      final options = greetingsFor(l10n, part);
      expect(options.length, 4, reason: '$part');
      expect(options.toSet().length, 4, reason: '$part has no repeats');
    }
  });

  testWidgets('the planner greets with one of the greetings for this hour', (
    tester,
  ) async {
    await pumpScreen(tester, screen: const PlannerScreen());

    final context = tester.element(find.byType(PlannerScreen));
    final options = greetingsFor(
      AppLocalizations.of(context),
      dayPartFor(DateTime.now().hour),
    );
    final greeting = tester
        .widget<Text>(find.byKey(const Key('plannerGreeting')))
        .data;

    expect(options, contains(greeting));
  });
}
