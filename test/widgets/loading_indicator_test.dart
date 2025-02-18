import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:simply_news/presentation/widgets/src/loading_indicator.dart';

void main() {
  group('LoadingIndicator', () {
    testWidgets('renders a CircularProgressIndicator', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoadingIndicator())),
      );

      // Verify that a CircularProgressIndicator is rendered.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
      'CircularProgressIndicator has correct strokeCap and strokeWidth',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: LoadingIndicator())),
        );

        // Find the CircularProgressIndicator widget.
        final finder = find.byType(CircularProgressIndicator);
        expect(finder, findsOneWidget);

        // Extract the widget and verify its properties.
        final CircularProgressIndicator progressIndicator = tester
            .widget<CircularProgressIndicator>(finder);

        // Verify that the CircularProgressIndicator has the correct properties.
        expect(progressIndicator.strokeCap, equals(StrokeCap.round));
        expect(progressIndicator.strokeWidth, equals(8));
      },
    );
  });
}
