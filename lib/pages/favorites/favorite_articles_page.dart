import 'dart:async';

import 'package:flutter/material.dart';

import 'package:domain/domain.dart';
import 'package:provider/provider.dart';

import 'package:simply_news/pages/article_overview/article_overview_page.dart';
import 'package:simply_news/widgets/widgets.dart';

import 'favorite_articles_page_scope.dart';

/// A page that displays a user’s saved favorite news articles, allowing users
/// to view and / or remove favorites.
class FavoriteArticlesPage extends StatefulWidget {
  /// Creates a new [FavoriteArticlesPage].
  const FavoriteArticlesPage({super.key});

  @override
  State<FavoriteArticlesPage> createState() => _FavoriteArticlesPageState();
}

class _FavoriteArticlesPageState extends State<FavoriteArticlesPage>
    with SingleTickerProviderStateMixin {
  /// The controller which manages the enter animations.
  late final AnimationController _enterAnimationsController;

  /// The enter animations for the [FavoriteArticlesPage].
  late final _EnterAnimations _enterAnimations;

  /// Timer to start the enter animation.
  late final Timer _enterAnimationsStartTimer;

  /// The state of the [ScaffoldMessenger] to show snack bars.
  ScaffoldMessengerState? _scaffoldMessenger;

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
  void didChangeDependencies() {
    super.didChangeDependencies();

    _scaffoldMessenger ??= ScaffoldMessenger.maybeOf(context);
  }

  @override
  void dispose() {
    _enterAnimationsStartTimer.cancel();
    _enterAnimationsController.dispose();

    _scaffoldMessenger = null;

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
    return ChangeNotifierProvider(
      create: (context) => FavoriteArticlesPageScope.of(context)..initialize(),
      builder: (context, _) {
        final colorScheme = Theme.of(context).colorScheme;
        final favorites = context.watch<FavoriteArticlesPageScope>();

        final padding = MediaQuery.paddingOf(context);
        final appBarHeight = kToolbarHeight + padding.top;
        final bottomPadding = 32 + padding.bottom;

        Widget body = CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.only(
                top: 24,
                bottom: bottomPadding,
              ),
              sliver: SliverList.separated(
                itemCount: favorites.list.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final newsArticle = favorites.list[index];

                  return AnimatedTranslation.vertical(
                    animation: _enterAnimations.body,
                    pixels: 32,
                    child: NewsArticleCard(
                      article: newsArticle,
                      isFavorite: favorites.isFavorite(newsArticle),
                      onFavorite: () => favorites.removeFavorite(newsArticle),
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
        );

        final favoritesCount = favorites.count;
        final isFavoritesEmpty = favoritesCount == 0;

        final isLoading = favorites.isLoading;
        if (isLoading) {
          body = AnimatedTranslation.vertical(
            key: Key(
              'loading_indicator.${isLoading ? 'visible' : 'hidden'}',
            ),
            animation: _enterAnimations.body,
            pixels: 32,
            child: Padding(
              padding: EdgeInsets.only(bottom: appBarHeight),
              child: const Center(
                child: LoadingLayout(
                  message: Text('Loading news articles...'),
                ),
              ),
            ),
          );
        } else if (isFavoritesEmpty) {
          body = AnimatedTranslation.vertical(
            key: const Key('empty_favorites_state'),
            animation: _enterAnimations.body,
            pixels: 32,
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: appBarHeight),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 295),
                  child: DefaultTextStyle.merge(
                    textAlign: TextAlign.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('You have not favorited any articles.'),
                        const SizedBox(height: 24),
                        Text(
                          'TAP THE HEART ICON ON AN ARTICLE TO ADD IT TO YOUR '
                          'FAVORITES',
                          style: TextStyle(
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.64),
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

        return Scaffold(
          appBar: AppBar(
            clipBehavior: Clip.none,
            backgroundColor: WidgetStateColor.resolveWith(
              (states) {
                return states.contains(WidgetState.scrolledUnder)
                    ? colorScheme.primary.withValues(alpha: 0.24)
                    : Colors.transparent;
              },
            ),
            title: Column(
              children: [
                AnimatedTranslation.vertical(
                  animation: _enterAnimations.appBarTitle,
                  pixels: 32,
                  child: const Text('Favorites'),
                ),
                const SizedBox(height: 4),
                AnimatedTranslation.vertical(
                  animation: _enterAnimations.appBarSubtitle,
                  pixels: 32,
                  child: Text(
                    '$favoritesCount ARTICLES',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: colorScheme.onSurface.withValues(alpha: 0.64),
                    ),
                  ),
                ),
              ],
            ),
            leading: AnimatedTranslation.horizontal(
              animation: _enterAnimations.appBarButton,
              pixels: -24,
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: IconButton(
                  onPressed: Navigator.of(context).pop,
                  icon: const Icon(Icons.arrow_back),
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
        );
      },
    );
  }
}

/// The entrance animations for each item on the [FavoriteArticlesPage].
class _EnterAnimations {
  _EnterAnimations(this.controller)
      : appBarButton = CurvedAnimation(
          parent: controller,
          curve: const Interval(0.000, 0.500, curve: Curves.fastOutSlowIn),
        ),
        appBarTitle = CurvedAnimation(
          parent: controller,
          curve: const Interval(0.050, 0.550, curve: Curves.fastOutSlowIn),
        ),
        appBarSubtitle = CurvedAnimation(
          parent: controller,
          curve: const Interval(0.075, 0.575, curve: Curves.fastOutSlowIn),
        ),
        body = CurvedAnimation(
          parent: controller,
          curve: const Interval(0.200, 0.700, curve: Curves.fastOutSlowIn),
        );

  final AnimationController controller;

  final Animation<double> appBarButton;
  final Animation<double> appBarTitle;
  final Animation<double> appBarSubtitle;

  final Animation<double> body;
}
