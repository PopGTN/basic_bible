import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Enum for multiple themes
enum AppThemeMode {
  system,
  light,
  dark,
  blue,
  red,
}

// StateNotifier to manage the theme
class ThemeNotifier extends StateNotifier<AppThemeMode> {
  ThemeNotifier() : super(AppThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('themeMode');
    if (saved != null) {
      state = AppThemeMode.values.firstWhere(
        (e) => e.toString() == saved,
        orElse: () => AppThemeMode.system,
      );
    }
  }

  Future<void> setTheme(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.toString());
    state = mode;
  }
}

// Provider for Riverpod
final themeProvider =
    StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) => ThemeNotifier());

// ThemeData for each theme
final themeDataMap = {
  AppThemeMode.light: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.light),
  ),
  AppThemeMode.dark: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.dark),
  ),
  AppThemeMode.blue: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light),
  ),
  AppThemeMode.red: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.red, brightness: Brightness.light),
  ),
};

// Helper to map AppThemeMode to Flutter's ThemeMode
ThemeMode mapThemeMode(AppThemeMode mode) {
  switch (mode) {
    case AppThemeMode.system:
      return ThemeMode.system;
    case AppThemeMode.light:
    case AppThemeMode.blue:
    case AppThemeMode.red:
      return ThemeMode.light;
    case AppThemeMode.dark:
      return ThemeMode.dark;
  }
}

ThemeData getThemeData(AppThemeMode mode) {
  switch (mode) {
    case AppThemeMode.system:
      return themeDataMap[AppThemeMode.light]!; // fallback, system uses ThemeMode.system
    case AppThemeMode.light:
      return themeDataMap[AppThemeMode.light]!;
    case AppThemeMode.dark:
      return themeDataMap[AppThemeMode.dark]!;
    case AppThemeMode.blue:
      return themeDataMap[AppThemeMode.blue]!;
    case AppThemeMode.red:
      return themeDataMap[AppThemeMode.red]!;
  }
}
