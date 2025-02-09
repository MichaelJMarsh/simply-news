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

  /// The URL to the news article.
  String get url => _article.url ?? '';

  /// The title of the news article.
  String get title => _article.title ?? '';

  /// The author of the news article.
  String get author => _article.author ?? '';

  /// The length at which the News API truncates the content of the news article.
  static const _maxContentLength = 200;

  /// The content of the news article.
  String get content {
    final contentString = _article.content ?? '';
    if (_maxContentLength > contentString.length) return contentString;

    return contentString.substring(0, _maxContentLength);
  }

  /// Returns the [FavoriteNewsArticle], if the user has added the current
  /// news article to their favorites.
  FavoriteNewsArticle? _favoriteNewsArticle;

  Future<void> initialize() async {
    _favoriteNewsArticle = await _getFavoriteNewsArticle();

    notifyListeners();
  }

  /// Whether the current news article is a favorite.
  bool isFavorite() => _favoriteNewsArticle != null;

  /// Toggles the favorite status of the news article with the given [articleId].
  Future<void> toggleFavorite() async {
    if (isFavorite()) {
      await _favoriteNewsArticleRepository.delete(_article);

      _favoriteNewsArticle = null;
    } else {
      final now = clock.now();
      final favoriteNewsArticle = FavoriteNewsArticle(
        article: _article,
        insertionTime: now,
      );

      await _favoriteNewsArticleRepository.insert(
        favoriteNewsArticle,
      );
      _favoriteNewsArticle = favoriteNewsArticle;
    }

    notifyListeners();
  }

  /// Returns the ID for all [FavoriteNewsArticle]s the user added to their
  /// favorites.
  Future<FavoriteNewsArticle?> _getFavoriteNewsArticle() async {
    return _favoriteNewsArticleRepository.get(_article.url ?? '');
  }
}
