import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:data/data.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'app.dart';
import 'firebase_options.dart';

/// Initializes the database and other services, then returns the created [SimplyNewsApp].
Future<SimplyNewsApp> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final database = SqfliteDatabase(path: await _getDatabasePath());
  await database.open();

  final remoteConfig = RemoteConfigurationPlugin(
    remoteConfig: FirebaseRemoteConfig.instance,
  );

  await remoteConfig.initialize();

  return SimplyNewsApp(
    database: database,
    share: SharePlugin(delegate: ShareDelegate()),
    urlLauncher: UrlLauncherPlugin(delegate: UrlLauncherDelegate()),
    favoriteNewsArticleRepository:
        SqfliteFavoriteNewsArticleRepository(database.instance),
    newsArticleService: NewsArticleClient(apiKey: remoteConfig.newsApiKey),
  );
}

/// Returns the absolute local database path.
Future<String> _getDatabasePath() async {
  /// The database filename without directory path.
  const databaseFilename = 'simply_news.db';

  final path = await sqflite.getDatabasesPath();

  return join(path, databaseFilename);
}
