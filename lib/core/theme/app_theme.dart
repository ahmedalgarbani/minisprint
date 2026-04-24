import 'package:flutter/material.dart';
import 'app_colors.dart';
import '../constants/app_constants.dart';

class AppTheme {
  static ThemeData getTheme({
    required Color primaryColor,
    required Color secondaryColor,
    required Brightness brightness,
  }) {
    final isDark = brightness == Brightness.dark;
    final background = isDark ? AppColors.background : const Color(0xFFF8FAFC);
    final surface = isDark ? AppColors.surface : Colors.white;
    final textPrimary = isDark
        ? AppColors.textPrimary
        : const Color(0xFF0F172A);
    final textSecondary = isDark
        ? AppColors.textSecondary
        : const Color(0xFF64748B);
    final card = isDark ? AppColors.card : Colors.white;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: isDark ? 0 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.m),
          side: isDark
              ? BorderSide.none
              : const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.m),
          ),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.m),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.m),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.m),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        hintStyle: TextStyle(color: textSecondary),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryColor;
          return textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected))
            return primaryColor.withValues(alpha: 0.5);
          return isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
        }),
      ),
    );
  }

  static ThemeData darkTheme(Color primary, Color secondary) => getTheme(
    primaryColor: primary,
    secondaryColor: secondary,
    brightness: Brightness.dark,
  );

  static ThemeData lightTheme(Color primary, Color secondary) => getTheme(
    primaryColor: primary,
    secondaryColor: secondary,
    brightness: Brightness.light,
  );
}
