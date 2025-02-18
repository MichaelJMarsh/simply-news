import 'dart:async';

import 'package:flutter/material.dart';

import 'package:domain/domain.dart';
import 'package:provider/provider.dart';

import 'package:simply_news/presentation/animations/entrance_animations.dart';
import 'package:simply_news/presentation/widgets/widgets.dart';

import 'article_overview_page_scope.dart';

/// A detailed news article page, allowing users to read, share, and favorite
/// the currently displayed news article.
class ArticleOverviewPage extends StatefulWidget {
  /// Creates a new [ArticleOverviewPage].
  const ArticleOverviewPage({super.key, required this.article});

  /// The news article to display.
  final NewsArticle article;

  @override
  State<ArticleOverviewPage> createState() => _ArticleOverviewPageState();
}

class _ArticleOverviewPageState extends State<ArticleOverviewPage>
    with SingleTickerProviderStateMixin {
  /// The controller which manages the entrance animations.
  late final AnimationController _entranceAnimationsController;

  /// The entrance animations for the [ArticleOverviewPage].
  late final _EntranceAnimations _entranceAnimations;

  /// Timer to start the entrance animation.
  late final Timer _entranceAnimationsStartTimer;

  /// The state of the [ScaffoldMessenger] to show snack bars.
  ScaffoldMessengerState? _scaffoldMessenger;

  @override
  void initState() {
    super.initState();

    _entranceAnimationsController = AnimationController(
      duration: const Duration(seconds: 2),
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

  /// Opens the article's URL in the browser.
  Future<void> _openArticleUrl(
    BuildContext context, {
    required String url,
  }) async {
    final urlLauncher = context.read<UrlLauncher>();
    final canLaunch = await urlLauncher.canLaunch(url);

    if (!context.mounted) return;

    if (!canLaunch) {
      _scaffoldMessenger?.hideCurrentSnackBar();
      _scaffoldMessenger?.showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Could not open the article. Please check your connection '
            'and try again.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );

      return;
    }

    await urlLauncher.launch(url);
  }

  /// Shares the article's URL.
  Future<void> _shareArticle(
    BuildContext context, {
    required String articleUrl,
  }) async {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final success = await context.read<Share>().send(
      content: articleUrl,
      sharePositionOrigin:
          renderBox.localToGlobal(Offset.zero) & renderBox.size,
      subject: 'Simply News',
      message: 'Check out this article I found on Simply News!',
    );

    if (!context.mounted) return;

    if (!success && context.mounted) {
      const snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          'There was an error when trying to share the new article. '
          'Please try again later.',
          style: TextStyle(color: Colors.white),
        ),
      );

      _scaffoldMessenger?.hideCurrentSnackBar();
      _scaffoldMessenger?.showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (context) =>
              ArticleOverviewPageScope.of(context, article: widget.article)
                ..initialize(),
      builder: (context, _) {
        final article = context.watch<ArticleOverviewPageScope>();
        final articleUrl = article.url;

        final isFavoriteArticle = article.isFavorite();

        return Scaffold(
          appBar: AppBar(
            clipBehavior: Clip.none,
            title: AnimatedTranslation.vertical(
              animation: _entranceAnimations.appBarTitle,
              pixels: 32,
              child: const Text('Article Overview'),
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
            actions: [
              AnimatedTranslation.horizontal(
                animation: _entranceAnimations.appBarButton,
                pixels: 24,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: FavoriteIconButton(
                    isFavorite: isFavoriteArticle,
                    onPressed: article.toggleFavorite,
                  ),
                ),
              ),
            ],
          ),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList.list(
                  children: [
                    const SizedBox(height: 32),
                    AnimatedTranslation.vertical(
                      animation: _entranceAnimations.articleTitle,
                      pixels: 32,
                      child: Text(
                        article.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          height: 24 / 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedTranslation.vertical(
                      animation: _entranceAnimations.articleAuthor,
                      pixels: 32,
                      child: Text(article.author),
                    ),
                    const SizedBox(height: 16),
                    AnimatedTranslation.vertical(
                      animation: _entranceAnimations.divider,
                      pixels: 32,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Divider(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AnimatedTranslation.vertical(
                      animation: _entranceAnimations.articleContent,
                      pixels: 32,
                      child: Text(
                        article.content,
                        style: const TextStyle(fontSize: 16, height: 24 / 16),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: AnimatedTranslation.vertical(
                              animation: _entranceAnimations.readMoreButton,
                              pixels: 32,
                              child: ElevatedButton(
                                onPressed:
                                    () => _openArticleUrl(
                                      context,
                                      url: article.url,
                                    ),
                                child: const Text('READ MORE'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AnimatedTranslation.vertical(
                              animation: _entranceAnimations.shareButton,
                              pixels: 32,
                              child: Builder(
                                builder: (context) {
                                  return ElevatedButton(
                                    onPressed:
                                        () => _shareArticle(
                                          context,
                                          articleUrl: articleUrl,
                                        ),
                                    child: const Text('SHARE'),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: AnimatedTranslation.vertical(
            animation: _entranceAnimations.saveButton,
            pixels: 32,
            child: FloatingActionButton.extended(
              onPressed: article.toggleFavorite,
              label: AnimatedSize(
                curve: Curves.fastOutSlowIn,
                duration: const Duration(milliseconds: 250),
                child: AnimatedSwitcher(
                  switchInCurve: Curves.easeIn,
                  switchOutCurve: Curves.easeOut,
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    key: Key(
                      'floating_action_button_text.${isFavoriteArticle ? 'favorite' : 'unfavorite'}',
                    ),
                    isFavoriteArticle
                        ? 'REMOVE FROM FAVORITES'
                        : 'ADD TO FAVORITES',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The entrance animations for each item on the [ArticleOverviewPage].
class _EntranceAnimations extends EntranceAnimations {
  /// Creates a new [_EntranceAnimations]
  const _EntranceAnimations({required super.controller});

  Animation<double> get appBarButton => curvedAnimation(0.000, 0.250);
  Animation<double> get appBarTitle => curvedAnimation(0.025, 0.275);
  Animation<double> get articleTitle => curvedAnimation(0.100, 0.350);
  Animation<double> get articleAuthor => curvedAnimation(0.125, 0.375);
  Animation<double> get divider => curvedAnimation(0.150, 0.400);
  Animation<double> get articleContent => curvedAnimation(0.200, 0.450);
  Animation<double> get readMoreButton => curvedAnimation(0.250, 0.500);
  Animation<double> get shareButton => curvedAnimation(0.275, 0.525);
  Animation<double> get saveButton => curvedAnimation(0.350, 0.600);
}
