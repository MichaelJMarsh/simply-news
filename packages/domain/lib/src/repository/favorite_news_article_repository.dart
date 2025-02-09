import 'package:domain/src/model/favorite_news_article.dart';
import 'package:domain/src/model/news_article.dart';

/// The interface for accessing favorited news articles (see [FavoriteNewsArticle]).
abstract class FavoriteNewsArticleRepository {
  const FavoriteNewsArticleRepository._();

  /// A listenable stream that emits an updated list of favorite news articles
  /// every time the database changes.
  Stream<List<FavoriteNewsArticle>> get changes;

  /// Adds the given [favoriteNewsArticle] to the database.
  Future<void> insert(FavoriteNewsArticle favoriteNewsArticle);

  /// Removes the givne [newsArticle] from the database.
  Future<void> delete(NewsArticle newsArticle);

  /// Returns the corresponding [FavoriteNewsArticle] from the database, which
  /// matches the given [articleUrl].
  Future<FavoriteNewsArticle?> get(String articleUrl);

  /// Returns a list of all favorite news articles.
  Future<List<FavoriteNewsArticle>> list();
}
