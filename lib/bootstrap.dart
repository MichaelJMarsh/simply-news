import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:data/data.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:uuid/uuid.dart';

import 'app.dart';

/// Initializes the database and other services, then returns the created [ThalloApp].
Future<SimplyNewsApp> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final database = SqfliteDatabase(path: await _getDatabasePath());
  await database.open();

  return SimplyNewsApp(
    database: database,
    generateUuid: const Uuid().v4,
    getAppVersion: _getAppVersion,
    share: const SharePlugin(),
    favoriteActionRepository:
        SqfliteFavoriteNewsArticleRepository(database.instance),
    settingsRepository: SqfliteSettingsRepository(database.instance),
  );
}

/// Returns the absolute local database path.
Future<String> _getDatabasePath() async {
  /// The database filename without directory path.
  const databaseFilename = 'simply_news.db';

  final path = await sqflite.getDatabasesPath();

  return join(path, databaseFilename);
}

Future<String> _getAppVersion() async {
  final packageInfo = await PackageInfo.fromPlatform();

  return packageInfo.version;
}
