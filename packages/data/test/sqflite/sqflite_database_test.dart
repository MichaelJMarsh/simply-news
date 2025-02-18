import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:data/src/sqflite/sqflite_database.dart';
import 'package:data/src/sqflite/sqflite_favorite_news_article_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SqfliteDatabase', () {
    setUpAll(() {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    test(
      'opens database and creates the favorite_news_articles table',
      () async {
        final db = SqfliteDatabase(path: inMemoryDatabasePath);

        await db.open();
        expect(db.instance.isOpen, isTrue);

        final tables = await db.instance.rawQuery(
          'SELECT name FROM sqlite_master WHERE type = "table"',
        );
        final tableNames = tables.map((row) => row['name']).cast<String>();
        expect(
          tableNames,
          contains(SqfliteFavoriteNewsArticleRepository.tableName),
          reason: 'Expected the favorite_news_articles table to be created',
        );

        final columns = await db.instance.rawQuery(
          'PRAGMA table_info(${SqfliteFavoriteNewsArticleRepository.tableName})',
        );

        final columnNames = columns.map((col) => col['name'] as String).toSet();
        expect(
          columnNames,
          containsAll({
            FavoriteNewsArticleField.article,
            FavoriteNewsArticleField.insertionDateInMillisecondsSinceEpoch,
          }),
        );

        await db.close();
        expect(db.instance.isOpen, isFalse);
      },
    );
  });
}
