import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/preferences/work_mode.dart';
import '../../../../core/theme/theme_settings_datasource.dart';
import '../../../../core/theme/theme_settings_model.dart';

class ThemeSettingsCubit extends Cubit<ThemeSettings> {
  final ThemeSettingsDataSource _dataSource;

  ThemeSettingsCubit({ThemeSettingsDataSource? dataSource})
    : _dataSource = dataSource ?? ThemeSettingsDataSource(),
      super(const ThemeSettings());

  Future<void> loadSettings() async {
    try {
      emit(await _dataSource.getThemeSettings());
    } catch (_) {
      // Keep defaults if preferences cannot be read.
    }
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _update(state.copyWith(themeMode: mode));

  Future<void> setPrimaryColor(Color color) =>
      _update(state.copyWith(primaryColor: color));

  Future<void> setSecondaryColor(Color color) =>
      _update(state.copyWith(secondaryColor: color));

  Future<void> setLocale(Locale locale) =>
      _update(state.copyWith(locale: locale));

  Future<void> setWorkMode(WorkMode mode) =>
      _update(state.copyWith(workMode: mode));

  /// Applies the change immediately; persisting is best-effort.
  Future<void> _update(ThemeSettings settings) async {
    emit(settings);
    try {
      await _dataSource.saveThemeSettings(settings);
    } catch (_) {}
  }
}
