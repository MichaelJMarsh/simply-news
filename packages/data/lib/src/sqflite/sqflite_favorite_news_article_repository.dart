import 'dart:async';

import 'package:domain/domain.dart' hide Database;
import 'package:sqflite/sqflite.dart';

/// The sqflite implementation of [FavoriteNewsArticleRepository].
class SqfliteFavoriteNewsArticleRepository
    implements FavoriteNewsArticleRepository {
  /// Creates a new [SqfliteFavoriteNewsArticleRepository] instance.
  SqfliteFavoriteNewsArticleRepository(this._database);

  /// The sqflite database instance.
  final Database _database;

  /// The name of the [SqfliteFavoriteNewsArticleRepository] table.
  static const tableName = 'favorite_news_articles';

  final StreamController<List<FavoriteNewsArticle>> _eventController =
      StreamController.broadcast();

  @override
  Stream<List<FavoriteNewsArticle>> get changes => _eventController.stream;
  List<FavoriteNewsArticle> _favoriteNewsArticles = [];

  @override
  Future<void> insert(FavoriteNewsArticle favoriteNewsArticle) async {
    await _database.insert(
      tableName,
      favoriteNewsArticle.toSqfliteMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Add to the local list and emit updated state.
    _favoriteNewsArticles.add(favoriteNewsArticle);
    _eventController.add(List.from(_favoriteNewsArticles));
  }

  @override
  Future<void> delete(String articleId) async {
    await _database.delete(
      tableName,
      where: '${FavoriteNewsArticleField.articleId} = ?',
      whereArgs: [articleId],
    );

    // Remove from the local list and emit updated state.
    _favoriteNewsArticles.removeWhere(
      (article) => article.articleId == articleId,
    );
    _eventController.add(List.from(_favoriteNewsArticles));
  }

  @override
  Future<FavoriteNewsArticle?> get(String articleId) async {
    final results = await _database.query(
      tableName,
      where: '${FavoriteNewsArticleField.articleId} = ?',
      whereArgs: [articleId],
    );

    if (results.isEmpty) return null;

    return FavoriteNewsArticle.fromSqfliteMap(results.first);
  }

  @override
  Future<List<FavoriteNewsArticle>> list() async {
    const insertionDateField =
        FavoriteNewsArticleField.insertionDateInMillisecondsSinceEpoch;

    final results = await _database.query(
      tableName,
      orderBy: '$insertionDateField DESC',
    );

    final favoriteNewsArticles =
        results.map(FavoriteNewsArticle.fromSqfliteMap).toList();

    _favoriteNewsArticles = favoriteNewsArticles;

    return favoriteNewsArticles;
  }
}
