import 'dart:async';

import 'package:flutter/material.dart';

import 'package:domain/domain.dart';
import 'package:provider/provider.dart';
import 'package:simply_news/presentation/animations/entrance_animations.dart';

import 'package:simply_news/presentation/pages/article_overview/article_overview_page.dart';
import 'package:simply_news/presentation/pages/favorites/favorite_articles_page.dart';
import 'package:simply_news/presentation/widgets/widgets.dart';

import 'dashboard_page_scope.dart';

/// A dynamic dashboard displaying news articles with a dropdown menu for
/// selecting news sources, a search bar, and favorite icon button which
/// navigates users to the [FavoriteArticlesPage].
///
/// Users can view news articles, favorite them, and load more articles.
///
/// As the users scroll to the bottom of the page, the dashboard will load more
/// articles. If the user reaches the end of the available articles, they will
/// be prompted to update the news source or search query.
///
/// If a users pulls down on a given list of articles, the dashboard will refresh
/// the articles.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DashboardPageScope.of(context)..initialize(),
      child: const _Layout(),
    );
  }
}

class _Layout extends StatefulWidget {
  /// Creates a new [_Layout].
  const _Layout();

  @override
  State<_Layout> createState() => _LayoutState();
}

class _LayoutState extends State<_Layout> with SingleTickerProviderStateMixin {
  /// The controller which manages the entrance animations.
  late final AnimationController _entranceAnimationsController;

  /// The entrance animations for the [DashboardPage].
  late final _EntranceAnimations _entranceAnimations;

  /// Timer to start the entrance animation.
  late final Timer _entranceAnimationsStartTimer;

  /// Scroll controller used for pagination.
  final _scrollController = ScrollController();

  /// The focus node for the search bar.
  final _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _entranceAnimationsController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _entranceAnimations = _EntranceAnimations(
      controller: _entranceAnimationsController,
    );

    _entranceAnimationsStartTimer = Timer(
      const Duration(milliseconds: 200),
      _entranceAnimationsController.forward,
    );

    // Listen for scroll events to trigger loading more articles.
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _entranceAnimationsStartTimer.cancel();
    _entranceAnimationsController.dispose();

    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();

    _searchFocusNode.dispose();

    super.dispose();
  }

  /// Attempts to load more articles, if the user scrolls close to the bottom.
  Future<void> _onScroll() async {
    const pixelThreshold = 200.0;
    final hasReachBottom =
        _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - pixelThreshold;

    final dashboardScope = context.read<DashboardPageScope>();

    if (!hasReachBottom || dashboardScope.isLoadingMore) return;

    await dashboardScope.loadMoreArticles();
  }

  /// Opens the [ArticleOverviewPage] for the given [articleId].
  Future<void> _openArticleOverview(
    BuildContext context, {
    required NewsArticle article,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ArticleOverviewPage(article: article)),
    );
  }

  /// Opens the [FavoriteArticlesPage].
  Future<void> _openFavoritesArticles(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FavoriteArticlesPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final padding = MediaQuery.paddingOf(context);
    final appBarHeight = kToolbarHeight + padding.top;
    final bottomPadding = 32 + padding.bottom;
    final topPadding = 16 + padding.top;

    final dashboard = context.watch<DashboardPageScope>();
    final newArticlesIsEmpty = dashboard.newsArticles.isEmpty;

    const dropDownHeight = 48.0;
    const searchBarHeight = 56.0;
    const searchBarVerticalPadding = 8.0;
    final headerHeight = appBarHeight + searchBarHeight;

    final hasReachedLastArticle =
        !dashboard.hasMoreArticles && dashboard.newsArticles.isNotEmpty;

    Widget body = RefreshIndicator(
      onRefresh: dashboard.refreshArticles,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.only(top: 24),
            sliver: SliverList.separated(
              itemCount: dashboard.newsArticles.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final newsArticle = dashboard.newsArticles[index];

                return AnimatedTranslation.vertical(
                  animation: _entranceAnimations.body,
                  pixels: 32,
                  child: NewsArticleCard(
                    article: newsArticle,
                    isFavorite: dashboard.isFavorite(newsArticle.url),
                    onFavorite: () => dashboard.toggleFavorite(newsArticle),
                    onPressed:
                        () =>
                            _openArticleOverview(context, article: newsArticle),
                  ),
                );
              },
            ),
          ),
          if (dashboard.isLoadingMore)
            const SliverToBoxAdapter(
              key: Key('loading_more_articles_indicator'),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: LoadingIndicator()),
              ),
            )
          else if (hasReachedLastArticle)
            SliverToBoxAdapter(
              key: const Key('end_of_articles_indicator'),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
                child: Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.64),
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                      color: colorScheme.primary.withValues(alpha: 0.08),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: DefaultTextStyle.merge(
                        textAlign: TextAlign.center,
                        child: Column(
                          spacing: 8,
                          children: [
                            Text(
                              'It seems you have reached the end of available '
                              'new articles.',
                              style: TextStyle(color: colorScheme.primary),
                            ),
                            Text(
                              'UPDATE THE NEWS SOURCE OR SEARCH QUERY FOR MORE '
                              'ARTICLES',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary.withValues(
                                  alpha: 0.48,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          SliverToBoxAdapter(child: SizedBox(height: bottomPadding)),
        ],
      ),
    );

    final isLoading = dashboard.isLoading;
    if (isLoading) {
      body = AnimatedTranslation.vertical(
        key: Key('loading_indicator.${isLoading ? 'visible' : 'hidden'}'),
        animation: _entranceAnimations.body,
        pixels: 32,
        child: Padding(
          padding: EdgeInsets.only(bottom: headerHeight),
          child: const Center(
            child: LoadingLayout(message: Text('Loading news articles...')),
          ),
        ),
      );
    } else if (newArticlesIsEmpty) {
      body = AnimatedTranslation.vertical(
        key: const Key('empty_search_state'),
        animation: _entranceAnimations.body,
        pixels: 32,
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(bottom: headerHeight),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 295),
              child: DefaultTextStyle.merge(
                textAlign: TextAlign.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Welcome to Simply News!'),
                    const SizedBox(height: 24),
                    Text(
                      'To get started, select a source from the dropdown above and '
                      '/ or use the search bar to find news articles.',
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.64),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _searchFocusNode.unfocus,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
            topPadding + dropDownHeight + searchBarVerticalPadding,
          ),
          child: AppBar(
            clipBehavior: Clip.none,
            backgroundColor: WidgetStateColor.resolveWith((states) {
              return states.contains(WidgetState.scrolledUnder)
                  ? colorScheme.primary.withValues(alpha: 0.24)
                  : Colors.transparent;
            }),
            flexibleSpace: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: topPadding),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AnimatedTranslation.vertical(
                        animation: _entranceAnimations.appBarTitle,
                        pixels: 32,
                        child: DropdownButton(
                          value:
                              dashboard.selectedSourceId?.isEmpty == true
                                  ? null
                                  : dashboard.selectedSourceId,
                          hint: const Text('Select Source'),
                          underline: const SizedBox(),
                          items: [
                            // Option to clear selection
                            const DropdownMenuItem(
                              value: '',
                              child: Text('All Sources'),
                            ),
                            // Actual sources
                            ...dashboard.sources.map(
                              (source) => DropdownMenuItem(
                                value: source.id,
                                child: Text(source.name),
                              ),
                            ),
                          ],
                          onChanged:
                              (sourceId) => dashboard.selectSource(sourceId),
                        ),
                      ),
                      AnimatedTranslation.horizontal(
                        animation: _entranceAnimations.appBarButton,
                        pixels: 24,
                        child: IconButton(
                          onPressed: () => _openFavoritesArticles(context),
                          icon: const Icon(Icons.favorite),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: searchBarVerticalPadding),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(searchBarHeight),
              child: AnimatedTranslation.vertical(
                animation: _entranceAnimations.searchBar,
                pixels: 32,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: searchBarVerticalPadding,
                  ),
                  child: SearchBar(
                    key: const Key('search_bar'),
                    hintText: 'Search for news articles...',
                    focusNode: _searchFocusNode,
                    textInputAction: TextInputAction.search,
                    onSubmitted: dashboard.searchNewsArticles,
                  ),
                ),
              ),
            ),
          ),
        ),
        body: AnimatedSwitcher(
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          duration: const Duration(milliseconds: 450),
          child: body,
        ),
      ),
    );
  }
}

/// The entrance animations for each item on the [DashboardPage].
class _EntranceAnimations extends EntranceAnimations {
  /// Creates a new [_EntranceAnimations].
  const _EntranceAnimations({required super.controller});

  Animation<double> get appBarButton => curvedAnimation(0.000, 0.500);
  Animation<double> get appBarTitle => curvedAnimation(0.050, 0.550);
  Animation<double> get searchBar => curvedAnimation(0.200, 0.700);
  Animation<double> get body => curvedAnimation(0.300, 0.800);
}
