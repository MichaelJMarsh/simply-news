import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:simply_news/presentation/widgets/src/loading_indicator.dart';
import 'package:simply_news/presentation/widgets/src/loading_layout.dart';

void main() {
  group('LoadingLayout', () {
    testWidgets('renders message and LoadingIndicator', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LoadingLayout(message: Text('Loading...'))),
        ),
      );

      // Verify that the test message is rendered.
      expect(find.text('Loading...'), findsOneWidget);

      // Verify that the LoadingIndicator is rendered.
      expect(find.byType(LoadingIndicator), findsOneWidget);
    });

    testWidgets(
      'uses the correct spacing between the message and the LoadingIndicator',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: LoadingLayout(message: Text('Loading data...')),
            ),
          ),
        );

        // Verify that a SizedBox with height 24 is rendered.
        final sizedBoxFinder = find.byWidgetPredicate(
          (widget) => widget is SizedBox && widget.height == 24,
        );
        expect(sizedBoxFinder, findsOneWidget);
      },
    );

    testWidgets('centers the content along the main axis of a Column', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LoadingLayout(message: Text('Loading...'))),
        ),
      );

      // Verify that a Column is used with mainAxisAlignment set to center.
      final columnFinder = find.byType(Column);
      expect(columnFinder, findsOneWidget);

      final Column columnWidget = tester.widget<Column>(columnFinder);
      expect(columnWidget.mainAxisAlignment, equals(MainAxisAlignment.center));
    });
  });
}
