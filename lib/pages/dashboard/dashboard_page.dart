import 'dart:async';

import 'package:flutter/material.dart';

import 'package:domain/domain.dart';
import 'package:provider/provider.dart';

import 'package:simply_news/pages/article_overview/article_overview_page.dart';
import 'package:simply_news/widgets/widgets.dart';

import 'dashboard_page_scope.dart';
import 'widgets/news_article_tile.dart';

class DashboardPage extends StatefulWidget {
  /// Creates a new [DashboardPage].
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  /// The controller which manages the enter animations.
  late final AnimationController _enterAnimationsController;

  /// The enter animations for the [DashboardPage].
  late final _EnterAnimations _enterAnimations;

  /// Timer to start the enter animation.
  late final Timer _enterAnimationsStartTimer;

  @override
  void initState() {
    super.initState();

    _enterAnimationsController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _enterAnimations = _EnterAnimations(_enterAnimationsController);

    _enterAnimationsStartTimer = Timer(
      const Duration(milliseconds: 200),
      _enterAnimationsController.forward,
    );
  }

  @override
  void dispose() {
    _enterAnimationsStartTimer.cancel();
    _enterAnimationsController.dispose();

    super.dispose();
  }

  /// Opens the article overview page for the given [articleId].
  Future<void> _openArticleOverview(
    BuildContext context, {
    required NewsArticle article,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleOverviewPage(article: article),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = 32 + MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      appBar: AppBar(
        title: AnimatedTranslation.vertical(
          animation: _enterAnimations.appBarTitle,
          pixels: 32,
          child: const Text('Simply News'),
        ),
        actions: [
          AnimatedTranslation.horizontal(
            animation: _enterAnimations.appBarButton,
            pixels: 24,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.favorite),
              ),
            ),
          ),
        ],
      ),
      body: ChangeNotifierProvider(
        create: (context) => DashboardPageScope.of(context)..initialize(),
        builder: (context, _) {
          final dashboard = context.watch<DashboardPageScope>();
          final isLoading = dashboard.isLoading;

          return AnimatedSwitcher(
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            duration: const Duration(milliseconds: 450),
            child: isLoading
                ? AnimatedTranslation.vertical(
                    animation: _enterAnimations.loadingIndicator,
                    pixels: 32,
                    child: Center(
                      key: Key(
                        'loading_indicator.${isLoading ? 'visible' : 'hidden'}',
                      ),
                      child: const Text('Loading news articles...'),
                    ),
                  )
                : CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: AnimatedTranslation.vertical(
                            animation: _enterAnimations.searchBar,
                            pixels: 32,
                            child: SearchBar(
                              key: const Key('search_bar'),
                              hintText: 'Search for news articles...',
                              onChanged: dashboard.searchNewsArticles,
                              onSubmitted: dashboard.searchNewsArticles,
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.only(
                          bottom: bottomPadding,
                        ),
                        sliver: SliverList.separated(
                          itemCount: dashboard.newsArticles.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final newsArticle = dashboard.newsArticles[index];

                            return AnimatedTranslation.vertical(
                              animation: _enterAnimations.newsArticles,
                              pixels: 32,
                              child: NewsArticleTile(
                                article: newsArticle,
                                isFavorite:
                                    dashboard.isFavorite(newsArticle.url),
                                onFavorite: () =>
                                    dashboard.toggleFavorite(newsArticle),
                                onPressed: () => _openArticleOverview(
                                  context,
                                  article: newsArticle,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

/// The entrance animations for each item on the [DashboardPage].
class _EnterAnimations {
  _EnterAnimations(this.controller)
      : appBarButton = CurvedAnimation(
          parent: controller,
          curve: const Interval(0, 0.500, curve: Curves.fastOutSlowIn),
        ),
        appBarTitle = CurvedAnimation(
          parent: controller,
          curve: const Interval(0.050, 0.550, curve: Curves.fastOutSlowIn),
        ),
        searchBar = CurvedAnimation(
          parent: controller,
          curve: const Interval(0.200, 0.700, curve: Curves.fastOutSlowIn),
        ),
        loadingIndicator = CurvedAnimation(
          parent: controller,
          curve: const Interval(0.300, 0.800, curve: Curves.fastOutSlowIn),
        ),
        newsArticles = CurvedAnimation(
          parent: controller,
          curve: const Interval(0.400, 0.900, curve: Curves.fastOutSlowIn),
        );

  final AnimationController controller;

  final Animation<double> appBarButton;
  final Animation<double> appBarTitle;

  final Animation<double> searchBar;

  final Animation<double> loadingIndicator;
  final Animation<double> newsArticles;
}
