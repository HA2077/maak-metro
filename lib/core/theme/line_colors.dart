import 'package:flutter/material.dart';

/// Used when a line row carries a colour we cannot read. Neutral, never throws.
const Color unknownLineColor = Color(0xFF6B7280);

/// Reads a `#RRGGBB` colour from the database. The `#` is optional and hex
/// digits may be lower case. Anything else returns [unknownLineColor] so one
/// bad row cannot crash a screen.
Color parseHexColor(String hex) {
  var value = hex.trim();
  if (value.startsWith('#')) {
    value = value.substring(1);
  }
  if (value.length != 6) {
    return unknownLineColor;
  }
  final rgb = int.tryParse(value, radix: 16);
  if (rgb == null) {
    return unknownLineColor;
  }
  return Color(0xFF000000 | rgb);
}

/// Black or white, whichever reads better on [background] (WCAG contrast).
Color lineTextColor(Color background) {
  final luminance = background.computeLuminance();
  final contrastWithWhite = 1.05 / (luminance + 0.05);
  final contrastWithBlack = (luminance + 0.05) / 0.05;
  return contrastWithBlack >= contrastWithWhite ? Colors.black : Colors.white;
}
