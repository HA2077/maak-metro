import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maak_metro/domain/models/metro_models.dart';
import 'package:maak_metro/screens/planner_screen.dart';

import '../support/pump_screen.dart';

void main() {
  testWidgets(
    'an empty network explains itself instead of showing a dead form',
    (tester) async {
      await pumpScreen(
        tester,
        screen: const PlannerScreen(),
        network: NetworkData.empty,
      );

      expect(find.text('بيانات الشبكة لم تُحمَّل بعد'), findsOneWidget);
      expect(find.text('إعادة المحاولة'), findsOneWidget);
      expect(find.text('اعرض المسار'), findsNothing);
    },
  );

  testWidgets('interchange chips fill both stations', (tester) async {
    await pumpScreen(tester, screen: const PlannerScreen());

    expect(find.text('محطات التبديل'), findsOneWidget);

    final action = tester.widget<FilledButton>(find.byType(FilledButton).first);
    expect(action.onPressed, isNull);

    await tester.tap(find.text('العتبة').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('ناصر').first);
    await tester.pumpAndSettle();

    final enabled = tester.widget<FilledButton>(
      find.byType(FilledButton).first,
    );
    expect(enabled.onPressed, isNotNull);
  });
}
