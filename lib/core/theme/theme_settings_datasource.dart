import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_settings_model.dart';

class ThemeSettingsDataSource {
  static const _keyThemeMode = 'theme_mode';
  static const _keyPrimaryColor = 'primary_color';
  static const _keySecondaryColor = 'secondary_color';
  static const _keyLocale = 'locale';

  Future<ThemeSettings> getThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return ThemeSettings(
      themeMode: ThemeMode.values[prefs.getInt(_keyThemeMode) ?? 0],
      primaryColor: Color(prefs.getInt(_keyPrimaryColor) ?? 0xFF6366F1),
      secondaryColor: Color(prefs.getInt(_keySecondaryColor) ?? 0xFF10B981),
      locale: Locale(prefs.getString(_keyLocale) ?? 'en'),
    );
  }

  Future<void> saveThemeSettings(ThemeSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeMode, settings.themeMode.index);
    await prefs.setInt(_keyPrimaryColor, settings.primaryColor.toARGB32());
    await prefs.setInt(_keySecondaryColor, settings.secondaryColor.toARGB32());
    await prefs.setString(_keyLocale, settings.locale.languageCode);
  }
}
