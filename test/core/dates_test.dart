import 'package:flutter_test/flutter_test.dart';

import 'package:maak_metro/core/utils/dates.dart';

void main() {
  test('isMetroClosed covers 12:15 AM up to 5:15 AM', () {
    final cases = [
      ((hour: 0, minute: 14), false),
      ((hour: 0, minute: 15), true),
      ((hour: 3, minute: 0), true),
      ((hour: 5, minute: 14), true),
      ((hour: 5, minute: 15), false),
      ((hour: 12, minute: 0), false),
    ];
    for (final (time, expected) in cases) {
      expect(
        isMetroClosed(now: DateTime(2026, 11, 26, time.hour, time.minute)),
        expected,
        reason: '${time.hour}:${time.minute}',
      );
    }
  });
}
