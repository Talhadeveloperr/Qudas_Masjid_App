// qudas/lib/utils/app_colors.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeType { green, white, black, blue }

class AppTheme {
  // Global Notifier for Theme State
  static final ValueNotifier<AppThemeType> themeNotifier =
      ValueNotifier<AppThemeType>(AppThemeType.green);

  static const String _themePrefKey = 'app_theme_pref';

  // Initialize theme from SharedPreferences
  static Future<void> initTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeIndex = prefs.getInt(_themePrefKey) ?? 0;
    if (savedThemeIndex >= 0 && savedThemeIndex < AppThemeType.values.length) {
      themeNotifier.value = AppThemeType.values[savedThemeIndex];
    }
  }

  // Change Theme and Save to SharedPreferences
  static Future<void> changeTheme(AppThemeType type) async {
    themeNotifier.value = type;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themePrefKey, type.index);
  }

  // Generate ThemeData based on type
  static ThemeData getThemeData(AppThemeType type) {
    Color primaryColor;
    Color scaffoldBackgroundColor;
    Brightness brightness;

    switch (type) {
      case AppThemeType.green:
        primaryColor = const Color(0xFF004E2D);
        scaffoldBackgroundColor = const Color(0xFFF8F9FF);
        brightness = Brightness.light;
        break;
      case AppThemeType.white:
        // Use a dark slate color for primary when theme is 'white' to ensure contrast
        primaryColor = const Color(0xFF213145);
        scaffoldBackgroundColor = const Color(0xFFF8F9FF);
        brightness = Brightness.light;
        break;
      case AppThemeType.black:
        // Inverse theme for dark mode
        primaryColor = const Color(0xFF82D8A3); 
        scaffoldBackgroundColor = const Color(0xFF0B1C30);
        brightness = Brightness.dark;
        break;
      case AppThemeType.blue:
        primaryColor = const Color(0xFF294759);
        scaffoldBackgroundColor = const Color(0xFFF8F9FF);
        brightness = Brightness.light;
        break;
    }

    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: brightness,
        primary: primaryColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: brightness == Brightness.dark ? Colors.black : Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: brightness == Brightness.dark ? Colors.black : Colors.white,
        ),
      ),
      useMaterial3: true,
    );
  }
}
