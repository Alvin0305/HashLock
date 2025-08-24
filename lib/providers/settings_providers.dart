import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quartz/constants/app_constants.dart';

final settingsBoxProvider = Provider<Box>((ref) {
  return Hive.box(HiveBoxNames.settingsBox);
});

final usernameProvider = StateProvider<String>((ref) {
  final box = ref.watch(settingsBoxProvider);

  return box.get(SettingsKeys.username, defaultValue: 'User');
});

final avatarProvider = StateProvider<String>((ref) {
  final box = ref.watch(settingsBoxProvider);

  return box.get(SettingsKeys.userAvatar, defaultValue: 'avatar_1');
});

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((
  ref,
) {
  final box = ref.read(settingsBoxProvider);
  return ThemeModeNotifier(box);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final Box _settingsBox;

  ThemeModeNotifier(this._settingsBox) : super(_loadThemeMode(_settingsBox));

  static ThemeMode _loadThemeMode(Box box) {
    final themeString = box.get(SettingsKeys.themeMode, defaultValue: 'system');
    switch (themeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void setThemeMode(ThemeMode themeMode) {
    if (state != themeMode) {
      state = themeMode;
      _settingsBox.put(SettingsKeys.themeMode, themeMode.name);
    }
  }
}
