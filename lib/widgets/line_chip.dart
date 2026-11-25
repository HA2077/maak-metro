import 'package:flutter/material.dart';
import 'package:maak_metro/core/theme/line_colors.dart';
import 'package:maak_metro/core/utils/localized_names.dart';
import 'package:maak_metro/domain/domain.dart';

/// Line name on the line's own colour, with the text colour picked for
/// contrast.
class LineChip extends StatelessWidget {
  const LineChip({super.key, required this.line});

  final Line line;

  @override
  Widget build(BuildContext context) {
    final color = parseHexColor(line.colorHex);
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        lineName(context, line),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: lineTextColor(color),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
