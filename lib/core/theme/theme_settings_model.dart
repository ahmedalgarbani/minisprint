import 'package:flutter/material.dart';

class ThemeSettings {
  final ThemeMode themeMode;
  final Color primaryColor;
  final Color secondaryColor;
  final Locale locale;

  const ThemeSettings({
    this.themeMode = ThemeMode.dark,
    this.primaryColor = const Color(0xFF6366F1),
    this.secondaryColor = const Color(0xFF10B981),
    this.locale = const Locale('en'),
  });

  ThemeSettings copyWith({
    ThemeMode? themeMode,
    Color? primaryColor,
    Color? secondaryColor,
    Locale? locale,
  }) {
    return ThemeSettings(
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      locale: locale ?? this.locale,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode.index,
      'primaryColor': primaryColor.toARGB32(),
      'secondaryColor': secondaryColor.toARGB32(),
      'locale': locale.languageCode,
    };
  }

  factory ThemeSettings.fromMap(Map<String, dynamic> map) {
    return ThemeSettings(
      themeMode: ThemeMode.values[map['themeMode'] ?? 0],
      primaryColor: Color(map['primaryColor'] ?? 0xFF6366F1),
      secondaryColor: Color(map['secondaryColor'] ?? 0xFF10B981),
      locale: Locale(map['locale'] ?? 'en'),
    );
  }
}
