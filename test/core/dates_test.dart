import 'package:flutter_test/flutter_test.dart';
import 'package:maak_metro/core/utils/dates.dart';

void main() {
  test('ISO dates read day first', () {
    expect(dayFirstDate('2026-03-27'), '27-03-2026');
    expect(dayFirstDate('2026-11-18'), '18-11-2026');
  });

  test('a value that is not three parts is left alone', () {
    expect(dayFirstDate(''), '');
    expect(dayFirstDate('2026-03'), '2026-03');
    expect(dayFirstDate('unknown'), 'unknown');
  });
}
