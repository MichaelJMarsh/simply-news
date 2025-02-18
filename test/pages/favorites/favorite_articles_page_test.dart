import 'dart:async';

import 'package:flutter/material.dart';

import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:simply_news/presentation/pages/article_overview/article_overview_page.dart';
import 'package:simply_news/presentation/pages/favorites/favorite_articles_page.dart';
import 'package:simply_news/presentation/widgets/widgets.dart';

import 'favorite_articles_page_test.mocks.dart';

@GenerateNiceMocks([MockSpec<FavoriteNewsArticleRepository>()])
void main() {
  late FavoriteNewsArticleRepository mockRepository;

  /// A helper method to pump the [FavoriteArticlesPage] into the widget tree.
  Future<void> pumpFavoriteArticlesPage(WidgetTester tester) async {
    await tester.pumpWidget(
      Provider.value(
        value: mockRepository,
        child: const MaterialApp(home: FavoriteArticlesPage()),
      ),
    );
  }

  setUp(() {
    mockRepository = MockFavoriteNewsArticleRepository();

    when(mockRepository.list()).thenAnswer((_) async => []);
    when(mockRepository.changes).thenAnswer((_) => const Stream.empty());
  });

  tearDown(() {
    reset(mockRepository);
  });

  testWidgets('shows a loading indicator while loading', (
    WidgetTester tester,
  ) async {
    when(mockRepository.list()).thenAnswer((_) async {
      return Future.delayed(const Duration(seconds: 1), () => []);
    });
    when(mockRepository.changes).thenAnswer((_) => Stream.value([]));

    await pumpFavoriteArticlesPage(tester);

    // Verify that the loading layout is displayed.
    expect(find.byType(LoadingLayout), findsOneWidget);

    // Allow the loading process to complete.
    await tester.pumpAndSettle();

    // Verify that the loading layout is no longer displayed.
    expect(find.byType(LoadingLayout), findsNothing);
    expect(find.byKey(const Key('empty_favorites_state')), findsOneWidget);
  });

  testWidgets('shows empty favorites state when no favorites exist', (
    WidgetTester tester,
  ) async {
    when(mockRepository.list()).thenAnswer((_) async => []);
    when(mockRepository.changes).thenAnswer((_) => Stream.value([]));

    await pumpFavoriteArticlesPage(tester);
    await tester.pumpAndSettle();

    // Verify that the loading layout is not displayed.
    expect(find.byType(LoadingLayout), findsNothing);

    // Verify that the empty favorites state is displayed.
    expect(find.byKey(const Key('empty_favorites_state')), findsOneWidget);
    expect(find.text('You have not favorited any articles.'), findsOneWidget);
  });

  testWidgets('displays favorite articles when available', (
    WidgetTester tester,
  ) async {
    final favoriteNewsArticle = FavoriteNewsArticle(
      article: const NewsArticle(
        title: 'My Favorite Article',
        author: 'Test Author',
        content: 'Some content...',
        url: 'https://example.com/my-favorite',
      ),
      insertionTime: DateTime.now(),
    );

    when(mockRepository.list()).thenAnswer((_) async => [favoriteNewsArticle]);
    when(
      mockRepository.changes,
    ).thenAnswer((_) => Stream.value([favoriteNewsArticle]));

    await pumpFavoriteArticlesPage(tester);
    await tester.pumpAndSettle();

    // Verify that the loading layout is not displayed.
    expect(find.byType(LoadingLayout), findsNothing);
    expect(find.byKey(const Key('empty_favorites_state')), findsNothing);

    // Verify that the favorite article is displayed.
    expect(find.byType(NewsArticleCard), findsOneWidget);
    expect(find.text('My Favorite Article'), findsOneWidget);
  });

  testWidgets('removes a favorite when tapping the "favorite" icon', (
    WidgetTester tester,
  ) async {
    final favoriteNewsArticle = FavoriteNewsArticle(
      article: const NewsArticle(
        title: 'Removable Article',
        author: 'Test Author',
        content: 'Some content...',
        url: 'https://example.com/remove-me',
      ),
      insertionTime: DateTime.now(),
    );

    when(mockRepository.list()).thenAnswer((_) async => [favoriteNewsArticle]);
    when(
      mockRepository.changes,
    ).thenAnswer((_) => Stream.value([favoriteNewsArticle]));

    await pumpFavoriteArticlesPage(tester);
    await tester.pumpAndSettle();

    final cardFinder = find.byType(NewsArticleCard);
    expect(cardFinder, findsOneWidget);

    final favoriteIconFinder = find.descendant(
      of: cardFinder,
      matching: find.byIcon(Icons.favorite),
    );
    expect(favoriteIconFinder, findsOneWidget);

    await tester.tap(favoriteIconFinder);
    await tester.pumpAndSettle();

    // Verify that the favorite article was removed.
    verify(mockRepository.delete(favoriteNewsArticle.article)).called(1);
  });

  testWidgets(
    'navigates to ArticleOverviewPage when tapping a favorite article',
    (WidgetTester tester) async {
      final favoriteNewsArticle = FavoriteNewsArticle(
        article: const NewsArticle(
          title: 'Navigation Test Article',
          author: 'Test Author',
          content: 'Some content...',
          url: 'https://example.com/nav-test',
        ),
        insertionTime: DateTime.now(),
      );

      when(
        mockRepository.list(),
      ).thenAnswer((_) async => [favoriteNewsArticle]);
      when(
        mockRepository.changes,
      ).thenAnswer((_) => Stream.value([favoriteNewsArticle]));

      await pumpFavoriteArticlesPage(tester);
      await tester.pumpAndSettle();

      final cardFinder = find.byType(NewsArticleCard);
      expect(cardFinder, findsOneWidget);

      await tester.tap(cardFinder);
      await tester.pumpAndSettle();

      // Verify that the ArticleOverviewPage is displayed.
      expect(find.byType(ArticleOverviewPage), findsOneWidget);
      expect(find.text('Navigation Test Article'), findsOneWidget);
    },
  );
}
