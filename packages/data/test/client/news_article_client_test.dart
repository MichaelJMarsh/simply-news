import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:data/src/client/news_article_client.dart';

import 'news_article_client_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<http.Client>(),
])
void main() {
  late MockClient mockHttpClient;
  late NewsArticleClient client;

  const apiKey = 'test-api-key';

  setUp(() {
    mockHttpClient = MockClient();
    // Create the NewsArticleClient with our mock client
    client = NewsArticleClient(apiKey: apiKey, client: mockHttpClient);
  });

  group('NewsArticleClient', () {
    group('fetchSources', () {
      test('returns list of sources when status code is 200 and valid JSON',
          () async {
        final fakeResponse = jsonEncode({
          'status': 'ok',
          'sources': [
            {
              'id': 'abc-news',
              'name': 'ABC News',
              'description': 'Your trusted news source.',
              'url': 'https://abcnews.go.com',
              'category': 'general',
              'language': 'en',
              'country': 'us',
            },
            {
              'id': 'bbc-news',
              'name': 'BBC News',
              'description': 'News from the UK',
              'url': 'http://bbc.co.uk/news',
              'category': 'general',
              'language': 'en',
              'country': 'gb',
            },
          ],
        });

        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response(fakeResponse, 200,
              headers: {'Content-Type': 'application/json'}),
        );

        final sources = await client.fetchSources();
        expect(sources.length, 2);
        expect(sources[0].id, 'abc-news');
        expect(sources[1].name, 'BBC News');
      });

      test('returns empty list if "sources" key not present', () async {
        final fakeResponse = jsonEncode({'status': 'ok'});

        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response(
            fakeResponse,
            200,
            headers: {'Content-Type': 'application/json'},
          ),
        );

        final sources = await client.fetchSources();
        expect(sources, isEmpty);
      });

      test('throws exception if status code != 200', () async {
        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response('Unauthorized', 401),
        );

        expect(
          () => client.fetchSources(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('fetchArticlesBySource', () {
      test('returns SearchResult with articles when status code is 200',
          () async {
        final fakeResponse = jsonEncode({
          'status': 'ok',
          'totalResults': 2,
          'articles': [
            {
              'title': 'Article 1',
              'url': 'https://example.com/1',
            },
            {
              'title': 'Article 2',
              'url': 'https://example.com/2',
            },
          ],
        });

        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response(
            fakeResponse,
            200,
            headers: {'Content-Type': 'application/json'},
          ),
        );

        final result = await client.fetchArticlesBySource(sourceId: 'abc-news');
        expect(result.totalResults, 2);
        expect(result.articles.length, 2);
        expect(result.articles[0].title, 'Article 1');
        expect(result.articles[1].url, 'https://example.com/2');
      });

      test('returns empty result if "articles" key is missing', () async {
        final fakeResponse = jsonEncode({
          'status': 'ok',
          'totalResults': 0,
        });

        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response(fakeResponse, 200),
        );

        final result = await client.fetchArticlesBySource(sourceId: 'abc-news');
        expect(result.articles, isEmpty);
        expect(result.totalResults, 0);
      });

      test('throws exception if status code != 200', () async {
        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response('Bad Request', 400),
        );

        expect(
          () => client.fetchArticlesBySource(sourceId: 'abc-news'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('searchArticles', () {
      test('returns SearchResult with articles when status code is 200',
          () async {
        final fakeResponse = jsonEncode({
          'status': 'ok',
          'totalResults': 2,
          'articles': [
            {
              'title': 'Flutter is great',
              'url': 'https://example.com/flutter',
            },
            {
              'title': 'Dart 3 Released',
              'url': 'https://example.com/dart3',
            },
          ],
        });

        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response(
            fakeResponse,
            200,
            headers: {'Content-Type': 'application/json'},
          ),
        );

        final result = await client.searchArticles(query: 'flutter');
        expect(result.totalResults, 2);
        expect(result.articles.length, 2);
        expect(result.articles[0].title, 'Flutter is great');
      });

      test('returns empty result if no "articles" key in JSON', () async {
        final fakeResponse = jsonEncode({'status': 'ok'});
        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response(fakeResponse, 200),
        );

        final result = await client.searchArticles(query: 'xyz');
        expect(result.articles, isEmpty);
        expect(result.totalResults, 0);
      });

      test('throws exception if status code != 200', () async {
        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response('Internal Server Error', 500),
        );

        expect(
          () => client.searchArticles(query: 'failing'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
