import 'dart:convert';

import 'package:domain/domain.dart';
import 'package:http/http.dart' as http;

const _defaultPage = 1;
const _defaultPageSize = 10;

/// A client for fetching news articles from the News API.
class NewsArticleClient implements NewsArticleService {
  /// Creates a new instance of [NewsArticleClient].
  NewsArticleClient({required String apiKey, http.Client? client})
    : _apiKey = apiKey,
      _client = client ?? http.Client();

  final String _apiKey;
  final http.Client _client;

  static const _baseUrl = 'newsapi.org';

  @override
  Future<List<NewsSource>> fetchSources() async {
    final uri = Uri.https(_baseUrl, '/v2/sources', {'apiKey': _apiKey});
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch sources (status: ${response.statusCode})',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (!data.containsKey('sources')) return [];

    final sourcesJson = data['sources'] as List;
    return sourcesJson
        .map((json) => NewsSource.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<SearchResult> searchArticles({
    required String query,
    String searchIn = 'title',
    String language = 'en',
    String sortBy = 'publishedAt',
    int pageSize = _defaultPageSize,
    int page = _defaultPage,
    String? sourceId,
  }) async {
    final queryParameters = <String, String>{
      'q': query,
      'language': language,
      'sortBy': sortBy,
      'pageSize': pageSize.toString(),
      'page': page.toString(),
      'apiKey': _apiKey,
    };

    if (searchIn.isNotEmpty) {
      queryParameters['searchIn'] = searchIn;
    }

    if (sourceId != null && sourceId.isNotEmpty) {
      queryParameters['sources'] = sourceId;
    }

    final uri = Uri.https(_baseUrl, '/v2/everything', queryParameters);
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to search articles (status: ${response.statusCode})',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (!data.containsKey('articles')) {
      return const SearchResult(articles: [], totalResults: 0);
    }

    final articlesJson = data['articles'] as List;
    final articles =
        articlesJson
            .map((json) => NewsArticle.fromJson(json as Map<String, dynamic>))
            .toList();

    final totalResults = data['totalResults'] as int? ?? articles.length;

    return SearchResult(articles: articles, totalResults: totalResults);
  }
}
