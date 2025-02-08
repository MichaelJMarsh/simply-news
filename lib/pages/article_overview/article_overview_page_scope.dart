import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:clock/clock.dart';
import 'package:domain/domain.dart';
import 'package:provider/provider.dart';

class ArticleOverviewPageScope extends ChangeNotifier {
  /// Creates a new [ArticleOverviewPageScope].
  ArticleOverviewPageScope({
    required NewsArticle article,
    required FavoriteNewsArticleRepository favoriteNewsArticleRepository,
  })  : _article = article,
        _favoriteNewsArticleRepository = favoriteNewsArticleRepository;

  /// Creates a new [ArticleOverviewPageScope] from the [context].
  factory ArticleOverviewPageScope.of(
    final BuildContext context, {
    required NewsArticle article,
  }) {
    return ArticleOverviewPageScope(
      article: article,
      favoriteNewsArticleRepository: context.read(),
    );
  }

  final NewsArticle _article;

  final FavoriteNewsArticleRepository _favoriteNewsArticleRepository;

  /// The news article to display.
  NewsArticle? _newsArticle;

  /// The title of the news article.
  String get title => _newsArticle?.title ?? '';

  /// The author of the news article.
  String get author => _newsArticle?.author ?? '';

  /// The content of the news article.
  String get content => _newsArticle?.content ?? '';

  /// Returns the [NewsArticle] ID, if the user has added the current
  /// news article to their favorites.
  String? _favoriteNewsArticleId;

  /// Whether the dashboard page is loading.
  bool get isLoading => _isLoading;
  bool _isLoading = true;

  Future<void> initialize() async {
    _favoriteNewsArticleId = await _getFavoriteNewsArticleId();

    _isLoading = false;

    notifyListeners();
  }

  /// Whether the current news article is a favorite.
  bool isFavorite() => _favoriteNewsArticleId != null;

  /// Toggles the favorite status of the news article with the given [articleId].
  Future<void> toggleFavorite() async {
    final articleId = _article.id;

    if (isFavorite()) {
      await _favoriteNewsArticleRepository.delete(articleId);

      _favoriteNewsArticleId = null;
    } else {
      final now = clock.now();
      await _favoriteNewsArticleRepository.insert(
        FavoriteNewsArticle(
          articleId: articleId,
          insertionTime: now,
        ),
      );

      _favoriteNewsArticleId = articleId;
    }

    notifyListeners();
  }

  /// Returns the ID for all [FavoriteNewsArticle]s the user added to their
  /// favorites.
  Future<String?> _getFavoriteNewsArticleId() async {
    final favoriteNewsArticle =
        await _favoriteNewsArticleRepository.get(_article.id);

    return favoriteNewsArticle?.articleId;
  }
}
