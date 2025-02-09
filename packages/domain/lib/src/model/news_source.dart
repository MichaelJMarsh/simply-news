import 'package:flutter/foundation.dart';

/// A class that represents a news source.
@immutable
class NewsSource {
  /// Creates a new [NewsSource].
  const NewsSource({
    required this.id,
    required this.name,
    this.description,
    this.url,
    this.category,
    this.language,
    this.country,
  });

  /// The unique identifier of the news source.
  final String id;

  /// The name of the news source.
  final String name;

  /// A brief description of the news source.
  final String? description;

  /// The URL of the news source.
  final String? url;

  /// The category of the news source.
  final String? category;

  /// The language of the news source.
  final String? language;

  /// The country where the news source is based.
  final String? country;

  /// Creates a new [NewsSource] from a JSON object.
  factory NewsSource.fromJson(Map<String, dynamic> json) {
    return NewsSource(
      id: json[NewsSourceField.id] as String? ?? '',
      name: json[NewsSourceField.name] as String? ?? '',
      description: json[NewsSourceField.description] as String?,
      url: json[NewsSourceField.url] as String?,
      category: json[NewsSourceField.category] as String?,
      language: json[NewsSourceField.language] as String?,
      country: json[NewsSourceField.country] as String?,
    );
  }

  /// Converts a [NewsSource] instance to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      NewsSourceField.id: id,
      NewsSourceField.name: name,
      NewsSourceField.description: description,
      NewsSourceField.url: url,
      NewsSourceField.category: category,
      NewsSourceField.language: language,
      NewsSourceField.country: country,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NewsSource &&
        other.runtimeType == runtimeType &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.url == url &&
        other.category == category &&
        other.language == language &&
        other.country == country;
  }

  @override
  int get hashCode {
    return runtimeType.hashCode ^
        id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        url.hashCode ^
        category.hashCode ^
        language.hashCode ^
        country.hashCode;
  }
}

/// Contains the field names of the [NewsSource] table.
@immutable
abstract class NewsSourceField {
  const NewsSourceField._();

  static const id = 'id';
  static const name = 'name';
  static const description = 'description';
  static const url = 'url';
  static const category = 'category';
  static const language = 'language';
  static const country = 'country';
}
