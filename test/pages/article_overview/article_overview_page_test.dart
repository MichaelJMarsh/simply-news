import 'package:flutter/material.dart';

import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:simply_news/pages/article_overview/article_overview_page.dart';
import 'package:simply_news/widgets/widgets.dart';

import 'article_overview_page_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<FavoriteNewsArticleRepository>(),
])
void main() {
  group('ArticleOverviewPage', () {
    late FavoriteNewsArticleRepository favoriteNewsArticleRepository;

    final testArticle = NewsArticle(
      title: 'Test Article Title',
      author: 'Test Author',
      // Ensure content is long enough to be truncated (200 characters).
      content: 'Test Content ${'a' * 300}',
      url: 'https://example.com/article',
    );

    setUp(() {
      favoriteNewsArticleRepository = MockFavoriteNewsArticleRepository();

      when(favoriteNewsArticleRepository.get(any))
          .thenAnswer((_) async => null);
      when(favoriteNewsArticleRepository.delete(any))
          .thenAnswer((_) async => Future.value());
      when(favoriteNewsArticleRepository.insert(any))
          .thenAnswer((_) async => Future.value());
    });

    tearDown(() {
      reset(favoriteNewsArticleRepository);
    });

    testWidgets(
      'renders article details and UI elements',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          Provider.value(
            value: favoriteNewsArticleRepository,
            child: MaterialApp(
              home: ArticleOverviewPage(article: testArticle),
            ),
          ),
        );
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Verify that the app bar title is displayed.
        expect(find.text('Article Overview'), findsOneWidget);

        // Verify that the article title and author are rendered.
        expect(find.text('Test Article Title'), findsOneWidget);
        expect(find.text('Test Author'), findsOneWidget);

        // Verify that the article content is truncated to 200 characters.
        final expectedContent = testArticle.content!.substring(0, 200);
        expect(find.text(expectedContent), findsOneWidget);

        expect(find.byType(FavoriteIconButton), findsOneWidget);
        expect(
          find.widgetWithText(ElevatedButton, 'READ MORE'),
          findsOneWidget,
        );
        expect(find.widgetWithText(ElevatedButton, 'SHARE'), findsOneWidget);
        expect(
          find.byKey(const Key('floating_action_button_text.unfavorite')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'toggles favorite status when favorite button is tapped',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          Provider.value(
            value: favoriteNewsArticleRepository,
            child: MaterialApp(
              home: ArticleOverviewPage(article: testArticle),
            ),
          ),
        );
        await tester.pumpAndSettle(const Duration(seconds: 1));

        final favoriteButton = find.byType(FavoriteIconButton);
        expect(favoriteButton, findsOneWidget);
        await tester.tap(favoriteButton);
        await tester.pumpAndSettle();

        verify(favoriteNewsArticleRepository.insert(any)).called(1);
      },
    );
  });
}
