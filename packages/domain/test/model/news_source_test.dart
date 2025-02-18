import 'package:flutter_test/flutter_test.dart';
import 'package:domain/domain.dart';

void main() {
  group('NewsSource', () {
    final testJson = {
      NewsSourceField.id: 'abc-news',
      NewsSourceField.name: 'ABC News',
      NewsSourceField.description: 'Some description',
      NewsSourceField.url: 'https://abcnews.go.com',
      NewsSourceField.category: 'general',
      NewsSourceField.language: 'en',
      NewsSourceField.country: 'us',
    };

    const expectedSource = NewsSource(
      id: 'abc-news',
      name: 'ABC News',
      description: 'Some description',
      url: 'https://abcnews.go.com',
      category: 'general',
      language: 'en',
      country: 'us',
    );

    test('correctly stores and retrieves values', () {
      const source = NewsSource(
        id: 'bbc-news',
        name: 'BBC News',
        description: 'BBC News provides reliable updates',
        url: 'https://bbc.co.uk',
        category: 'general',
        language: 'en',
        country: 'gb',
      );

      expect(source.id, 'bbc-news');
      expect(source.name, 'BBC News');
      expect(source.description, 'BBC News provides reliable updates');
      expect(source.url, 'https://bbc.co.uk');
      expect(source.category, 'general');
      expect(source.language, 'en');
      expect(source.country, 'gb');

      final json = source.toJson();
      expect(json[NewsSourceField.id], 'bbc-news');
      expect(json[NewsSourceField.name], 'BBC News');
      expect(
        json[NewsSourceField.description],
        'BBC News provides reliable updates',
      );
      expect(json[NewsSourceField.url], 'https://bbc.co.uk');
      expect(json[NewsSourceField.category], 'general');
      expect(json[NewsSourceField.language], 'en');
      expect(json[NewsSourceField.country], 'gb');
    });

    test('fromJson constructs correctly', () {
      final source = NewsSource.fromJson(testJson);
      expect(source, equals(expectedSource));
    });

    test('toJson returns correct map', () {
      final json = expectedSource.toJson();
      expect(json, equals(testJson));
    });

    test('equality and hashCode', () {
      const sameSource = NewsSource(
        id: 'abc-news',
        name: 'ABC News',
        description: 'Some description',
        url: 'https://abcnews.go.com',
        category: 'general',
        language: 'en',
        country: 'us',
      );

      const differentSource = NewsSource(id: 'bbc-news', name: 'BBC News');

      expect(expectedSource, equals(sameSource));
      expect(expectedSource.hashCode, equals(sameSource.hashCode));
      expect(expectedSource, isNot(equals(differentSource)));
    });
  });
}
