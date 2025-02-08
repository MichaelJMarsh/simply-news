import 'package:domain/src/model/news_article.dart';

/// The interface for accessing news articles.
abstract class NewsArticleService {
  const NewsArticleService._();

  /// Returns a [NewsArticle] for the given [id], if it exists.
  Future<NewsArticle?> get(String id);

  /// Returns a list of [NewsArticle]s for the given [country].
  ///
  /// The [countryCode] is a two-letter ISO 3166-1 code that represents the country
  /// for which you want to fetch the news articles.
  ///
  /// The [pageSize] is used to specify the number of articles to fetch.
  Future<List<NewsArticle>> list({
    String countryCode = 'US',
    int pageSize = 20,
  });
}
