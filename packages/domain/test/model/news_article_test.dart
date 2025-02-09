import 'package:flutter_test/flutter_test.dart';
import 'package:domain/domain.dart';

void main() {
  group('NewsArticle', () {
    final testJson = {
      NewsArticleField.title: 'Test Title',
      NewsArticleField.author: 'Test Author',
      NewsArticleField.description: 'Test Description',
      NewsArticleField.url: 'https://example.com',
      NewsArticleField.urlToImage: 'https://example.com/image.jpg',
      NewsArticleField.publishedAt: null,
      NewsArticleField.content: 'Test Content',
    };

    const expectedArticle = NewsArticle(
      title: 'Test Title',
      author: 'Test Author',
      description: 'Test Description',
      url: 'https://example.com',
      urlToImage: 'https://example.com/image.jpg',
      publishedAt: null,
      content: 'Test Content',
    );

    test('correctly stores and retrieves values', () {
      const article = NewsArticle(
        title: 'Test News',
        author: 'John Doe',
        description: 'Breaking news!',
        url: 'https://news.com/article',
        urlToImage: 'https://news.com/image.jpg',
        publishedAt: null,
        content: 'Detailed news content here.',
      );

      expect(article.title, 'Test News');
      expect(article.author, 'John Doe');
      expect(article.description, 'Breaking news!');
      expect(article.url, 'https://news.com/article');
      expect(article.urlToImage, 'https://news.com/image.jpg');
      expect(article.publishedAt, isNull);
      expect(article.content, 'Detailed news content here.');

      final json = article.toJson();
      expect(json[NewsArticleField.title], 'Test News');
      expect(json[NewsArticleField.author], 'John Doe');
      expect(json[NewsArticleField.description], 'Breaking news!');
      expect(json[NewsArticleField.url], 'https://news.com/article');
      expect(json[NewsArticleField.urlToImage], 'https://news.com/image.jpg');
    });

    test('fromJson constructs correctly', () {
      final article = NewsArticle.fromJson(testJson);
      expect(article, equals(expectedArticle));
    });

    test('toJson returns correct map', () {
      const article = expectedArticle;
      final json = article.toJson();
      expect(json, equals(testJson));
    });

    test('equality and hashCode', () {
      const sameArticle = NewsArticle(
        title: 'Test Title',
        author: 'Test Author',
        description: 'Test Description',
        url: 'https://example.com',
        urlToImage: 'https://example.com/image.jpg',
        publishedAt: null,
        content: 'Test Content',
      );

      const differentArticle = NewsArticle(title: 'Another Title');

      expect(expectedArticle, equals(sameArticle));
      expect(expectedArticle.hashCode, equals(sameArticle.hashCode));
      expect(expectedArticle, isNot(equals(differentArticle)));
    });
  });
}
