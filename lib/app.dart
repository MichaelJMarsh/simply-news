import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter/services.dart';

import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:provider/provider.dart';

import 'app_theme.dart';
import 'pages/dashboard/dashboard_page.dart';

/// Manages the core functionalities of SimplyNews.
///
/// Leverages a variety of services and repositories to manage user data,
/// preferences and system interactions.
class SimplyNewsApp extends StatefulWidget {
  /// Creates a new [SimplyNewsApp].
  const SimplyNewsApp({
    super.key,
    required this.database,
    required this.share,
    required this.urlLauncher,
    required this.favoriteNewsArticleRepository,
    required this.settingsRepository,
    required this.newsArticleService,
  });

  final Database database;

  final Share share;
  final UrlLauncher urlLauncher;

  final FavoriteNewsArticleRepository favoriteNewsArticleRepository;
  final SettingsRepository settingsRepository;

  final NewsArticleService newsArticleService;

  @override
  State<SimplyNewsApp> createState() => _SimplyNewsAppState();
}

class _SimplyNewsAppState extends State<SimplyNewsApp>
    with WidgetsBindingObserver {
  @override
  void dispose() {
    widget.database.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: widget.database),
        Provider.value(value: widget.share),
        Provider.value(value: widget.urlLauncher),
        Provider.value(value: widget.favoriteNewsArticleRepository),
        Provider.value(value: widget.settingsRepository),
        Provider.value(value: widget.newsArticleService),
        ChangeNotifierProvider(
          lazy: false,
          create: (_) => Settings(
            widget.settingsRepository,
          )..initialize(),
        ),
      ],
      builder: (context, __) {
        final mediaQuery = MediaQuery.of(context);
        final themeMode = Settings.select(
          context,
          (settings) => settings.themeMode,
        );
        final theme = AppTheme.getTheme(
          themeMode: themeMode,
          platformBrightness: mediaQuery.platformBrightness,
        );

        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.noScaling,
          ),
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: theme.colorScheme.brightness == Brightness.dark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark,
            child: DefaultTextStyle(
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
              child: MaterialApp(
                title: 'Simply News',
                theme: theme,
                home: const DashboardPage(),
              ),
            ),
          ),
        );
      },
    );
  }
}
