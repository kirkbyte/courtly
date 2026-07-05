import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsLocalDatasource {
  SettingsLocalDatasource(this._prefs);

  static const _keyThemeMode = 'settings.themeMode';
  static const _keyLocale = 'settings.locale';
  static const _keyNotifications = 'settings.notifications';

  final SharedPreferences _prefs;

  ThemeMode readThemeMode() {
    final raw = _prefs.getString(_keyThemeMode);
    return ThemeMode.values.asNameMap()[raw] ?? ThemeMode.system;
  }

  Future<void> saveThemeMode(ThemeMode mode) =>
      _prefs.setString(_keyThemeMode, mode.name);

  String? readLocaleCode() => _prefs.getString(_keyLocale);

  Future<void> saveLocaleCode(String code) =>
      _prefs.setString(_keyLocale, code);

  bool readNotifications() => _prefs.getBool(_keyNotifications) ?? true;

  Future<void> saveNotifications(bool enabled) =>
      _prefs.setBool(_keyNotifications, enabled);
}
