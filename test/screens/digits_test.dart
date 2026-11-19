import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maak_metro/core/utils/digits.dart';
import 'package:maak_metro/screens/route_result_screen.dart';
import 'package:maak_metro/screens/settings_screen.dart';

import '../support/pump_screen.dart';
import '../support/sample_network.dart';

class _Localized extends StatelessWidget {
  const _Localized(this.locale, this.text);

  final Locale locale;
  final String text;

  @override
  Widget build(BuildContext context) => Localizations.override(
    context: context,
    locale: locale,
    child: Builder(builder: (context) => Text(localizedDigits(context, text))),
  );
}

void main() {
  test('Latin figures become Arabic-Indic, with the Arabic separator', () {
    expect(arabicDigits('27.5'), '٢٧٫٥');
    expect(arabicDigits('12 جنيه'), '١٢ جنيه');
    expect(arabicDigits('2026-03-27'), '٢٠٢٦-٠٣-٢٧');
  });

  testWidgets('English keeps Latin figures', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: _Localized(Locale('en'), '27.5 minutes')),
    );
    expect(find.text('27.5 minutes'), findsOneWidget);
  });

  testWidgets('the about card reads dates day first in Arabic figures', (
    tester,
  ) async {
    await pumpScreen(tester, screen: const SettingsScreen());

    expect(find.text('معاك'), findsOneWidget);
    expect(find.text('الإصدار 1.0.0'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('تاريخ البيانات'), findsOneWidget);
    expect(find.text('سريان الأجرة'), findsOneWidget);
    // Day, month, year as separate runs: bidi would flip them in one string.
    // No zero padding, so March is ٣ rather than ٠٣.
    for (final part in ['١٨', '١١', '٢٧', '٣']) {
      expect(find.text(part), findsOneWidget, reason: part);
    }
    expect(find.text('٢٠٢٦'), findsNWidgets(2));
  });

  testWidgets('the result screen reads in Arabic figures', (tester) async {
    await pumpScreen(
      tester,
      screen: const RouteResultScreen(),
      result: sampleResult(),
    );

    expect(find.text('الوقت التقديري ٢٧٫٥ دقيقة'), findsOneWidget);
    expect(find.text('٥ محطات'), findsOneWidget);
    expect(find.text('تغييران'), findsOneWidget);
    expect(find.text('١٢ جنيه'), findsOneWidget);
  });
}
