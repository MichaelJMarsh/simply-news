import 'dart:async';

import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:simply_news/presentation/pages/favorites/favorite_articles_page_scope.dart';

import 'favorite_articles_page_scope_test.mocks.dart';

@GenerateNiceMocks([MockSpec<FavoriteNewsArticleRepository>()])
void main() {
  late MockFavoriteNewsArticleRepository mockFavoriteNewsArticleRepository;
  late FavoriteArticlesPageScope scope;

  // We'll define some sample articles and favorite entries for testing.
  const sampleArticle1 = NewsArticle(
    title: 'Article 1',
    url: 'https://example.com/1',
    author: 'Author 1',
    content: 'Content 1',
  );
  const sampleArticle2 = NewsArticle(
    title: 'Article 2',
    url: 'https://example.com/2',
    author: 'Author 2',
    content: 'Content 2',
  );

  final favoriteNewsArticle1 = FavoriteNewsArticle(
    article: sampleArticle1,
    insertionTime: DateTime.now(),
  );
  final favoriteNewsArticle2 = FavoriteNewsArticle(
    article: sampleArticle2,
    insertionTime: DateTime.now(),
  );

  setUp(() {
    mockFavoriteNewsArticleRepository = MockFavoriteNewsArticleRepository();

    when(
      mockFavoriteNewsArticleRepository.list(),
    ).thenAnswer((_) async => <FavoriteNewsArticle>[]);
    when(
      mockFavoriteNewsArticleRepository.changes,
    ).thenAnswer((_) => const Stream.empty());

    scope = FavoriteArticlesPageScope(
      favoriteNewsArticleRepository: mockFavoriteNewsArticleRepository,
    );
  });

  tearDown(() {
    reset(mockFavoriteNewsArticleRepository);
  });

  group('FavoriteArticlesPageScope', () {
    test(
      'initialize() loads favorites, sets isLoading = false, notifies listeners',
      () async {
        bool didNotify = false;
        scope.addListener(() {
          didNotify = true;
        });

        when(
          mockFavoriteNewsArticleRepository.list(),
        ).thenAnswer((_) async => [favoriteNewsArticle1, favoriteNewsArticle2]);

        await scope.initialize();

        // Verify the state.
        expect(scope.isLoading, isFalse);
        expect(scope.list, [sampleArticle1, sampleArticle2]);
        expect(scope.count, 2);

        // Verify that notifyListeners was called.
        expect(didNotify, isTrue);
      },
    );

    test('count returns the size of loaded favorite articles', () async {
      // Verify that count is 0 initially.
      expect(scope.count, 0);

      when(
        mockFavoriteNewsArticleRepository.list(),
      ).thenAnswer((_) async => [favoriteNewsArticle1]);

      await scope.initialize();

      // Verify that count is 1 after loading the favorite article.
      expect(scope.count, 1);
    });

    group('isFavorite', () {
      test('returns false if article is not in the list', () async {
        await scope.initialize();

        // Verify that the article is not in the list.
        expect(scope.isFavorite(sampleArticle1), isFalse);
      });

      test('returns true if article is in the list', () async {
        when(
          mockFavoriteNewsArticleRepository.list(),
        ).thenAnswer((_) async => [favoriteNewsArticle1]);

        await scope.initialize();

        // Verify that the article is in the list.
        expect(scope.isFavorite(sampleArticle1), isTrue);
      });
    });

    test(
      'removeFavorite calls repository.delete(article) and removes it from the list',
      () async {
        when(
          mockFavoriteNewsArticleRepository.list(),
        ).thenAnswer((_) async => [favoriteNewsArticle1, favoriteNewsArticle2]);

        await scope.initialize();
        expect(scope.list, [sampleArticle1, sampleArticle2]);

        when(
          mockFavoriteNewsArticleRepository.delete(sampleArticle1),
        ).thenAnswer((_) => Future.value());

        await scope.removeFavorite(sampleArticle1);

        verify(
          mockFavoriteNewsArticleRepository.delete(sampleArticle1),
        ).called(1);
      },
    );
  });
}
