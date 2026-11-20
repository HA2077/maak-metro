import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, Object?> _arb(String language) =>
    jsonDecode(File('lib/core/l10n/app_$language.arb').readAsStringSync())
        as Map<String, Object?>;

Set<String> _keys(Map<String, Object?> arb) =>
    arb.keys.where((key) => !key.startsWith('@')).toSet();

void main() {
  test('Arabic and English define exactly the same keys', () {
    expect(_keys(_arb('ar')), _keys(_arb('en')));
  });

  test('every placeholder used in a message is declared', () {
    final arb = _arb('ar');
    for (final key in _keys(arb)) {
      final message = arb[key]! as String;
      final meta = arb['@$key'] as Map<String, Object?>?;
      final declared =
          (meta?['placeholders'] as Map<String, Object?>?)?.keys.toSet() ??
          const <String>{};
      final used = {
        for (final match in RegExp(r'\{(\w+)').allMatches(message))
          match.group(1)!,
      };
      expect(declared, used, reason: key);
    }
  });
}
