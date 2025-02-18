import 'dart:async';

import 'package:flutter/material.dart';

import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:simply_news/presentation/pages/dashboard/dashboard_page.dart';
import 'package:simply_news/presentation/widgets/widgets.dart';

import 'dashboard_page_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<FavoriteNewsArticleRepository>(),
  MockSpec<NewsArticleService>(),
])
void main() {
  late MockFavoriteNewsArticleRepository mockFavoriteRepository;
  late MockNewsArticleService mockNewsArticleService;

  /// Helper method to pump the [DashboardPage] into the widget tree.
  Future<void> pumpDashboardPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<FavoriteNewsArticleRepository>.value(
            value: mockFavoriteRepository,
          ),
          Provider<NewsArticleService>.value(value: mockNewsArticleService),
        ],
        child: const MaterialApp(home: DashboardPage()),
      ),
    );
  }

  setUp(() {
    mockFavoriteRepository = MockFavoriteNewsArticleRepository();
    mockNewsArticleService = MockNewsArticleService();

    when(mockFavoriteRepository.list()).thenAnswer((_) async => []);
    when(
      mockFavoriteRepository.changes,
    ).thenAnswer((_) => const Stream.empty());
    when(
      mockNewsArticleService.fetchSources(),
    ).thenAnswer((_) async => <NewsSource>[]);

    const searchResult = SearchResult(articles: [], totalResults: 0);

    when(
      mockNewsArticleService.searchArticles(
        query: anyNamed('query'),
        page: anyNamed('page'),
        pageSize: anyNamed('pageSize'),
        sourceId: anyNamed('sourceId'),
      ),
    ).thenAnswer((_) async => searchResult);
  });

  tearDown(() {
    reset(mockFavoriteRepository);
    reset(mockNewsArticleService);
  });

  testWidgets('shows loading layout initially', (WidgetTester tester) async {
    await pumpDashboardPage(tester);

    // Verify that the LoadingLayout is displayed initially.
    expect(find.byType(LoadingLayout), findsOneWidget);

    // Allow the loading process to complete.
    await tester.pumpAndSettle();

    // Verify that the LoadingLayout is no longer displayed.
    expect(find.byType(LoadingLayout), findsNothing);
    expect(find.byKey(const Key('empty_search_state')), findsOneWidget);
  });

  testWidgets('displays empty state when no articles are found', (
    WidgetTester tester,
  ) async {
    await pumpDashboardPage(tester);
    await tester.pumpAndSettle();

    // Verify that the empty search state is displayed.
    expect(find.text('Welcome to Simply News!'), findsOneWidget);
    expect(find.byKey(const Key('empty_search_state')), findsOneWidget);
  });
}
