import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:domain/domain.dart';
import 'package:http/http.dart' as http;

class NewsApiPlugin implements NewsArticleService {
  // Ideally you’d load this securely, e.g. from .env or Firebase Remote Config
  static const _apiKey = '0f342d6f6e5b43ddae29a80e1e039131';
  static const _baseUrl = 'newsapi.org';

  @override
  Future<NewsArticle?> get(String id) async {
    final articles = await list();

    final newsArticle = articles.firstWhereOrNull(
      (newArticle) => newArticle.id == id,
    );

    return newsArticle;
  }

  @override
  Future<List<NewsArticle>> list({
    String countryCode = 'US',
    int pageSize = 20,
  }) async {
    final queryParameters = {
      'country': countryCode,
      'pageSize': pageSize.toString(),
      'apiKey': _apiKey,
    };

    final uri = Uri.https(_baseUrl, '/v2/top-headlines', queryParameters);
    final response = await http.get(uri);

    final isNotSuccessfulResponse = response.statusCode != 200;
    if (isNotSuccessfulResponse) {
      throw Exception(
        'Failed to fetch articles (status: ${response.statusCode})',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final articlesJson = data['articles'] as List<dynamic>;

    return articlesJson
        .map((json) => NewsArticle.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
