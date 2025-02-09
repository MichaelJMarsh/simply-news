import 'package:domain/domain.dart';
import 'package:sqflite/sqflite.dart' as sql;

import 'sqflite_favorite_news_article_repository.dart';

/// The sqflite implementation of [Database].
class SqfliteDatabase implements Database {
  /// Creates a new [SqfliteDatabase] instance.
  SqfliteDatabase({required String path}) : _path = path;

  /// The path to the database file.
  final String _path;

  /// The current database version.
  static const _version = 1;

  /// The sqflite database instance.
  late final sql.Database instance;

  @override
  Future<void> open() async {
    instance = await sql.openDatabase(
      _path,
      version: _version,
      onCreate: _onCreate,
    );
  }

  /// Creates the database schema and inserts initial data.
  Future<void> _onCreate(sql.Database database, int version) async {
    return database.transaction((transaction) async {
      // Create database tables.
      await transaction.createFavoriteNewsArticleTable();
    });
  }

  @override
  Future<void> close() async {
    await instance.close();
  }
}

/// Helper class for creating the database schema.
extension _CreateDatabase on sql.Transaction {
  /// Creates the database table for the favorite news article repository.
  Future<void> createFavoriteNewsArticleTable() async {
    return execute('''
      CREATE TABLE ${SqfliteFavoriteNewsArticleRepository.tableName} (
        ${FavoriteNewsArticleField.article} TEXT NOT NULL PRIMARY KEY,
        ${FavoriteNewsArticleField.insertionDateInMillisecondsSinceEpoch} INTEGER NOT NULL
      )
    ''');
  }
}
