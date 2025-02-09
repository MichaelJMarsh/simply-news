import 'package:flutter/material.dart';

import 'package:domain/domain.dart';

import 'package:simply_news/widgets/widgets.dart';

class NewsArticleCard extends StatelessWidget {
  /// Creates a new [NewsArticleCard].
  const NewsArticleCard({
    super.key,
    required this.article,
    required this.isFavorite,
    required this.onFavorite,
    required this.onPressed,
  });

  /// The news article to display.
  final NewsArticle article;

  /// Whether the news article is a favorite.
  final bool isFavorite;

  /// The function called when the user taps on the news article.
  final VoidCallback onFavorite;

  /// The function called when the user taps on the news article.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final author = article.author ?? '';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onPressed,
        splashFactory: InkRipple.splashFactory,
        splashColor: colorScheme.primary.withValues(alpha: 0.16),
        highlightColor: Colors.transparent,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      article.title ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  FavoriteIconButton(
                    isFavorite: isFavorite,
                    onPressed: onFavorite,
                  ),
                ],
              ),
              if (author.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    author,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
