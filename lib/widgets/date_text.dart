import 'package:flutter/material.dart';
import 'package:maak_metro/core/utils/dates.dart';
import 'package:maak_metro/core/utils/digits.dart';

/// A date from the seed, day first, in the reader's direction.
///
/// The three fields are separate texts on purpose: Arabic-Indic figures form a
/// single right-to-left run, so one string would be reordered by bidi and read
/// year first. No zero padding — an Arabic zero is a dot, so ٢٧-٣-٢٠٢٦.
class DateText extends StatelessWidget {
  const DateText(this.isoDate, {super.key, this.style});

  final String isoDate;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolved =
        style ??
        theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600);
    final date = splitIsoDate(isoDate);
    if (date == null) return Text(isoDate, style: resolved);

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
