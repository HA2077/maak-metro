import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maak_metro/core/motion/app_motion.dart';

void main() {
  testWidgets('reduced motion collapses durations and stagger', (tester) async {
    late Duration duration;
    late Duration delay;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Builder(
          builder: (context) {
            duration = AppMotion.of(context, AppMotion.slow);
            delay = AppMotion.delayFor(context, 4);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(duration, Duration.zero);
    expect(delay, Duration.zero);
  });

  testWidgets('without reduced motion the tokens apply', (tester) async {
    late Duration duration;
    late Duration delay;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(),
        child: Builder(
          builder: (context) {
            duration = AppMotion.of(context, AppMotion.slow);
            delay = AppMotion.delayFor(context, 4);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(duration, AppMotion.slow);
    expect(delay, AppMotion.stagger * 4);
  });
}
