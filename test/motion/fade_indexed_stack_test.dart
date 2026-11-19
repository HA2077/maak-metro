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

void main() {
  testWidgets('both tabs paint during the fade, only the new one after', (
    tester,
  ) async {
    await tester.pumpWidget(_app(0));
    expect(find.text('planner'), findsOneWidget);
    expect(find.text('lines'), findsNothing);

    await tester.pumpWidget(_app(1));
    await tester.pump(const Duration(milliseconds: 80));
    expect(find.text('planner'), findsOneWidget);
    expect(find.text('lines'), findsOneWidget);

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
