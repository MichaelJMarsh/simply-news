import 'package:domain/src/model/favorite_news_article.dart';

/// The interface for accessing favorited news articles (see [FavoriteAction]).
abstract class FavoriteNewsArticleRepository {
  const FavoriteNewsArticleRepository._();

  /// A listenable stream that emits an updated list of favorite news articles
  /// every time the database changes.
  Stream<List<FavoriteNewsArticle>> get changes;

  /// Adds a favorite news article to the database.
  Future<void> insert(FavoriteNewsArticle favoriteNewsArticle);

  /// Removes a favorite news article from the database.
  Future<void> delete(String actionId);

  /// Gets a favorite news article from the database.
  Future<FavoriteNewsArticle?> get(String actionId);

  /// Returns a list of all favorite news articles.
  Future<List<FavoriteNewsArticle>> list();
}
