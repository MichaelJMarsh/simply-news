import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:clock/clock.dart';
import 'package:domain/domain.dart';
import 'package:provider/provider.dart';

class DashboardPageScope extends ChangeNotifier {
  /// Creates a new [DashboardPageScope].
  DashboardPageScope({
    required FavoriteNewsArticleRepository favoriteNewsArticleRepository,
    required NewsArticleService newsArticleService,
  })  : _favoriteNewsArticleRepository = favoriteNewsArticleRepository,
        _newsArticleService = newsArticleService;

  /// Creates a new [DashboardPageScope] from the [context].
  factory DashboardPageScope.of(final BuildContext context) {
    return DashboardPageScope(
      favoriteNewsArticleRepository: context.read(),
      newsArticleService: context.read(),
    );
  }

  final FavoriteNewsArticleRepository _favoriteNewsArticleRepository;
  final NewsArticleService _newsArticleService;

  /// The subscription which streams [List<FavoriteNewsArticle>] events.
  StreamSubscription<List<FavoriteNewsArticle>>?
      _favoriteNewsArticleStreamSubscription;

  /// The list of news articles to display.
  List<NewsArticle> get newsArticles => _newsArticles;
  List<NewsArticle> _newsArticles = [];

  /// Returns the list of [NewsArticle] IDs which the user has added
  /// to favorites.
  List<String> _favoriteNewsArticleIds = [];

  /// Whether the dashboard page is loading.
  bool get isLoading => _isLoading;
  bool _isLoading = true;

  Timer? _debounce;

  Future<void> initialize() async {
    _favoriteNewsArticleIds = await _getFavoriteNewsArticleIds();

    _initializeFavoriteNewsArticleStreamSubscription();

    _isLoading = false;

    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();

    _favoriteNewsArticleStreamSubscription?.cancel();

    super.dispose();
  }

  /// Initializes the [StreamSubscription] for any [FavoriteNewsArticle] changes.
  void _initializeFavoriteNewsArticleStreamSubscription() {
    _favoriteNewsArticleStreamSubscription = _favoriteNewsArticleRepository
        .changes
        .listen((favoriteNewsArticles) async {
      _favoriteNewsArticleIds = favoriteNewsArticles
          .map((favoriteNewsArticle) => favoriteNewsArticle.articleId)
          .toList();

      notifyListeners();
    });
  }

  /// Whether the news article with the given [articleId] is a favorite.
  bool isFavorite(String articleId) {
    return _favoriteNewsArticleIds.contains(articleId);
  }

  Future<void> searchNewsArticles(String query) async {
    _debounce?.cancel();

    // Debounce the search query to avoid making too many requests and allow
    // for smoother frontend experience.
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      _newsArticles = await _newsArticleService.searchArticles(query: query);

      notifyListeners();
    });
  }

  /// Toggles the favorite status of the news article with the given [articleId].
  Future<void> toggleFavorite(String articleId) async {
    if (isFavorite(articleId)) {
      return _favoriteNewsArticleRepository.delete(articleId);
    }

    final now = clock.now();
    return _favoriteNewsArticleRepository.insert(
      FavoriteNewsArticle(
        articleId: articleId,
        insertionTime: now,
      ),
    );
  }

  /// Returns the ID for all [FavoriteNewsArticle]s the user added to their
  /// favorites.
  Future<List<String>> _getFavoriteNewsArticleIds() async {
    final favoriteNewsArticles = await _favoriteNewsArticleRepository.list();

    return favoriteNewsArticles
        .map((favoriteNewsArticle) => favoriteNewsArticle.articleId)
        .toList();
  }
}
