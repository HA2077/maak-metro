import 'package:flutter_test/flutter_test.dart';
import 'package:maak_metro/core/utils/arabic_normalize.dart';

void main() {
  group('normalizeSearch', () {
    test('lowercases Latin and trims', () {
      expect(normalizeSearch('  El Shohada  '), 'el shohada');
      expect(normalizeSearch('SADAT'), 'sadat');
    });

    test('collapses internal whitespace', () {
      expect(normalizeSearch('el    shohada'), 'el shohada');
      expect(normalizeSearch('a\t\nb'), 'a b');
    });

    test('removes Arabic diacritics', () {
      expect(normalizeSearch('الشُّهَدَاء'), normalizeSearch('الشهداء'));
      expect(normalizeSearch('سُكُون'), 'سكون');
    });

    test('removes tatweel', () {
      expect(normalizeSearch('الـــشهداء'), 'الشهداء');
    });

    test('unifies alef forms', () {
      const expected = 'احمد';
      expect(normalizeSearch('أحمد'), expected);
      expect(normalizeSearch('إحمد'), expected);
      expect(normalizeSearch('آحمد'), expected);
      expect(normalizeSearch('ٱحمد'), expected);
    });

    test('unifies ta marbuta to ha', () {
      expect(normalizeSearch('محطة'), normalizeSearch('محطه'));
    });

    test('unifies alef maqsura to ya', () {
      expect(normalizeSearch('مصطفي'), normalizeSearch('مصطفى'));
    });

    test('keeps standalone hamza distinct', () {
      // ء on its own is kept; only the alef carriers are unified.
      expect(normalizeSearch('مسءول'), isNot(normalizeSearch('مسوول')));
      // ئ and ؤ are kept as separate letters.
      expect(normalizeSearch('شئ'), isNot(normalizeSearch('شي')));
      expect(normalizeSearch('مؤ'), isNot(normalizeSearch('مو')));
    });

    test('alef with hamza on a word is unified, as documented', () {
      // "خطأ" ends in أ, which is an alef carrier, so it becomes ا.
      expect(normalizeSearch('خطأ'), 'خطا');
    });

    test('leaves digits and Latin punctuation alone', () {
      expect(normalizeSearch('Line 3'), 'line 3');
      expect(normalizeSearch('2026-03-27'), '2026-03-27');
    });

    test('empty and whitespace-only input become empty', () {
      expect(normalizeSearch(''), '');
      expect(normalizeSearch('   '), '');
    });
  });

  group('stationMatchesQuery', () {
    test('empty query matches everything', () {
      expect(stationMatchesQuery('الشهداء', ''), isTrue);
    });

    test('matches with or without hamza and tashkeel', () {
      expect(stationMatchesQuery('الشهداء', 'الشُّهَدَاء'), isTrue);
      expect(stationMatchesQuery('الشهداء', 'الشهداء'), isTrue);
    });

    test('matches an Arabic prefix', () {
      expect(stationMatchesQuery('محطة الشهداء', 'الشهد'), isTrue);
    });

    test('matches English regardless of case', () {
      expect(stationMatchesQuery('El Shohada', 'shohada'), isTrue);
      expect(stationMatchesQuery('El Shohada', 'EL SHO'), isTrue);
    });

    test('rejects an unrelated query', () {
      expect(stationMatchesQuery('الشهداء', 'المعادي'), isFalse);
    });

    test('ta marbuta and ha are interchangeable', () {
      expect(stationMatchesQuery('محطه', 'محطة'), isTrue);
    });

    test('alef maqsura and ya are interchangeable', () {
      expect(stationMatchesQuery('مصطفى', 'مصطفي'), isTrue);
    });
  });
}
