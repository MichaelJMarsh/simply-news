// Mocks generated by Mockito 5.4.5 from annotations
// in simply_news/test/pages/favorites/favorite_articles_page_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:domain/src/model/favorite_news_article.dart' as _i4;
import 'package:domain/src/model/news_article.dart' as _i5;
import 'package:domain/src/repository/favorite_news_article_repository.dart'
    as _i2;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [FavoriteNewsArticleRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockFavoriteNewsArticleRepository extends _i1.Mock
    implements _i2.FavoriteNewsArticleRepository {
  @override
  _i3.Stream<List<_i4.FavoriteNewsArticle>> get changes =>
      (super.noSuchMethod(
            Invocation.getter(#changes),
            returnValue: _i3.Stream<List<_i4.FavoriteNewsArticle>>.empty(),
            returnValueForMissingStub:
                _i3.Stream<List<_i4.FavoriteNewsArticle>>.empty(),
          )
          as _i3.Stream<List<_i4.FavoriteNewsArticle>>);

  @override
  _i3.Future<void> insert(_i4.FavoriteNewsArticle? favoriteNewsArticle) =>
      (super.noSuchMethod(
            Invocation.method(#insert, [favoriteNewsArticle]),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);

  @override
  _i3.Future<void> delete(_i5.NewsArticle? newsArticle) =>
      (super.noSuchMethod(
            Invocation.method(#delete, [newsArticle]),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);

  @override
  _i3.Future<_i4.FavoriteNewsArticle?> get(String? articleUrl) =>
      (super.noSuchMethod(
            Invocation.method(#get, [articleUrl]),
            returnValue: _i3.Future<_i4.FavoriteNewsArticle?>.value(),
            returnValueForMissingStub:
                _i3.Future<_i4.FavoriteNewsArticle?>.value(),
          )
          as _i3.Future<_i4.FavoriteNewsArticle?>);

  @override
  _i3.Future<List<_i4.FavoriteNewsArticle>> list() =>
      (super.noSuchMethod(
            Invocation.method(#list, []),
            returnValue: _i3.Future<List<_i4.FavoriteNewsArticle>>.value(
              <_i4.FavoriteNewsArticle>[],
            ),
            returnValueForMissingStub:
                _i3.Future<List<_i4.FavoriteNewsArticle>>.value(
                  <_i4.FavoriteNewsArticle>[],
                ),
          )
          as _i3.Future<List<_i4.FavoriteNewsArticle>>);
}
