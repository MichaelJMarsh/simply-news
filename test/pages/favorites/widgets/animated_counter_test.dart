import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:simply_news/presentation/pages/favorites/widgets/animated_counted.dart';

void main() {
  group('AnimatedCounter', () {
    testWidgets('renders with initial value of 0 and animates to given value', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AnimatedCounter(10))),
      );

      // Verify that the initial value is displayed.
      expect(find.text('0.0'), findsOneWidget);

      await tester.pumpAndSettle();

      // Verify that the counter animates to the final value.
      expect(find.text('10.0'), findsOneWidget);
    });

    testWidgets('applies provided text style', (WidgetTester tester) async {
      const textStyle = TextStyle(fontSize: 24, fontWeight: FontWeight.bold);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AnimatedCounter(5, style: textStyle)),
        ),
      );

      final textFinder = find.byType(Text);
      expect(textFinder, findsOneWidget);

      final Text textWidget = tester.widget<Text>(textFinder);

      // Verify that the text style is applied.
      expect(textWidget.style, equals(textStyle));
    });

    testWidgets('uses provided animation curve and duration', (
      WidgetTester tester,
    ) async {
      const duration = Duration(seconds: 1);
      const curve = Curves.bounceOut;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedCounter(8, duration: duration, curve: curve),
          ),
        ),
      );

      final tweenFinder = find.byType(TweenAnimationBuilder<num>);
      expect(tweenFinder, findsOneWidget);

      final TweenAnimationBuilder<num> tweenWidget = tester
          .widget<TweenAnimationBuilder<num>>(tweenFinder);

      // Verify that the provided duration and curve are used.
      expect(tweenWidget.duration, equals(duration));
      expect(tweenWidget.curve, equals(curve));
    });

    testWidgets('asserts that value is greater than or equal to 0', (
      WidgetTester tester,
    ) async {
      // Verify that an assertion is thrown when the value is negative.
      expect(() => AnimatedCounter(-1), throwsA(isA<AssertionError>()));
    });
  });
}
