import 'package:flutter_test/flutter_test.dart';
import 'package:domain/domain.dart';

void main() {
  group('NewsSource', () {
    final testJson = {
      NewsSourceField.id: 'abc-news',
      NewsSourceField.name: 'ABC News',
      NewsSourceField.description: 'Some description',
      NewsSourceField.url: 'https://abcnews.go.com',
      NewsSourceField.category: 'general',
      NewsSourceField.language: 'en',
      NewsSourceField.country: 'us',
    };

    const expectedSource = NewsSource(
      id: 'abc-news',
      name: 'ABC News',
      description: 'Some description',
      url: 'https://abcnews.go.com',
      category: 'general',
      language: 'en',
      country: 'us',
    );

    test('correctly stores and retrieves values', () {
      const article1 = NewsArticle(title: 'Article 1', url: 'https://1.com');
      const article2 = NewsArticle(title: 'Article 2', url: 'https://2.com');

      const searchResult = SearchResult(
        articles: [article1, article2],
        totalResults: 100,
      );

      expect(searchResult.articles, hasLength(2));
      expect(searchResult.articles[0].title, 'Article 1');
      expect(searchResult.articles[1].title, 'Article 2');
      expect(searchResult.totalResults, 100);
    });

    test('fromJson constructs correctly', () {
      final source = NewsSource.fromJson(testJson);
      expect(source, equals(expectedSource));
    });

    test('toJson returns correct map', () {
      final json = expectedSource.toJson();
      expect(json, equals(testJson));
    });

    test('equality and hashCode', () {
      const sameSource = NewsSource(
        id: 'abc-news',
        name: 'ABC News',
        description: 'Some description',
        url: 'https://abcnews.go.com',
        category: 'general',
        language: 'en',
        country: 'us',
      );

      const differentSource = NewsSource(
        id: 'bbc-news',
        name: 'BBC News',
      );

      expect(expectedSource, equals(sameSource));
      expect(expectedSource.hashCode, equals(sameSource.hashCode));
      expect(expectedSource, isNot(equals(differentSource)));
    });
  });
}
