import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:domain/domain.dart';
import 'package:provider/provider.dart';

/// Interface to the app settings stored in [SettingsRepository].
///
/// Caches the values in the repository so that values are available
/// instantaneously, and acts as a change notifier to easily update UI
/// upon settings changes.
class Settings extends ChangeNotifier {
  /// Creates a new [Settings] instance.
  Settings(this._repository);

  final SettingsRepository _repository;

  /// The current app settings.
  SettingsData get data => _data;
  SettingsData _data = const SettingsData();

  StreamSubscription<SettingsData>? _listener;

  /// Initializes the settings by listening to changes in the underlying repository.
  Future<void> initialize() async {
    _data = await _repository.get();

    _listener = _repository.changes.listen((data) {
      if (_data == data) return;

      _data = data;
      notifyListeners();
    });

    notifyListeners();
  }

  @override
  void dispose() {
    _listener?.cancel();

    super.dispose();
  }

  /// Reads the settings.
  static SettingsData read(BuildContext context) =>
      context.read<Settings>()._data;

  /// Reads the settings and subscribes to changes.
  static SettingsData watch(BuildContext context) =>
      context.watch<Settings>()._data;

  /// Selects a value from the settings and subscribes to changes.
  static T select<T>(
    BuildContext context,
    T Function(SettingsData settings) selector,
  ) =>
      context.select((Settings settings) => selector(settings._data));

  /// Updates the settings.
  static Future<void> update(
    BuildContext context,
    UpdateSettings updateSettings,
  ) async {
    final settings = context.read<Settings>();

    await settings._repository.update(updateSettings);

    settings._data = await settings._repository.get();
    settings.notifyListeners();
  }
}
