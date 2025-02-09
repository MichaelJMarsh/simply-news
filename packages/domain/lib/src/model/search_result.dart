import 'package:flutter/foundation.dart';

import 'package:collection/collection.dart';

import 'news_article.dart';

/// A class that represents a collection of news articles and the total result count.
@immutable
class SearchResult {
  /// Creates a new [SearchResult].
  const SearchResult({
    required this.articles,
    required this.totalResults,
  });

  /// The list of news articles.
  final List<NewsArticle> articles;

  /// The total number of results found for the search.
  final int totalResults;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SearchResult &&
        other.runtimeType == runtimeType &&
        const ListEquality().equals(other.articles, articles) &&
        other.totalResults == totalResults;
  }

  @override
  int get hashCode {
    return runtimeType.hashCode ^
        const ListEquality().hash(articles) ^
        totalResults.hashCode;
  }
}

/// Contains the field names of the [SearchResult].
@immutable
abstract class SearchResultField {
  const SearchResultField._();

  static const articles = 'articles';
  static const totalResults = 'totalResults';
}
