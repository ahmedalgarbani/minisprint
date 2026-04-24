import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme_settings_model.dart';
import '../../../../core/theme/theme_settings_datasource.dart';

class ThemeSettingsCubit extends Cubit<ThemeSettings> {
  final ThemeSettingsDataSource _dataSource;

  ThemeSettingsCubit({ThemeSettingsDataSource? dataSource})
    : _dataSource = dataSource ?? ThemeSettingsDataSource(),
      super(const ThemeSettings());

  Future<void> loadSettings() async {
    final settings = await _dataSource.getThemeSettings();
    emit(settings);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final newSettings = state.copyWith(themeMode: mode);
    await _dataSource.saveThemeSettings(newSettings);
    emit(newSettings);
  }

  Future<void> setPrimaryColor(Color color) async {
    final newSettings = state.copyWith(primaryColor: color);
    await _dataSource.saveThemeSettings(newSettings);
    emit(newSettings);
  }

  Future<void> setSecondaryColor(Color color) async {
    final newSettings = state.copyWith(secondaryColor: color);
    await _dataSource.saveThemeSettings(newSettings);
    emit(newSettings);
  }

  Future<void> setLocale(Locale locale) async {
    final newSettings = state.copyWith(locale: locale);
    await _dataSource.saveThemeSettings(newSettings);
    emit(newSettings);
  }
}
