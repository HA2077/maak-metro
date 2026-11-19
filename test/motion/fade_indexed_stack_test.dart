import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maak_metro/core/motion/fade_indexed_stack.dart';

Widget _app(int index) => MaterialApp(
  home: FadeIndexedStack(
    index: index,
    children: const [
      Center(child: Text('planner')),
      Center(child: Text('lines')),
      Center(child: Text('library')),
      Center(child: Text('settings')),
    ],
  ),
);

double _opacityOf(WidgetTester tester, String label) {
  final transition = tester.widget<FadeTransition>(
    find
        .ancestor(of: find.text(label), matching: find.byType(FadeTransition))
        .first,
  );
  return transition.opacity.value;
}

void main() {
  testWidgets('tabs cross-dissolve, so neither a blank frame nor a stuck tab', (
    tester,
  ) async {
    await tester.pumpWidget(_app(0));
    expect(find.text('planner'), findsOneWidget);
    expect(find.text('lines'), findsNothing);

    await tester.pumpWidget(_app(1));
    await tester.pump(const Duration(milliseconds: 60));

    // Both are already moving: the old tab is never left at full opacity, and
    // the new one is on screen before the old one is gone.
    final leaving = _opacityOf(tester, 'planner');
    final arriving = _opacityOf(tester, 'lines');
    expect(leaving, greaterThan(0));
    expect(leaving, lessThan(1));
    expect(arriving, greaterThan(0));
    expect(arriving, lessThan(1));

    await tester.pumpAndSettle();
    expect(find.text('planner'), findsNothing);
    expect(find.text('lines'), findsOneWidget);
  });

  testWidgets('reduced motion swaps without a fade', (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          home: FadeIndexedStack(
            index: 0,
            children: [Text('planner'), Text('lines')],
          ),
        ),
      ),
    );

    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          home: FadeIndexedStack(
            index: 1,
            children: [Text('planner'), Text('lines')],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('planner'), findsNothing);
    expect(find.text('lines'), findsOneWidget);
  });
}
