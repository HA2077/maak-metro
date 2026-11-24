import 'package:flutter/material.dart';
import 'package:maak_metro/core/theme/app_theme.dart';
import 'package:maak_metro/core/theme/line_colors.dart';
import 'package:maak_metro/domain/domain.dart';

/// A small coloured pill naming a metro line.
///
/// The colour comes from the database (`color_hex`), and the label colour is
/// picked for contrast by [lineTextColor] so the chip stays readable on every
/// line colour, including a pale one.
class LineChip extends StatelessWidget {
  const LineChip({super.key, required this.line});

  final Line line;

  @override
  Widget build(BuildContext context) {
    final background = parseHexColor(line.colorHex);
    final foreground = lineTextColor(background);
    final language = Localizations.localeOf(context).languageCode;

    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpace.md,
        vertical: AppSpace.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.field),
      ),
      child: Text(
        line.localizedName(language),
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: foreground, fontWeight: FontWeight.w700),
      ),
    );
  }
}
