import 'package:flutter/widgets.dart';

const Map<String, String> _arabicDigits = {
  '0': '٠',
  '1': '١',
  '2': '٢',
  '3': '٣',
  '4': '٤',
  '5': '٥',
  '6': '٦',
  '7': '٧',
  '8': '٨',
  '9': '٩',
  '.': '٫',
};

/// 12.5 becomes ١٢٫٥. Egyptian metro signage and the Arabic UI both use
/// Arabic-Indic digits, with the Arabic decimal separator.
String arabicDigits(String text) => text.replaceAllMapped(
  RegExp('[0-9.]'),
  (match) => _arabicDigits[match[0]]!,
);

/// Applies [arabicDigits] only when the UI is actually in Arabic, so the
/// English translation keeps Latin digits.
String localizedDigits(BuildContext context, String text) =>
    Localizations.localeOf(context).languageCode == 'ar'
    ? arabicDigits(text)
    : text;
