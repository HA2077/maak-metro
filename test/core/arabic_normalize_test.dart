import 'package:flutter_test/flutter_test.dart';
import 'package:maak_metro/core/utils/arabic_normalize.dart';

void main() {
  test('folds alef forms, ta marbuta and alef maqsura', () {
    expect(normalizeSearch('الأهرام'), normalizeSearch('الاهرام'));
    expect(normalizeSearch('إمبابة'), normalizeSearch('امبابه'));
    expect(normalizeSearch('آخر'), 'اخر');
    expect(normalizeSearch('دار السلام'), 'دار السلام');
    expect(normalizeSearch('مصطفى'), 'مصطفي');
  });

  test('drops diacritics and tatweel', () {
    expect(normalizeSearch('الـسـادات'), 'السادات');
    expect(normalizeSearch('السَّادات'), 'السادات');
  });

  test('lower cases, trims and collapses whitespace', () {
    expect(normalizeSearch('  Sadat   Station '), 'sadat station');
  });

  test('keeps a pure English query readable', () {
    expect(normalizeSearch('Kit Kat'), 'kit kat');
  });
}
