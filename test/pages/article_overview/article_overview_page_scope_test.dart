import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:simply_news/pages/article_overview/article_overview_page_scope.dart';

import 'article_overview_page_scope_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<FavoriteNewsArticleRepository>(),
])
void main() {
  late MockFavoriteNewsArticleRepository mockFavoriteNewsArticleRepository;
  late ArticleOverviewPageScope scope;

  const testArticle = NewsArticle(
    title: 'Mock Title',
    author: 'Mock Author',
    content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
        'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
        'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris '
        'nisi ut aliquip ex ea commodo consequat.',
    url: 'https://example.com/article/123',
  );

  setUp(() {
    mockFavoriteNewsArticleRepository = MockFavoriteNewsArticleRepository();

    when(mockFavoriteNewsArticleRepository.get(any))
        .thenAnswer((_) async => null);

    scope = ArticleOverviewPageScope(
      article: testArticle,
      favoriteNewsArticleRepository: mockFavoriteNewsArticleRepository,
    );
  });

  tearDown(() {
    reset(mockFavoriteNewsArticleRepository);
  });

  group('ArticleOverviewPageScope', () {
    test('exposes expected properties: title, author, content, url', () {
      expect(scope.title, equals('Mock Title'));
      expect(scope.author, equals('Mock Author'));
      expect(scope.url, equals('https://example.com/article/123'));
    });

    group('content', () {
      test('is truncated to 200 characters if longer than 200', () {
        final longContentArticle = NewsArticle(
          title: 'Long Content',
          content: List.filled(300, 'A').join(),
        );

        final localScope = ArticleOverviewPageScope(
          article: longContentArticle,
          favoriteNewsArticleRepository: mockFavoriteNewsArticleRepository,
        );

        // Verify that the content is truncated to 200 characters.
        expect(localScope.content.length, 200);
        expect(localScope.content, equals('A' * 200));
      });

      test('is not truncated if less than or equal to 200', () {
        final shortContentArticle = NewsArticle(
          title: 'Short Content',
          content: List.filled(150, 'A').join(),
        );

        final localScope = ArticleOverviewPageScope(
          article: shortContentArticle,
          favoriteNewsArticleRepository: mockFavoriteNewsArticleRepository,
        );

        // Verify that the content is not truncated.
        expect(localScope.content.length, 150);
        expect(localScope.content, equals('A' * 150));
      });
    });

    test('initialize() sets favoriteNewsArticle, notifies listeners', () async {
      bool didNotify = false;
      scope.addListener(() {
        didNotify = true;
      });

      when(mockFavoriteNewsArticleRepository.get(testArticle.url!))
          .thenAnswer((_) async => null);

      await scope.initialize();

      expect(scope.isFavorite(), isFalse);
      expect(
        didNotify,
        isTrue,
        reason: 'Expected notifyListeners to be called',
      );
    });

    group('isFavorite()', () {
      test('returns false if repository returns null', () async {
        when(mockFavoriteNewsArticleRepository.get(testArticle.url!))
            .thenAnswer((_) async => null);

        await scope.initialize();

        expect(scope.isFavorite(), isFalse);
        verify(mockFavoriteNewsArticleRepository.get(testArticle.url!))
            .called(1);
      });

      test('returns true if repository returns a FavoriteNewsArticle',
          () async {
        final favorite = FavoriteNewsArticle(
          article: testArticle,
          insertionTime: DateTime.now(),
        );

        when(mockFavoriteNewsArticleRepository.get(testArticle.url!))
            .thenAnswer((_) async => favorite);

        await scope.initialize();

        expect(scope.isFavorite(), isTrue);
        verify(mockFavoriteNewsArticleRepository.get(testArticle.url!))
            .called(1);
      });
    });

    group('toggleFavorite()', () {
      test('inserts article if not currently favorite', () async {
        when(mockFavoriteNewsArticleRepository.get(testArticle.url!))
            .thenAnswer((_) async => null);

        await scope.initialize();
        expect(scope.isFavorite(), isFalse);

        when(mockFavoriteNewsArticleRepository.insert(any))
            .thenAnswer((_) async => Future.value());

        await scope.toggleFavorite();
        verify(mockFavoriteNewsArticleRepository.insert(any)).called(1);

        // Verify that the article is now a favorite.
        expect(scope.isFavorite(), isTrue);
      });

      test('deletes article if currently favorite', () async {
        final favorite = FavoriteNewsArticle(
          article: testArticle,
          insertionTime: DateTime.now(),
        );

        when(mockFavoriteNewsArticleRepository.get(testArticle.url!))
            .thenAnswer((_) async => favorite);

        await scope.initialize();
        expect(scope.isFavorite(), isTrue);

        when(mockFavoriteNewsArticleRepository.delete(testArticle))
            .thenAnswer((_) async => Future.value());

        await scope.toggleFavorite();
        verify(mockFavoriteNewsArticleRepository.delete(testArticle)).called(1);

        // Verify that the article is no longer a favorite.
        expect(scope.isFavorite(), isFalse);
      });
    });
  });
}
