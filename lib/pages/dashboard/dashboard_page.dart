import 'package:flutter/material.dart';

import 'package:domain/domain.dart';
import 'package:provider/provider.dart';

import 'package:simply_news/pages/article_overview/article_overview_page.dart';

import 'dashboard_page_scope.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

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
        title: const Text('Simply News Dashboard'),
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
                ? Center(
                    key: Key(
                      'loading_indicator.${isLoading ? 'visible' : 'hidden'}',
                    ),
                    child: const Text('Loading news articles...'),
                  )
                : CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        sliver: SliverToBoxAdapter(
                          child: SearchBar(
                            key: const Key('search_bar'),
                            hintText: 'Search for news articles...',
                            onChanged: dashboard.searchNewsArticles,
                            onSubmitted: dashboard.searchNewsArticles,
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

                            final author = newsArticle.author ?? '';

                            return ListTile(
                              onTap: () => _openArticleOverview(
                                context,
                                article: newsArticle,
                              ),
                              title: Text(newsArticle.title ?? ''),
                              subtitle: author.isNotEmpty ? Text(author) : null,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 8,
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
