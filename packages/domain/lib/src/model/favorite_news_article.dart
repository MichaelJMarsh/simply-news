import 'package:flutter/foundation.dart';

/// A class that represents a favorite eco action.
@immutable
class FavoriteNewsArticle {
  /// Creates a new [FavoriteNewsArticle].
  const FavoriteNewsArticle({
    required this.articleId,
    required this.insertionTime,
  });

  /// Creates a new [FavoriteNewsArticle] from a Sqflite map.
  factory FavoriteNewsArticle.fromSqfliteMap(Map<String, dynamic> map) {
    return FavoriteNewsArticle(
      articleId: map[FavoriteNewsArticleField.articleId] as String,
      insertionTime: DateTime.fromMillisecondsSinceEpoch(
        map[FavoriteNewsArticleField.insertionDateInMillisecondsSinceEpoch]
            as int,
      ),
    );
  }

  /// The ID of the corresponding [EcoAction].
  final String articleId;

  /// The time when the eco action was added to the favorites.
  final DateTime insertionTime;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FavoriteNewsArticle &&
        other.runtimeType == runtimeType &&
        other.articleId == articleId &&
        other.insertionTime == insertionTime;
  }

  @override
  int get hashCode {
    return runtimeType.hashCode ^ articleId.hashCode ^ insertionTime.hashCode;
  }

  /// Converts a [FavoriteNewsArticle] to a Sqflite map.
  Map<String, dynamic> toSqfliteMap() {
    return {
      FavoriteNewsArticleField.articleId: articleId,
      FavoriteNewsArticleField.insertionDateInMillisecondsSinceEpoch:
          insertionTime.millisecondsSinceEpoch,
    };
  }
}

/// Contains the field names of the [FavoriteNewsArticle] table.
@immutable
abstract class FavoriteNewsArticleField {
  const FavoriteNewsArticleField._();

  static const articleId = 'article_id';
  static const insertionDateInMillisecondsSinceEpoch =
      'insertion_date_in_milliseconds_since_epoch';
}
