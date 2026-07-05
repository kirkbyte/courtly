import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/di.dart';

part 'settings_notifier.g.dart';

typedef AppSettings = ({
  ThemeMode themeMode,
  Locale? locale,
  bool notifications,
});

@Riverpod(keepAlive: true)
class SettingsNotifier extends _$SettingsNotifier {
  @override
  AppSettings build() {
    final datasource = ref.watch(settingsLocalDatasourceProvider);
    final code = datasource.readLocaleCode();
    return (
      themeMode: datasource.readThemeMode(),
      locale: code == null ? null : Locale(code),
      notifications: datasource.readNotifications(),
    );
  }

  Future<void> toggleDark(bool isDark) async {
    await ref
        .read(settingsLocalDatasourceProvider)
        .saveThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
    ref.invalidateSelf();
  }

  Future<void> setLocale(String code) async {
    await ref.read(settingsLocalDatasourceProvider).saveLocaleCode(code);
    ref.invalidateSelf();
  }

  Future<void> toggleNotifications(bool enabled) async {
    await ref
        .read(settingsLocalDatasourceProvider)
        .saveNotifications(enabled);
    ref.invalidateSelf();
  }
}
