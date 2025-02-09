import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:domain/domain.dart';

void main() {
  group('FavoriteNewsArticle', () {
    const testArticle = NewsArticle(
      title: 'Test Title',
      author: 'Test Author',
      description: 'Test Description',
      url: 'https://example.com',
      urlToImage: 'https://example.com/image.jpg',
      publishedAt: null,
      content: 'Test Content',
    );

    final testFavorite = FavoriteNewsArticle(
      article: testArticle,
      insertionTime: DateTime(2023, 5, 1, 12, 0, 0),
    );

    test('correctly stores and retrieves values', () {
      const testArticle = NewsArticle(
        title: 'Test Title',
        url: 'https://example.com',
      );

      final favoriteNewsArticle = FavoriteNewsArticle(
        article: testArticle,
        insertionTime: DateTime(2023, 5, 1, 12, 0, 0),
      );

      expect(favoriteNewsArticle.article.title, 'Test Title');
      expect(favoriteNewsArticle.article.url, 'https://example.com');
      expect(
        favoriteNewsArticle.insertionTime,
        DateTime(2023, 5, 1, 12, 0, 0),
      );

      final map = favoriteNewsArticle.toSqfliteMap();
      expect(
        jsonDecode(map[FavoriteNewsArticleField.article] as String),
        equals(testArticle.toJson()),
      );
      expect(
        map[FavoriteNewsArticleField.insertionDateInMillisecondsSinceEpoch],
        favoriteNewsArticle.insertionTime.millisecondsSinceEpoch,
      );
    });

    test('toSqfliteMap returns correct map representation', () {
      final map = testFavorite.toSqfliteMap();

      expect(map[FavoriteNewsArticleField.article], isA<String>());
      expect(
        jsonDecode(map[FavoriteNewsArticleField.article] as String),
        equals(testArticle.toJson()),
      );
      expect(
        map[FavoriteNewsArticleField.insertionDateInMillisecondsSinceEpoch],
        testFavorite.insertionTime.millisecondsSinceEpoch,
      );
    });

    test('fromSqfliteMap reconstructs FavoriteNewsArticle', () {
      final sqfliteMap = {
        FavoriteNewsArticleField.article: jsonEncode(testArticle.toJson()),
        FavoriteNewsArticleField.insertionDateInMillisecondsSinceEpoch:
            testFavorite.insertionTime.millisecondsSinceEpoch,
      };

      final favoriteFromMap = FavoriteNewsArticle.fromSqfliteMap(sqfliteMap);

      expect(favoriteFromMap, equals(testFavorite));
      expect(favoriteFromMap.article.url, equals('https://example.com'));
      expect(favoriteFromMap.insertionTime, testFavorite.insertionTime);
    });

    test('equality and hashCode', () {
      final sameFavorite = FavoriteNewsArticle(
        article: testArticle,
        insertionTime: DateTime(2023, 5, 1, 12, 0, 0),
      );

      // Different insertion time
      final differentFavorite = FavoriteNewsArticle(
        article: testArticle,
        insertionTime: DateTime(2023, 5, 2, 12, 0, 0),
      );

      expect(testFavorite, equals(sameFavorite));
      expect(testFavorite.hashCode, equals(sameFavorite.hashCode));
      expect(testFavorite, isNot(equals(differentFavorite)));
    });
  });
}
