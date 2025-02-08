import 'package:flutter/foundation.dart';

/// A class that represents a news article.
@immutable
class NewsArticle {
  /// Creates a new [NewsArticle].
  const NewsArticle({
    required this.title,
    this.author,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
  });

  /// The title of the article.
  final String? title;

  /// The author of the article.
  final String? author;

  /// The description of the article.
  final String? description;

  /// The URL of the article.
  final String? url;

  /// The URL to the image of the article.
  final String? urlToImage;

  /// The time when the article was published.
  final DateTime? publishedAt;

  /// The content of the article.
  final String? content;

  /// Creates a new [NewsArticle] from a JSON object.
  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json[NewsArticleField.title] as String? ?? '',
      author: json[NewsArticleField.author] as String?,
      description: json[NewsArticleField.description] as String?,
      url: json[NewsArticleField.url] as String?,
      urlToImage: json[NewsArticleField.urlToImage] as String?,
      publishedAt: json[NewsArticleField.publishedAt] != null
          ? DateTime.tryParse(json[NewsArticleField.publishedAt])
          : null,
      content: json[NewsArticleField.content] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NewsArticle &&
        other.runtimeType == runtimeType &&
        other.title == title &&
        other.author == author &&
        other.description == description &&
        other.url == url &&
        other.urlToImage == urlToImage &&
        other.publishedAt == publishedAt &&
        other.content == content;
  }

  @override
  int get hashCode {
    return runtimeType.hashCode ^
        title.hashCode ^
        author.hashCode ^
        description.hashCode ^
        url.hashCode ^
        urlToImage.hashCode ^
        publishedAt.hashCode ^
        content.hashCode;
  }

  /// Converts an [NewsArticle] to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      NewsArticleField.title: title,
      NewsArticleField.author: author,
      NewsArticleField.description: description,
      NewsArticleField.url: url,
      NewsArticleField.urlToImage: urlToImage,
      NewsArticleField.publishedAt: publishedAt?.toIso8601String(),
      NewsArticleField.content: content,
    };
  }
}

/// Contains the field names of the [NewsArticleField] table.
@immutable
abstract class NewsArticleField {
  const NewsArticleField._();

  static const author = 'author';
  static const title = 'title';
  static const description = 'description';
  static const url = 'url';
  static const urlToImage = 'url_to_image';
  static const publishedAt = 'published_at';
  static const content = 'content';
}
