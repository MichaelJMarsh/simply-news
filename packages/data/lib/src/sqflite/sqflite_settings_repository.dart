import 'dart:async';

import 'package:domain/domain.dart' hide Database;
import 'package:sqflite/sqflite.dart';

/// The sqflite implementation of [SettingsRepository].
class SqfliteSettingsRepository implements SettingsRepository {
  /// Creates a new [SqfliteSettingsRepository] instance.
  SqfliteSettingsRepository(this._database);

  /// The sqflite database instance.
  final Database _database;

  /// The name of the [SqfliteSettingsRepository] table.
  static const tableName = 'settings';

  final StreamController<SettingsData> _eventController =
      StreamController.broadcast();

  @override
  Stream<SettingsData> get changes => _eventController.stream;

  @override
  Future<SettingsData> get() => _getWithExecutor(_database);

  @override
  Future<void> update(UpdateSettings updateSettings) async {
    late SettingsData newValue;

    await _database.transaction((transaction) async {
      final oldValue = await _getWithExecutor(transaction);
      newValue = updateSettings(oldValue);

      if (oldValue != newValue) {
        await _setWithExecutor(newValue, transaction);
      }
    });

    _eventController.add(newValue);
  }

  /// Gets the current [SettingsData] from the database.
  Future<SettingsData> _getWithExecutor(DatabaseExecutor executor) async {
    final results = await executor.query(tableName);

    return results.map(SettingsData.fromSqfliteMap).first;
  }

  /// Updates the current [SettingsData] in the database with the given [newValue].
  Future<void> _setWithExecutor(
    SettingsData newValue,
    DatabaseExecutor executor,
  ) async {
    await executor.update(tableName, newValue.toSqfliteMap());
  }
}
