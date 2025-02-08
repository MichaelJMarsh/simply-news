import 'package:domain/src/model/settings_data.dart';

/// Updates the settings with the returned value atomically.
typedef UpdateSettings = SettingsData Function(SettingsData oldValue);

/// The interface for accessing app settings (see [SettingsData]).
abstract class SettingsRepository {
  const SettingsRepository._();

  /// A listenable stream that emits an updated app settings every time the
  /// settings change.
  Stream<SettingsData> get changes;

  /// Returns the app settings.
  Future<SettingsData> get();

  /// Updates the app settings.
  Future<void> update(UpdateSettings updateSettings);
}
