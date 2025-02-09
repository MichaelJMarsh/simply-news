import 'dart:async';

import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:simply_news/pages/dashboard/dashboard_page_scope.dart';

import 'dashboard_page_scope_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<FavoriteNewsArticleRepository>(),
  MockSpec<NewsArticleService>(),
])
void main() {
  late MockFavoriteNewsArticleRepository mockFavoriteRepository;
  late MockNewsArticleService mockNewsArticleService;
  late DashboardPageScope scope;

  const article1 = NewsArticle(
    title: 'Article 1',
    url: 'https://example.com/article1',
  );
  const article2 = NewsArticle(
    title: 'Article 2',
    url: 'https://example.com/article2',
  );

  const searchResultPage1 = SearchResult(
    articles: [article1, article2],
    totalResults: 4,
  );

  setUp(() {
    mockFavoriteRepository = MockFavoriteNewsArticleRepository();
    mockNewsArticleService = MockNewsArticleService();

    when(mockFavoriteRepository.list()).thenAnswer((_) async => []);
    when(mockFavoriteRepository.changes)
        .thenAnswer((_) => const Stream.empty());
    when(mockNewsArticleService.fetchSources()).thenAnswer((_) async => []);
    when(
      mockNewsArticleService.searchArticles(
        query: anyNamed('query'),
        page: anyNamed('page'),
        pageSize: anyNamed('pageSize'),
        sourceId: anyNamed('sourceId'),
      ),
    ).thenAnswer(
      (_) async => const SearchResult(articles: [], totalResults: 0),
    );
    when(
      mockNewsArticleService.fetchArticlesBySource(
        sourceId: anyNamed('sourceId'),
        page: anyNamed('page'),
        pageSize: anyNamed('pageSize'),
      ),
    ).thenAnswer(
      (_) async => const SearchResult(articles: [], totalResults: 0),
    );

    // Create a fresh scope for each test.
    scope = DashboardPageScope(
      favoriteNewsArticleRepository: mockFavoriteRepository,
      newsArticleService: mockNewsArticleService,
    );
  });

  tearDown(() {
    reset(mockFavoriteRepository);
    reset(mockNewsArticleService);
  });

  group('DashboardPageScope', () {
    test('initialize() loads favorites and sources and sets isLoading to false',
        () async {
      final favoriteArticles = [
        FavoriteNewsArticle(
          article: article1,
          insertionTime: DateTime.now(),
        ),
      ];
      when(mockFavoriteRepository.list())
          .thenAnswer((_) async => favoriteArticles);
      // Stub sources.
      const sources = [NewsSource(id: 'source1', name: 'Source 1')];
      when(mockNewsArticleService.fetchSources())
          .thenAnswer((_) async => sources);

      await scope.initialize();

      expect(scope.isLoading, isFalse);
      expect(scope.sources, equals(sources));
      expect(scope.isFavorite(article1.url), isTrue);
    });

    group('selectSource()', () {
      test('clears articles and refreshes with new source', () async {
        when(
          mockNewsArticleService.fetchArticlesBySource(
            sourceId: anyNamed('sourceId'),
            page: anyNamed('page'),
            pageSize: anyNamed('pageSize'),
          ),
        ).thenAnswer((_) async => searchResultPage1);

        await scope.selectSource('source1');

        // Verify that articles are loaded.
        expect(scope.newsArticles, equals(searchResultPage1.articles));
      });
    });

    group('searchNewsArticles()', () {
      test(
          'if query is empty and no source selected, clears articles without loading',
          () async {
        await scope.searchNewsArticles('');

        await Future.delayed(const Duration(milliseconds: 600));

        // Verify that no articles were loaded, after 500ms debounce.
        expect(scope.newsArticles, isEmpty);
      });

      test('with non-empty query, loads search result after debounce',
          () async {
        when(
          mockNewsArticleService.searchArticles(
            query: 'flutter',
            page: anyNamed('page'),
            pageSize: anyNamed('pageSize'),
            sourceId: anyNamed('sourceId'),
          ),
        ).thenAnswer((_) async => searchResultPage1);

        await scope.searchNewsArticles('flutter');

        await Future.delayed(const Duration(milliseconds: 600));

        // Verify that articles are loaded, after 500ms debounce.
        expect(scope.newsArticles, equals(searchResultPage1.articles));
      });
    });

    test('resets pagination and loads articles', () async {
      when(
        mockNewsArticleService.fetchArticlesBySource(
          sourceId: anyNamed('sourceId'),
          page: 1,
          pageSize: anyNamed('pageSize'),
        ),
      ).thenAnswer((_) async => searchResultPage1);

      when(
        mockNewsArticleService.fetchArticlesBySource(
          sourceId: anyNamed('sourceId'),
          page: 2,
          pageSize: anyNamed('pageSize'),
        ),
      ).thenAnswer(
        (_) async => const SearchResult(articles: [], totalResults: 4),
      );

      await scope.initialize();

      await scope.selectSource('source1');
      expect(scope.newsArticles, equals(searchResultPage1.articles));

      await scope.loadMoreArticles();
      expect(scope.newsArticles, equals(searchResultPage1.articles));

      await scope.refreshArticles();
      expect(scope.newsArticles, equals(searchResultPage1.articles));
    });

    group('toggleFavorite()', () {
      test('calls delete when article is already favorite', () async {
        when(mockFavoriteRepository.list()).thenAnswer(
          (_) async => [
            FavoriteNewsArticle(
              article: article1,
              insertionTime: DateTime.now(),
            ),
          ],
        );
        await scope.initialize();
        expect(scope.isFavorite(article1.url), isTrue);

        when(mockFavoriteRepository.delete(article1))
            .thenAnswer((_) async => Future.value());

        await scope.toggleFavorite(article1);
        verify(mockFavoriteRepository.delete(article1)).called(1);
      });

      test('calls insert when article is not favorite', () async {
        when(mockFavoriteRepository.list()).thenAnswer((_) async => []);
        await scope.initialize();
        expect(scope.isFavorite(article1.url), isFalse);

        when(mockFavoriteRepository.insert(any))
            .thenAnswer((_) async => Future.value());

        await scope.toggleFavorite(article1);
        verify(mockFavoriteRepository.insert(any)).called(1);
      });
    });
  });
}
