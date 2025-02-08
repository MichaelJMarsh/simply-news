import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'news_article.dart';

/// A class that represents a favorite news article.
@immutable
class FavoriteNewsArticle {
  /// Creates a new [FavoriteNewsArticle].
  const FavoriteNewsArticle({
    required this.article,
    required this.insertionTime,
  });

  /// Creates a new [FavoriteNewsArticle] from a Sqflite map.
  factory FavoriteNewsArticle.fromSqfliteMap(Map<String, dynamic> map) {
    return FavoriteNewsArticle(
      article: NewsArticle.fromJson(
        jsonDecode(map[FavoriteNewsArticleField.article])
            as Map<String, dynamic>,
      ),
      insertionTime: DateTime.fromMillisecondsSinceEpoch(
        map[FavoriteNewsArticleField.insertionDateInMillisecondsSinceEpoch]
            as int,
      ),
    );
  }

  /// The ID of the corresponding [FavoriteNewsArticle].
  final NewsArticle article;

  /// The time when the news article was added to the favorites.
  final DateTime insertionTime;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FavoriteNewsArticle &&
        other.runtimeType == runtimeType &&
        other.article == article &&
        other.insertionTime == insertionTime;
  }

  @override
  int get hashCode {
    return runtimeType.hashCode ^ article.hashCode ^ insertionTime.hashCode;
  }

  /// Converts a [FavoriteNewsArticle] to a Sqflite map.
  Map<String, dynamic> toSqfliteMap() {
    return {
      FavoriteNewsArticleField.article: jsonEncode(article.toJson()),
      FavoriteNewsArticleField.insertionDateInMillisecondsSinceEpoch:
          insertionTime.millisecondsSinceEpoch,
    };
  }
}

/// Contains the field names of the [FavoriteNewsArticle] table.
@immutable
abstract class FavoriteNewsArticleField {
  const FavoriteNewsArticleField._();

  static const article = 'article';
  static const insertionDateInMillisecondsSinceEpoch =
      'insertion_date_in_milliseconds_since_epoch';
}
