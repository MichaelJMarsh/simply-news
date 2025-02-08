import 'dart:async';

import 'package:flutter/material.dart';

import 'package:domain/domain.dart';
import 'package:provider/provider.dart';

import 'package:simply_news/widgets/widgets.dart';

import 'article_overview_page_scope.dart';

class ArticleOverviewPage extends StatefulWidget {
  /// Creates a new [ArticleOverviewPage].
  const ArticleOverviewPage({
    super.key,
    required this.article,
  });

  /// The news article to display.
  final NewsArticle article;

  @override
  State<ArticleOverviewPage> createState() => _ArticleOverviewPageState();
}

class _ArticleOverviewPageState extends State<ArticleOverviewPage>
    with SingleTickerProviderStateMixin {
  /// The controller which manages the enter animations.
  late final AnimationController _enterAnimationsController;

  /// The enter animations for the [ArticleOverviewPage].
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

  /// Opens the article's URL in the browser.
  Future<void> _openArticleUrl(
    BuildContext context, {
    required String url,
  }) async {
    final urlLauncher = context.read<UrlLauncher>();

    final canLaunch = await urlLauncher.canLaunch(url);

    if (!context.mounted) return;

    if (!canLaunch) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not open the article. Please check your connection '
            'and try again.',
          ),
        ),
      );

      return;
    }

    await urlLauncher.launch(url);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ArticleOverviewPageScope.of(
        context,
        article: widget.article,
      )..initialize(),
      builder: (context, _) {
        final article = context.watch<ArticleOverviewPageScope>();
        return Scaffold(
          appBar: AppBar(
            title: AnimatedTranslation.vertical(
              animation: _enterAnimations.appBarTitle,
              pixels: 32,
              child: const Text('Article Overview'),
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
            actions: [
              AnimatedTranslation.horizontal(
                animation: _enterAnimations.appBarButton,
                pixels: 24,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: FavoriteIconButton(
                    isFavorite: article.isFavorite(),
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
                      animation: _enterAnimations.articleTitle,
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
                      animation: _enterAnimations.articleAuthor,
                      pixels: 32,
                      child: Text(article.author),
                    ),
                    const SizedBox(height: 16),
                    AnimatedTranslation.vertical(
                      animation: _enterAnimations.divider,
                      pixels: 32,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Divider(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AnimatedTranslation.vertical(
                      animation: _enterAnimations.articleContent,
                      pixels: 32,
                      child: Text(
                        article.content,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 24 / 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    AnimatedTranslation.vertical(
                      animation: _enterAnimations.readMoreButton,
                      pixels: 32,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: ElevatedButton(
                          onPressed: () => _openArticleUrl(
                            context,
                            url: article.url,
                          ),
                          child: const Text('READ MORE'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// The entrance animations for each item on the [ArticleOverviewPage].
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
        articleTitle = CurvedAnimation(
          parent: controller,
          curve: const Interval(0.200, 0.700, curve: Curves.fastOutSlowIn),
        ),
        articleAuthor = CurvedAnimation(
          parent: controller,
          curve: const Interval(0.250, 0.750, curve: Curves.fastOutSlowIn),
        ),
        divider = CurvedAnimation(
          parent: controller,
          curve: const Interval(0.300, 0.800, curve: Curves.fastOutSlowIn),
        ),
        articleContent = CurvedAnimation(
          parent: controller,
          curve: const Interval(0.400, 0.900, curve: Curves.fastOutSlowIn),
        ),
        readMoreButton = CurvedAnimation(
          parent: controller,
          curve: const Interval(0.500, 1.000, curve: Curves.fastOutSlowIn),
        );

  final AnimationController controller;

  final Animation<double> appBarButton;
  final Animation<double> appBarTitle;

  final Animation<double> articleTitle;
  final Animation<double> articleAuthor;
  final Animation<double> divider;
  final Animation<double> articleContent;

  final Animation<double> readMoreButton;
}
