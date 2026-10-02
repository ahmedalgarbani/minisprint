import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../preferences/work_mode.dart';
import 'theme_settings_model.dart';

class ThemeSettingsDataSource {
  static const _keyThemeMode = 'theme_mode';
  static const _keyPrimaryColor = 'primary_color';
  static const _keySecondaryColor = 'secondary_color';
  static const _keyLocale = 'locale';
  static const _keyWorkMode = 'work_mode';

  Future<ThemeSettings> getThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    const defaults = ThemeSettings();
    final modeIndex = prefs.getInt(_keyThemeMode);
    return ThemeSettings(
      themeMode:
          modeIndex != null &&
              modeIndex >= 0 &&
              modeIndex < ThemeMode.values.length
          ? ThemeMode.values[modeIndex]
          : defaults.themeMode,
      primaryColor: Color(
        prefs.getInt(_keyPrimaryColor) ?? defaults.primaryColor.toARGB32(),
      ),
      secondaryColor: Color(
        prefs.getInt(_keySecondaryColor) ?? defaults.secondaryColor.toARGB32(),
      ),
      locale: Locale(prefs.getString(_keyLocale) ?? 'en'),
      workMode:
          WorkMode.values.asNameMap()[prefs.getString(_keyWorkMode)] ??
          defaults.workMode,
    );
  }

  Future<void> saveThemeSettings(ThemeSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeMode, settings.themeMode.index);
    await prefs.setInt(_keyPrimaryColor, settings.primaryColor.toARGB32());
    await prefs.setInt(_keySecondaryColor, settings.secondaryColor.toARGB32());
    await prefs.setString(_keyLocale, settings.locale.languageCode);
    await prefs.setString(_keyWorkMode, settings.workMode.name);
  }
}
