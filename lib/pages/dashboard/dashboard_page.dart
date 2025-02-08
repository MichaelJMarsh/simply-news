import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'dashboard_page_scope.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

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
          final dashboardScope = context.watch<DashboardPageScope>();
          final isLoading = dashboardScope.isLoading;

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
                        padding: EdgeInsets.only(
                          bottom: bottomPadding,
                        ),
                        sliver: SliverList.separated(
                          itemCount: dashboardScope.newsArticles.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final newsArticle =
                                dashboardScope.newsArticles[index];

                            return ListTile(
                              title: Text(newsArticle.title ?? ''),
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
