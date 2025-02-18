import 'package:flutter/material.dart';

import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:simply_news/presentation/widgets/src/favorite_icon_button.dart';
import 'package:simply_news/presentation/widgets/src/news_article_card.dart';

void main() {
  group('NewsArticleCard', () {
    const testArticle = NewsArticle(title: 'Breaking News', author: 'John Doe');

    testWidgets('renders article title and author when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NewsArticleCard(
              article: testArticle,
              isFavorite: false,
              onFavorite: () {},
              onPressed: () {},
            ),
          ),
        ),
      );

      // Verify that the title is displayed.
      expect(find.text('Breaking News'), findsOneWidget);

      // Verify that the author is displayed.
      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('renders favorite icon correctly based on isFavorite value', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NewsArticleCard(
              article: testArticle,
              isFavorite: true,
              onFavorite: () {},
              onPressed: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify that the favorite icon is displayed as selected.
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);

      // Rebuild with isFavorite set to false.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NewsArticleCard(
              article: testArticle,
              isFavorite: false,
              onFavorite: () {},
              onPressed: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify that the favorite icon is displayed as unselected.
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);
    });

    testWidgets('calls onPressed callback when tapped', (
      WidgetTester tester,
    ) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NewsArticleCard(
              article: testArticle,
              isFavorite: false,
              onFavorite: () {},
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(NewsArticleCard));
      await tester.pumpAndSettle();

      // Verify that onPressed was called.
      expect(pressed, isTrue);
    });

    testWidgets('calls onFavorite callback when favorite button is tapped', (
      WidgetTester tester,
    ) async {
      var favoriteToggled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NewsArticleCard(
              article: testArticle,
              isFavorite: false,
              onFavorite: () => favoriteToggled = true,
              onPressed: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(FavoriteIconButton));
      await tester.pumpAndSettle();

      // Verify that onFavorite was called.
      expect(favoriteToggled, isTrue);
    });

    testWidgets('renders without an author if none is provided', (
      WidgetTester tester,
    ) async {
      const articleWithoutAuthor = NewsArticle(title: 'Breaking News');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NewsArticleCard(
              article: articleWithoutAuthor,
              isFavorite: false,
              onFavorite: () {},
              onPressed: () {},
            ),
          ),
        ),
      );

      // Verify that the title is displayed.
      expect(find.byKey(const Key('news_article_card_title')), findsOneWidget);

      // Verify that no author is displayed.
      expect(find.byKey(const Key('news_article_card_author')), findsNothing);
    });

    testWidgets('uses Card with correct styling', (WidgetTester tester) async {
      // Arrange: Build the widget.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NewsArticleCard(
              article: testArticle,
              isFavorite: false,
              onFavorite: () {},
              onPressed: () {},
            ),
          ),
        ),
      );

      // Verify that the Card is used.
      final cardFinder = find.byType(Card);
      expect(cardFinder, findsOneWidget);

      final cardWidget = tester.widget<Card>(cardFinder);

      // Verify that the Card has the correct properties.
      expect(cardWidget.elevation, equals(2));
      expect(cardWidget.shape, isA<RoundedRectangleBorder>());
    });
  });
}
