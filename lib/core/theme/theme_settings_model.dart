import 'package:flutter/material.dart';

import '../preferences/work_mode.dart';

class ThemeSettings {
  final ThemeMode themeMode;
  final Color primaryColor;
  final Color secondaryColor;
  final Locale locale;
  final WorkMode workMode;

  const ThemeSettings({
    this.themeMode = ThemeMode.system,
    this.primaryColor = const Color(0xFF2563EB),
    this.secondaryColor = const Color(0xFF10B981),
    this.locale = const Locale('en'),
    this.workMode = WorkMode.simple,
  });

  ThemeSettings copyWith({
    ThemeMode? themeMode,
    Color? primaryColor,
    Color? secondaryColor,
    Locale? locale,
    WorkMode? workMode,
  }) {
    return ThemeSettings(
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      locale: locale ?? this.locale,
      workMode: workMode ?? this.workMode,
    );
  }
}
