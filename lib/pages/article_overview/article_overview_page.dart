import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'article_overview_page_scope.dart';

class ArticleOverviewPage extends StatelessWidget {
  /// Creates a new [ArticleOverviewPage].
  const ArticleOverviewPage({
    super.key,
    required this.article,
  });

  /// The news article to display.
  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Article Overview'),
      ),
      body: ChangeNotifierProvider(
        create: (context) => ArticleOverviewPageScope.of(
          context,
          article: article,
        )..initialize(),
        builder: (context, _) {
          final article = context.watch<ArticleOverviewPageScope>();
          final isLoading = article.isLoading;

          return AnimatedSwitcher(
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            duration: const Duration(milliseconds: 450),
            child: isLoading
                ? Center(
                    key: Key(
                      'loading_indicator.${isLoading ? 'visible' : 'hidden'}',
                    ),
                    child: const Text('Loading article overview...'),
                  )
                : CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverList.list(
                        children: [
                          Text(article.title),
                          const SizedBox(height: 8),
                          Text(article.author),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 24),
                          Text(article.content),
                        ],
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
