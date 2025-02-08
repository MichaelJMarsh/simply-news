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

  /// Returns the list of [NewsArticle] URLs that the user has added to their
  /// favorites.
  List<String> _favoriteNewsArticleUrls = [];

  /// Whether the dashboard page is loading.
  bool get isLoading => _isLoading;
  bool _isLoading = true;

  Timer? _debounce;

  Future<void> initialize() async {
    _favoriteNewsArticleUrls = await _getFavoriteNewsArticleUrls();

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
      _favoriteNewsArticleUrls = favoriteNewsArticles
          .map((favoriteNewsArticle) => favoriteNewsArticle.article.url)
          .whereType<String>()
          .toList();

      notifyListeners();
    });
  }

  /// Whether the news article with the given [articleUrl] is a favorite.
  bool isFavorite(String? articleUrl) {
    return _favoriteNewsArticleUrls.contains(articleUrl);
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
  Future<void> toggleFavorite(NewsArticle article) async {
    if (isFavorite(article.url)) {
      return _favoriteNewsArticleRepository.delete(article);
    }

    final now = clock.now();
    return _favoriteNewsArticleRepository.insert(
      FavoriteNewsArticle(
        article: article,
        insertionTime: now,
      ),
    );
  }

  /// Returns the URLs for all [FavoriteNewsArticle]s the user added to their
  /// favorites.
  Future<List<String>> _getFavoriteNewsArticleUrls() async {
    final favoriteNewsArticles = await _favoriteNewsArticleRepository.list();

    return favoriteNewsArticles
        .map((favoriteNewsArticle) => favoriteNewsArticle.article.url)
        .whereType<String>()
        .toList();
  }
}
