import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:maak_metro/core/theme/app_theme.dart';

double _contrast(Color a, Color b) {
  final first = a.computeLuminance();
  final second = b.computeLuminance();
  final lighter = first > second ? first : second;
  final darker = first > second ? second : first;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('AppTheme.ticketBadge', () {
    test('uses the light and dark fill pairs with readable foregrounds', () {
      for (final entry in AppTheme.ticketFills.entries) {
        for (final brightness in Brightness.values) {
          final badge = AppTheme.ticketBadge(entry.key, brightness);
          expect(
            badge.background,
            brightness == Brightness.light
                ? entry.value.light
                : entry.value.dark,
            reason: entry.key,
          );
          expect(
            _contrast(badge.background, badge.foreground),
            greaterThanOrEqualTo(4.5),
            reason: entry.key,
          );
        }
      }
    });

    test('falls back to the yellow tier for an unknown key', () {
      expect(
        AppTheme.ticketBadge('unknown', Brightness.light).background,
        AppTheme.ticketFills['yellow']!.light,
      );
    });
  });
}
