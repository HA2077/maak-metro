import 'package:flutter/material.dart';
import 'package:maak_metro/core/l10n/app_localizations.dart';
import 'package:maak_metro/core/utils/dates.dart';
import 'package:maak_metro/core/utils/digits.dart';
import 'package:maak_metro/providers/settings_provider.dart';
import 'package:provider/provider.dart';

/// A date in the format picked in settings: figures with the day first, or the
/// month written out. Both read day, month, year in the reader's direction.
class DateText extends StatelessWidget {
  const DateText(this.isoDate, {super.key, this.style});

  final String isoDate;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolved =
        style ??
        theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600);
    final date = splitIsoDate(isoDate);
    if (date == null) return Text(isoDate, style: resolved);

    final l10n = AppLocalizations.of(context);
    final written =
        context.watch<SettingsProvider>().dateStyle == DateStyle.written;

    if (written) {
      // Words between the numbers keep bidi from reordering them, so one text
      // is enough here.
      return Text(
        '${localizedDigits(context, '${date.day}')} '
        '${monthName(l10n, date.month)} '
        '${localizedDigits(context, '${date.year}')}',
        style: resolved,
      );
    }

    // Figures: one text per field, because Arabic-Indic numbers form a single
    // right-to-left run and bidi would flip the fields inside one string.
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: arabic ? TextDirection.rtl : TextDirection.ltr,
      children: [
        Text(localizedDigits(context, '${date.day}'), style: resolved),
        Text('-', style: resolved),
        Text(localizedDigits(context, '${date.month}'), style: resolved),
        Text('-', style: resolved),
        Text(localizedDigits(context, '${date.year}'), style: resolved),
      ],
    );
  }
}
