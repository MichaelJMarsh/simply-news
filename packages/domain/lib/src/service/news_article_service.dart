import 'package:domain/src/model/news_article.dart';

/// The interface for accessing news articles.
abstract class NewsArticleService {
  const NewsArticleService._();

  /// Returns a list of [NewsArticle]s for the given [query].
  ///
  /// The [searchIn] parameter specifies the fields to search in.
  ///
  /// The [language] parameter specifies the language of the articles.
  ///
  /// The [sortBy] parameter specifies the sorting order of the articles.
  ///
  /// The [pageSize] parameter specifies the number of articles to return.
  ///
  /// The [page] parameter specifies the page number to return.
  Future<List<NewsArticle>> searchArticles({
    required String query,
    String searchIn = 'title,description,content', // Search in all fields
    String language = 'en',
    String sortBy = 'publishedAt',
    int pageSize = 10,
    int page = 1,
  });
}
