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
  testWidgets('the old tab is gone before the new one appears', (tester) async {
    await tester.pumpWidget(_app(0));
    expect(find.text('planner'), findsOneWidget);
    expect(find.text('lines'), findsNothing);

    await tester.pumpWidget(_app(1));
    await tester.pump(const Duration(milliseconds: 60));

    // Leaving tab is fading out, incoming is still fully transparent: the two
    // are never visibly composited on top of each other.
    expect(_opacityOf(tester, 'planner'), lessThan(1));
    expect(_opacityOf(tester, 'lines'), 0);

    await tester.pump(const Duration(milliseconds: 120));
    expect(_opacityOf(tester, 'lines'), greaterThan(0));

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
