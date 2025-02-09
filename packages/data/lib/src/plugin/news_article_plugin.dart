import 'dart:convert';

import 'package:domain/domain.dart';
import 'package:http/http.dart' as http;

class NewsArticlePlugin implements NewsArticleService {
  /// Creates a new [NewsArticlePlugin].
  const NewsArticlePlugin({required String apiKey}) : _apiKey = apiKey;

  /// The API key to use for requests.
  final String _apiKey;

  static const _baseUrl = 'newsapi.org';

  @override
  Future<List<NewsArticle>> searchArticles({
    required String query,
    String searchIn = 'title,description,content',
    String language = 'en',
    String sortBy = 'publishedAt',
    int pageSize = 10,
    int page = 1,
  }) async {
    final queryParameters = {
      'q': query,
      'searchIn': searchIn,
      'language': language,
      'sortBy': sortBy,
      'pageSize': pageSize.toString(),
      'page': page.toString(),
      'apiKey': _apiKey,
    };

    final uri = Uri.https(_baseUrl, '/v2/everything', queryParameters);
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch articles (status: ${response.statusCode})',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (!data.containsKey('articles')) return [];

    final articlesJson = data['articles'] as List<dynamic>;
    return articlesJson
        .map((json) => NewsArticle.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
