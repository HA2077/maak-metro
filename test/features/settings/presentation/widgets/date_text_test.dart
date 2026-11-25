import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:maak_metro/core/utils/dates.dart';
import 'package:maak_metro/core/utils/digits.dart';
import 'package:maak_metro/features/settings/presentation/widgets/date_text.dart';

class _Localized extends StatelessWidget {
  const _Localized(this.locale, this.child);

  final Locale locale;
  final Widget child;

  @override
  Widget build(BuildContext context) => Localizations.override(
    context: context,
    locale: locale,
    child: Builder(builder: (context) => child),
  );
}

void main() {
  test('Latin figures become Arabic-Indic, with the Arabic separator', () {
    expect(arabicDigits('27.5'), '٢٧٫٥');
    expect(arabicDigits('12 جنيه'), '١٢ جنيه');
  });

  test('splitIsoDate reads day first and rejects junk', () {
    expect(splitIsoDate('2026-03-27'), (day: 27, month: 3, year: 2026));
    expect(splitIsoDate('2026-13-01'), isNull);
    expect(splitIsoDate('not a date'), isNull);
  });

  testWidgets('an Arabic date reads day first in Arabic figures', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: _Localized(Locale('ar'), DateText('2026-03-27'))),
    );

    // No zero padding: March is ٣, not ٠٣.
    expect(find.text('٢٧'), findsOneWidget);
    expect(find.text('٣'), findsOneWidget);
    expect(find.text('٢٠٢٦'), findsOneWidget);
  });

  testWidgets('an English date keeps Latin figures', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: _Localized(Locale('en'), DateText('2026-03-27'))),
    );

    expect(find.text('27'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('2026'), findsOneWidget);
  });
}
