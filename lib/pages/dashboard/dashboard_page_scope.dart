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
      favoriteNewsArticleRepository:
          context.read<FavoriteNewsArticleRepository>(),
      newsArticleService: context.read<NewsArticleService>(),
    );
  }

  final FavoriteNewsArticleRepository _favoriteNewsArticleRepository;
  final NewsArticleService _newsArticleService;

  /// Subscription for favorite news article changes.
  StreamSubscription<List<FavoriteNewsArticle>>?
      _favoriteNewsArticleStreamSubscription;

  /// The list of news articles to display.
  List<NewsArticle> get newsArticles => _newsArticles;
  List<NewsArticle> _newsArticles = [];

  /// The list of favorite article URLs.
  List<String> _favoriteNewsArticleUrls = [];

  /// Indicates if the first page is loading.
  bool get isLoading => _isLoading;
  bool _isLoading = true;

  /// Indicates if additional (paginated) articles are being loaded.
  bool get isLoadingMore => _isLoadingMore;
  bool _isLoadingMore = false;

  Timer? _debounce;

  /// The current search query.
  String _currentQuery = "";

  /// The current page of articles.
  int _currentPage = 1;

  /// Number of articles to load per page.
  static const _pageSize = 10;

  /// Whether there are more items available for the current query.
  bool _queryHasMoreItems = true;

  /// Initializes the scope. (No articles are loaded until a search is performed.)
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

  /// Subscribes to favorite article changes.
  void _initializeFavoriteNewsArticleStreamSubscription() {
    _favoriteNewsArticleStreamSubscription =
        _favoriteNewsArticleRepository.changes.listen((favoriteNewsArticles) {
      _favoriteNewsArticleUrls = favoriteNewsArticles
          .map((favoriteNewsArticle) => favoriteNewsArticle.article.url)
          .whereType<String>()
          .toList();

      notifyListeners();
    });
  }

  /// Returns whether the given [articleUrl] is marked as favorite.
  bool isFavorite(String? articleUrl) {
    return _favoriteNewsArticleUrls.contains(articleUrl);
  }

  /// Called when the search query changes.
  ///
  /// This debounces the input and triggers a refresh.
  Future<void> searchNewsArticles(String query) async {
    _debounce?.cancel();

    if (query.isEmpty) {
      _clearSearch();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      _currentQuery = query;
      await refreshArticles();
    });
  }

  /// Clear the articles and reset search state
  void _clearSearch() {
    _newsArticles = [];
    _currentQuery = "";
    _currentPage = 1;
    _queryHasMoreItems = true;

    notifyListeners();
  }

  /// Refreshes the articles list by loading the first page.
  ///
  /// If no articles exist yet, [isLoading] is set to true so that the UI
  /// can show a full-screen loader. If there are already articles,
  /// a refresh is done without toggling [isLoading].
  Future<void> refreshArticles() async {
    _currentPage = 1;
    _queryHasMoreItems = true;

    await _loadArticles(page: _currentPage, reset: true);
  }

  /// Loads more articles (next page) if available.
  Future<void> loadMoreArticles() async {
    if (_isLoadingMore || !_queryHasMoreItems || _isLoading) return;

    _currentPage++;
    await _loadArticles(page: _currentPage, reset: false);
  }

  /// Loads articles from the service.
  ///
  /// When [reset] is true, the articles list is replaced. Otherwise, the new
  /// articles are appended.
  Future<void> _loadArticles({required int page, bool reset = false}) async {
    _isLoadingMore = true;
    notifyListeners();

    try {
      final articles = await _newsArticleService.searchArticles(
        query: _currentQuery,
        page: page,
        pageSize: _pageSize,
      );

      if (reset) {
        _newsArticles = articles;
      } else {
        _newsArticles.addAll(articles);
      }

      // If fewer articles than requested are returned, assume no more pages.
      if (articles.length < _pageSize) {
        _queryHasMoreItems = false;
      }
    } catch (e) {
      // Record the error to Firebase Crashlytics or similar service.
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Toggles the favorite status of the given [article].
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

  /// Retrieves the URLs for all favorite news articles.
  Future<List<String>> _getFavoriteNewsArticleUrls() async {
    final favoriteNewsArticles = await _favoriteNewsArticleRepository.list();
    return favoriteNewsArticles
        .map((favoriteNewsArticle) => favoriteNewsArticle.article.url)
        .whereType<String>()
        .toList();
  }
}
