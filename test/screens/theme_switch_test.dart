import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maak_metro/screens/home_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/pump_screen.dart';

void main() {
  testWidgets('choosing Dark switches the app theme', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await pumpScreen(tester, screen: const HomeShell());

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('غامق'));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(Scaffold).first);
    expect(Theme.of(context).brightness, Brightness.dark);
  });
}
