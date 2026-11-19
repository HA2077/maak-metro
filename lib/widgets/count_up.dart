import 'package:flutter/material.dart';
import 'package:maak_metro/core/motion/app_motion.dart';

/// Animates a number from zero to [value] on first build. Wrap it in a static
/// [Semantics] label: screen readers should hear the final number once, not
/// every frame of the count.
class CountUp extends StatelessWidget {
  const CountUp({
    super.key,
    required this.value,
    required this.text,
    this.style,
    this.textAlign,
  });

  final double value;

  /// Formats the in-between value.
  final String Function(double value) text;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: AppMotion.of(context, AppMotion.slow),
      curve: AppMotion.decelerate,
      builder: (context, animated, _) =>
          Text(text(animated), style: style, textAlign: textAlign),
    );
  }
}
