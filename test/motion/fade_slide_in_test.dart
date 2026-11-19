import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maak_metro/core/motion/fade_slide_in.dart';

void main() {
  testWidgets('enters from transparent and settles fully visible', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: FadeSlideIn(child: Text('station'))),
      ),
    );

    final opacity = tester.widget<Opacity>(
      find.ancestor(of: find.text('station'), matching: find.byType(Opacity)),
    );
    expect(opacity.opacity, 0);

    await tester.pumpAndSettle();
    final settled = tester.widget<Opacity>(
      find.ancestor(of: find.text('station'), matching: find.byType(Opacity)),
    );
    expect(settled.opacity, 1);
  });

  testWidgets('reduced motion shows the child immediately', (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          home: Scaffold(body: FadeSlideIn(index: 3, child: Text('station'))),
        ),
      ),
    );

    final opacity = tester.widget<Opacity>(
      find.ancestor(of: find.text('station'), matching: find.byType(Opacity)),
    );
    expect(opacity.opacity, 1);
  });
}
