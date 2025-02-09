import 'dart:async';
import 'dart:convert';

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
  Future<void> insert(FavoriteNewsArticle? favoriteNewsArticle) async {
    if (favoriteNewsArticle == null) return;

    await _database.insert(
      tableName,
      {
        FavoriteNewsArticleField.article: jsonEncode(
          favoriteNewsArticle.article.toJson(),
        ),
        FavoriteNewsArticleField.insertionDateInMillisecondsSinceEpoch:
            favoriteNewsArticle.insertionTime.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Remove from the local list and emit updated state.
    _favoriteNewsArticles.add(favoriteNewsArticle);
    _eventController.add(List.from(_favoriteNewsArticles));
  }

  @override
  Future<void> delete(NewsArticle? newsArticle) async {
    if (newsArticle == null) return;

    await _database.delete(
      tableName,
      where: '${FavoriteNewsArticleField.article} LIKE ?',
      whereArgs: ['%"${newsArticle.url}"%'],
    );

    _favoriteNewsArticles.removeWhere(
      (favoriteNewsArticle) {
        return favoriteNewsArticle.article.url == newsArticle.url;
      },
    );
    _eventController.add(List.from(_favoriteNewsArticles));
  }

  @override
  Future<FavoriteNewsArticle?> get(String? articleUrl) async {
    if (articleUrl == null) return null;

    final results = await _database.query(
      tableName,
      where: '${FavoriteNewsArticleField.article} LIKE ?',
      whereArgs: ['%"$articleUrl"%'],
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

    final favoriteNewsArticles = results.map((map) {
      final jsonArticle =
          jsonDecode(map[FavoriteNewsArticleField.article] as String)
              as Map<String, dynamic>;
      return FavoriteNewsArticle(
        article: NewsArticle.fromJson(jsonArticle),
        insertionTime: DateTime.fromMillisecondsSinceEpoch(
          map[FavoriteNewsArticleField.insertionDateInMillisecondsSinceEpoch]
              as int,
        ),
      );
    }).toList();

    _favoriteNewsArticles = favoriteNewsArticles;
    return favoriteNewsArticles;
  }
}
