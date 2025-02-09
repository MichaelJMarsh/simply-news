import 'package:domain/domain.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:data/src/sqflite/sqflite_database.dart';
import 'package:data/src/sqflite/sqflite_favorite_news_article_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SqfliteFavoriteNewsArticleRepository', () {
    final database = SqfliteDatabase(path: inMemoryDatabasePath);

    setUpAll(() async {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

      await database.open();
    });

    setUp(() async {
      await database.instance.delete(
        SqfliteFavoriteNewsArticleRepository.tableName,
      );
    });

    tearDownAll(() async {
      await database.close();
    });

    test('insert -> get -> delete -> get returns null', () async {
      final repository =
          SqfliteFavoriteNewsArticleRepository(database.instance);

      const article = NewsArticle(
        url: 'https://example.com/my-article',
        title: 'My Article',
        author: 'John Doe',
        content: 'Lorem ipsum',
      );

      final favorite = FavoriteNewsArticle(
        article: article,
        insertionTime: DateTime(2023, 5, 1),
      );

      expect(await repository.get(article.url), isNull);

      await repository.insert(favorite);
      expect(await repository.get(article.url), equals(favorite));

      await repository.delete(article);
      expect(await repository.get(article.url), isNull);
    });

    test('list favorites in descending order by insertion time', () async {
      final repository =
          SqfliteFavoriteNewsArticleRepository(database.instance);

      final favorites = [
        FavoriteNewsArticle(
          article: const NewsArticle(
            url: 'https://example.com/1',
            title: 'Article 1',
          ),
          insertionTime: DateTime(2023, 5, 3),
        ),
        FavoriteNewsArticle(
          article: const NewsArticle(
            url: 'https://example.com/2',
            title: 'Article 2',
          ),
          insertionTime: DateTime(2023, 5, 2),
        ),
        FavoriteNewsArticle(
          article: const NewsArticle(
            url: 'https://example.com/3',
            title: 'Article 3',
          ),
          insertionTime: DateTime(2023, 5, 1),
        ),
      ];

      for (final entry in favorites) {
        await repository.insert(entry);
      }

      final actual = await repository.list();

      // Verify the order.
      expect(actual, favorites);
    });
  });
}
