import 'package:flutter/foundation.dart';

import 'theme_mode.dart';

/// Contains the app settings stored in the database.
@immutable
class SettingsData {
  /// Creates a new [SettingsData].
  const SettingsData({
    this.nickname = '',
    this.themeMode = ThemeMode.system,
  });

  /// Creates a new [SettingsData] from a Sqflite map.
  factory SettingsData.fromSqfliteMap(Map<String, dynamic> map) {
    return SettingsData(
      nickname: map[SettingsField.nickname] as String,
      themeMode: ThemeMode.values.firstWhere(
        (themeMode) =>
            themeMode.name == map[SettingsField.themeModeName] as String,
        orElse: () => ThemeMode.system,
      ),
    );
  }

  /// The user's nickname.
  final String nickname;

  /// The theme mode of the app.
  final ThemeMode themeMode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SettingsData &&
        other.runtimeType == runtimeType &&
        other.nickname == nickname &&
        other.themeMode == themeMode;
  }

  @override
  int get hashCode {
    return runtimeType.hashCode ^ nickname.hashCode ^ themeMode.hashCode;
  }

  /// Creates a copy of this [SettingsData] but with the given fields replaced
  /// with the new values.
  SettingsData copyWith({
    String? nickname,
    ThemeMode? themeMode,
  }) {
    return SettingsData(
      nickname: nickname ?? this.nickname,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  /// Converts a [SettingsData] to a Sqflite map.
  Map<String, dynamic> toSqfliteMap() {
    return {
      SettingsField.nickname: nickname,
      SettingsField.themeModeName: themeMode.name,
    };
  }
}

/// Contains the field names of the Settings table.
@immutable
abstract class SettingsField {
  const SettingsField._();

  static const nickname = 'nickname';
  static const themeModeName = 'theme_mode_name';
}
