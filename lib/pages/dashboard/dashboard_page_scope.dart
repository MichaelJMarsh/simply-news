import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:clock/clock.dart';
import 'package:domain/domain.dart';
import 'package:provider/provider.dart';

/// A provider-scoped state management class that handles fetching, searching,
/// filtering, and favoriting news articles with pagination and real-time updates.
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

  /// The subscription which listens to changes in favorite news articles.
  StreamSubscription<List<FavoriteNewsArticle>>?
      _favoriteNewsArticleStreamSubscription;

  /// The list of news articles.
  List<NewsArticle> get newsArticles => _newsArticles;
  List<NewsArticle> _newsArticles = [];

  /// The list of news sources.
  List<NewsSource> get sources => _sources;
  List<NewsSource> _sources = [];

  /// Whether we are currently loading sources.
  bool get isLoadingSources => _isLoadingSources;
  bool _isLoadingSources = false;

  /// The currently selected source (if any).
  String? get selectedSourceId => _selectedSourceId;
  String? _selectedSourceId;

  /// Search/favorites state
  List<String> _favoriteNewsArticleUrls = [];

  /// Whether the page is loading.
  bool get isLoading => _isLoading;
  bool _isLoading = true;

  /// Whether we are loading more articles.
  bool get isLoadingMore => _isLoadingMore;
  bool _isLoadingMore = false;

  /// The timer used for debouncing search queries.
  Timer? _debounce;

  /// The current search query.
  String _currentQuery = "";

  /// The current page of articles.
  int _currentPage = 1;

  /// The number of articles to load per page.
  static const _pageSize = 10;

  /// Whether there are more items to load.
  bool get hasMoreArticles => _hasMoreArticles;
  bool _hasMoreArticles = true;

  Future<void> initialize() async {
    _favoriteNewsArticleUrls = await _getFavoriteNewsArticleUrls();
    _initializeFavoriteNewsArticleStreamSubscription();

    await _loadSources();

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _favoriteNewsArticleStreamSubscription?.cancel();

    super.dispose();
  }

  /// Subscribes to favorite article changes
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

  /// Returns the favorite news article URLs.
  Future<List<String>> _getFavoriteNewsArticleUrls() async {
    final favoriteNewsArticles = await _favoriteNewsArticleRepository.list();
    return favoriteNewsArticles
        .map((favoriteNewsArticle) => favoriteNewsArticle.article.url)
        .whereType<String>()
        .toList();
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

  /// Load all available news sources.
  Future<void> _loadSources() async {
    _isLoadingSources = true;
    notifyListeners();

    try {
      _sources = await _newsArticleService.fetchSources();
    } catch (e) {
      // Record the error to Firebase Crashlytics or similar service.
    } finally {
      _isLoadingSources = false;
      notifyListeners();
    }
  }

  /// Select a particular source. If null or empty, we'll revert to "search all".
  Future<void> selectSource(String? sourceId) async {
    _selectedSourceId = sourceId;
    _currentPage = 1;
    _hasMoreArticles = true;

    // Clear out old articles.
    _newsArticles = [];
    notifyListeners();

    // Reload articles based on current query & new source.
    await refreshArticles();
  }

  /// Search for news articles based on the given [query].
  Future<void> searchNewsArticles(String query) async {
    _debounce?.cancel();

    // Reset to all sources if query is empty and no source is selected.
    if (query.isEmpty && _selectedSourceId == null) {
      _currentQuery = "";
      _currentPage = 1;
      _hasMoreArticles = true;
      _newsArticles = [];
      notifyListeners();

      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      _currentQuery = query;

      // Clear existing articles before reload.
      _newsArticles = [];
      _currentPage = 1;
      _hasMoreArticles = true;
      notifyListeners();

      await _loadArticles(page: _currentPage, reset: true);
    });
  }

  /// Refresh the articles list by loading the first page.
  Future<void> refreshArticles() async {
    _currentPage = 1;
    _hasMoreArticles = true;
    _newsArticles = [];

    notifyListeners();

    await _loadArticles(page: _currentPage, reset: true);
  }

  /// Loads more articles (next page), if available.
  Future<void> loadMoreArticles() async {
    if (_isLoadingMore || !_hasMoreArticles || _isLoading) return;

    _currentPage++;
    await _loadArticles(page: _currentPage);
  }

  /// Loads articles, either via search (everything) or via top-headlines,
  /// depending on whether [_currentQuery] is empty or not.
  Future<void> _loadArticles({required int page, bool reset = false}) async {
    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _newsArticleService.searchArticles(
        query: _currentQuery,
        page: page,
        pageSize: _pageSize,
        sourceId:
            (_selectedSourceId?.isNotEmpty == true) ? _selectedSourceId : null,
      );

      final newArticles = result.articles;
      final totalResults = result.totalResults;

      if (reset) {
        _newsArticles = newArticles;
      } else {
        _newsArticles.addAll(newArticles);
      }

      final loadedSoFar = _currentPage * _pageSize;
      _hasMoreArticles = (loadedSoFar < totalResults);
    } catch (e) {
      // Record the error to Firebase Crashlytics or similar service.
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}
