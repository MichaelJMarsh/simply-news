import 'dart:async';

import 'package:flutter/material.dart';

import 'package:domain/domain.dart';
import 'package:provider/provider.dart';

import 'package:simply_news/presentation/animations/entrance_animations.dart';
import 'package:simply_news/presentation/pages/article_overview/article_overview_page.dart';
import 'package:simply_news/presentation/widgets/widgets.dart';

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
  /// The controller which manages the entrance animations.
  late final AnimationController _entranceAnimationsController;

  /// The entrance animations for the [FavoriteArticlesPage].
  late final _EntranceAnimations _entranceAnimations;

  /// Timer to start the entrance animation.
  late final Timer _entranceAnimationsStartTimer;

  /// The state of the [ScaffoldMessenger] to show snack bars.
  ScaffoldMessengerState? _scaffoldMessenger;

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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _scaffoldMessenger ??= ScaffoldMessenger.maybeOf(context);
  }

  @override
  void dispose() {
    _entranceAnimationsStartTimer.cancel();
    _entranceAnimationsController.dispose();

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
              padding: EdgeInsets.only(top: 24, bottom: bottomPadding),
              sliver: SliverList.separated(
                itemCount: favorites.list.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final newsArticle = favorites.list[index];

                  return AnimatedTranslation.vertical(
                    animation: _entranceAnimations.body,
                    pixels: 32,
                    child: NewsArticleCard(
                      article: newsArticle,
                      isFavorite: favorites.isFavorite(newsArticle),
                      onFavorite: () => favorites.removeFavorite(newsArticle),
                      onPressed:
                          () => _openArticleOverview(
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
            key: Key('loading_indicator.${isLoading ? 'visible' : 'hidden'}'),
            animation: _entranceAnimations.body,
            pixels: 32,
            child: Padding(
              padding: EdgeInsets.only(bottom: appBarHeight),
              child: const Center(
                child: LoadingLayout(message: Text('Loading news articles...')),
              ),
            ),
          );
        } else if (isFavoritesEmpty) {
          body = AnimatedTranslation.vertical(
            key: const Key('empty_favorites_state'),
            animation: _entranceAnimations.body,
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
                            color: colorScheme.onSurface.withValues(
                              alpha: 0.64,
                            ),
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
            backgroundColor: WidgetStateColor.resolveWith((states) {
              return states.contains(WidgetState.scrolledUnder)
                  ? colorScheme.primary.withValues(alpha: 0.24)
                  : Colors.transparent;
            }),
            title: Column(
              children: [
                AnimatedTranslation.vertical(
                  animation: _entranceAnimations.appBarTitle,
                  pixels: 32,
                  child: const Text('Favorites'),
                ),
                const SizedBox(height: 4),
                AnimatedTranslation.vertical(
                  animation: _entranceAnimations.appBarSubtitle,
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
              animation: _entranceAnimations.appBarButton,
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
class _EntranceAnimations extends EntranceAnimations {
  /// Creates a new [_EntranceAnimations].
  const _EntranceAnimations({required super.controller});

  Animation<double> get appBarButton => curvedAnimation(0.000, 0.500);
  Animation<double> get appBarTitle => curvedAnimation(0.050, 0.550);
  Animation<double> get appBarSubtitle => curvedAnimation(0.075, 0.575);
  Animation<double> get body => curvedAnimation(0.200, 0.700);
}
