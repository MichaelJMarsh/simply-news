import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:domain/domain.dart';
import 'package:provider/provider.dart';

/// A provider-scoped state management class that tracks and updates the
/// user’s favorite news articles in real time using a repository and
/// stream subscription.
class FavoriteArticlesPageScope extends ChangeNotifier {
  /// Creates a new [FavoriteArticlesPageScope].
  FavoriteArticlesPageScope({
    required FavoriteNewsArticleRepository favoriteNewsArticleRepository,
  }) : _favoriteNewsArticleRepository = favoriteNewsArticleRepository;

  /// Creates a new [FavoriteArticlesPageScope] from the [context].
  factory FavoriteArticlesPageScope.of(
    final BuildContext context,
  ) {
    return FavoriteArticlesPageScope(
      favoriteNewsArticleRepository: context.read(),
    );
  }

  final FavoriteNewsArticleRepository _favoriteNewsArticleRepository;

  /// The subscription which listens to changes in favorite news articles.
  StreamSubscription<List<FavoriteNewsArticle>>?
      _favoriteNewsArticleStreamSubscription;

  /// Whether the [FavoriteArticlesPageScope] is loading.
  bool get isLoading => _isLoading;
  bool _isLoading = true;

  /// The URL to the news article.
  int get count => _list?.length ?? 0;

  /// Returns the [FavoriteNewsArticle], if the user has added the current
  /// news article to their favorites.
  List<NewsArticle> get list => _list ?? [];
  List<NewsArticle>? _list;

  Future<void> initialize() async {
    final favoriteNewsArticles = await _favoriteNewsArticleRepository.list();
    _list = _getFavorites(favoriteNewsArticles);

    _initializeFavoriteNewsArticleStreamSubscription();

    _isLoading = false;

    notifyListeners();
  }

  @override
  void dispose() {
    _favoriteNewsArticleStreamSubscription?.cancel();

    super.dispose();
  }

  /// Subscribes to favorite article changes
  void _initializeFavoriteNewsArticleStreamSubscription() {
    _favoriteNewsArticleStreamSubscription =
        _favoriteNewsArticleRepository.changes.listen((favoriteNewsArticles) {
      _list = _getFavorites(favoriteNewsArticles);

      notifyListeners();
    });
  }

  /// Returns whether the given [articleUrl] is marked as favorite.
  bool isFavorite(NewsArticle article) {
    return list.any((newsArticle) => newsArticle == article);
  }

  /// Removes the given [article] from the favorites.
  Future<void> removeFavorite(NewsArticle article) async {
    await _favoriteNewsArticleRepository.delete(article);

    notifyListeners();
  }

  /// Returns the list of [NewsArticle]s from the given [favoriteNewsArticles].
  List<NewsArticle> _getFavorites(
    List<FavoriteNewsArticle> favoriteNewsArticles,
  ) {
    return favoriteNewsArticles
        .map((favoriteNewsArticle) => favoriteNewsArticle.article)
        .whereType<NewsArticle>()
        .toList();
  }
}
