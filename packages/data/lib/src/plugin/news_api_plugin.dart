import 'dart:convert';

import 'package:domain/domain.dart';
import 'package:http/http.dart' as http;

class NewsApiPlugin implements NewsArticleService {
  // Ideally you’d load this securely, e.g. from .env or Firebase Remote Config
  static const _apiKey = '0f342d6f6e5b43ddae29a80e1e039131';
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
      print(
          'Error fetching articles: ${response.statusCode} - ${response.body}');
      throw Exception(
        'Failed to fetch articles (status: ${response.statusCode})',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (!data.containsKey('articles')) {
      print('Unexpected API response: $data');
      return [];
    }

    final articlesJson = data['articles'] as List<dynamic>;
    print('🔍 Found ${articlesJson.length} articles for query "$query"');

    return articlesJson
        .map((json) => NewsArticle.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
