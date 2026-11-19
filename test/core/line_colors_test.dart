import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maak_metro/core/theme/line_colors.dart';

void main() {
  group('parseHexColor', () {
    test('reads #RRGGBB', () {
      expect(parseHexColor('#1E63B8'), const Color(0xFF1E63B8));
    });

    test('accepts lower case and a missing #', () {
      expect(parseHexColor('#1e63b8'), const Color(0xFF1E63B8));
      expect(parseHexColor('1E63B8'), const Color(0xFF1E63B8));
    });

    test('returns the neutral colour for anything unreadable', () {
      for (final input in ['', 'red', '#12345', '#1234567', '#GGGGGG', ' ']) {
        expect(
          parseHexColor(input),
          unknownLineColor,
          reason: 'input: "$input"',
        );
      }
    });
  });

  group('lineTextColor', () {
    test('white on dark line colours', () {
      expect(lineTextColor(parseHexColor('#1E63B8')), Colors.white);
      expect(lineTextColor(parseHexColor('#D01F2F')), Colors.white);
    });

    test('black on light line colours', () {
      expect(lineTextColor(parseHexColor('#F5C518')), Colors.black);
      expect(lineTextColor(parseHexColor('#FFFFFF')), Colors.black);
    });
  });
}
