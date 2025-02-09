import 'package:domain/src/model/news_source.dart';
import 'package:domain/src/model/search_result.dart';

/// The interface for accessing news articles.
abstract class NewsArticleService {
  const NewsArticleService._();

  /// Returns a list of all available news sources.
  Future<List<NewsSource>> fetchSources();

  /// Returns a [SearchResult] (articles + total count) from the given [sourceId].
  ///
  /// If [sourceId] is null/empty, fetch from all sources.
  Future<SearchResult> fetchArticlesBySource({
    required String sourceId,
    int pageSize,
    int page,
  });

  /// Returns a [SearchResult] (articles + total count) from the given [query].
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
  Future<SearchResult> searchArticles({
    required String query,
    String searchIn,
    String language,
    String sortBy,
    int pageSize,
    int page,
    String? sourceId,
  });
}
