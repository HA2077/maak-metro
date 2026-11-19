import 'package:maak_metro/core/l10n/app_localizations.dart';

/// Figures (3-12-2026) or the month written out (3 ديسمبر 2026).
enum DateStyle { numeric, written }

/// Month names in the UI language, January first.
String monthName(AppLocalizations l10n, int month) => switch (month) {
  1 => l10n.monthJan,
  2 => l10n.monthFeb,
  3 => l10n.monthMar,
  4 => l10n.monthApr,
  5 => l10n.monthMay,
  6 => l10n.monthJun,
  7 => l10n.monthJul,
  8 => l10n.monthAug,
  9 => l10n.monthSep,
  10 => l10n.monthOct,
  11 => l10n.monthNov,
  12 => l10n.monthDec,
  _ => '$month',
};

/// Splits an ISO date into day, month and year. Null when it is not one.
({int day, int month, int year})? splitIsoDate(String isoDate) {
  final parts = isoDate.split('-');
  if (parts.length != 3) return null;
  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);
  if (year == null || month == null || day == null) return null;
  if (month < 1 || month > 12) return null;
  return (day: day, month: month, year: year);
}
