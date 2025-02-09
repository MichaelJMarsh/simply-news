import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:simply_news/widgets/src/favorite_icon_button.dart';

void main() {
  group('FavoriteIconButton', () {
    testWidgets(
      'renders favorite icon when isFavorite is true',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FavoriteIconButton(
                isFavorite: true,
                onPressed: () {},
              ),
            ),
          ),
        );

        // Verify that the correct icon is rendered.
        expect(find.byIcon(Icons.favorite), findsOneWidget);
        expect(find.byIcon(Icons.favorite_border), findsNothing);
      },
    );

    testWidgets(
      'renders not favorite icon when isFavorite is false',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FavoriteIconButton(
                isFavorite: false,
                onPressed: () {},
              ),
            ),
          ),
        );

        // Verify that the correct icon is rendered.
        expect(find.byIcon(Icons.favorite_border), findsOneWidget);
        expect(find.byIcon(Icons.favorite), findsNothing);
      },
    );

    testWidgets(
      'calls onPressed callback when tapped',
      (WidgetTester tester) async {
        var pressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FavoriteIconButton(
                isFavorite: false,
                onPressed: () => pressed = true,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();

        // Verify that the onPressed callback was called.
        expect(pressed, isTrue);
      },
    );

    testWidgets(
      'uses AnimatedSwitcher for transition and switches keys properly',
      (WidgetTester tester) async {
        // Arrange
        var isFavorite = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return FavoriteIconButton(
                    isFavorite: isFavorite,
                    onPressed: () {
                      setState(() => isFavorite = !isFavorite);
                    },
                  );
                },
              ),
            ),
          ),
        );

        // Verify that the not favorite icon is rendered.
        expect(
          find.byKey(const Key('favorite_icon.not_favorite')),
          findsOneWidget,
        );

        await tester.tap(find.byType(IconButton));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Verify that the key has changed.
        expect(find.byKey(const Key('favorite_icon.favorite')), findsOneWidget);
      },
    );
  });
}
