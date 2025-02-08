import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter/services.dart';

import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:provider/provider.dart';

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
    required this.getAppVersion,
    required this.share,
    required this.favoriteNewsArticleRepository,
    required this.settingsRepository,
    required this.newsArticleService,
  });

  final Database database;

  final GetAppVersion getAppVersion;
  final Share share;

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
        Provider.value(value: widget.getAppVersion),
        Provider.value(value: widget.share),
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
        var theme = _AppTheme.getTheme(
          themeMode: themeMode,
          platformBrightness: mediaQuery.platformBrightness,
        );

        theme = theme.copyWith(
          colorScheme: theme.colorScheme.copyWith(
            primary: const Color(0xFF1E3A8A),
          ),
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

/// Defines the SimplyNews app themes.
class _AppTheme {
  const _AppTheme._();

  static const primaryColor = Color(0xFF1E3A8A);

  /// Light theme configuration.
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );

  /// Dark theme configuration.
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );

  /// Determines the correct theme based on user settings and system brightness.
  static ThemeData getTheme({
    required ThemeMode themeMode,
    required Brightness platformBrightness,
  }) {
    return switch (themeMode) {
      ThemeMode.light => lightTheme,
      ThemeMode.dark => darkTheme,
      ThemeMode.system =>
        platformBrightness == Brightness.light ? lightTheme : darkTheme,
    };
  }
}
