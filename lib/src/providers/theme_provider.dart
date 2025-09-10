import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enum for all supported app themes.
/// - `system`: Follows device settings
/// - `light`: Standard light theme
/// - `dark`: Standard dark theme
/// - `blue`: Custom blue theme
/// - `red`: Custom red theme
enum AppThemeMode {
  system,
  light,
  dark,
  blue,
  red,
}

/// StateNotifier that manages the app's theme and persists it.
/// - Loads theme from SharedPreferences on startup
/// - Allows switching themes at runtime
class ThemeNotifier extends StateNotifier<AppThemeMode> {
  ThemeNotifier() : super(AppThemeMode.system) {
    _loadTheme();
  }

  /// Loads saved theme from SharedPreferences
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

  /// Saves the selected theme and updates the state
  Future<void> setTheme(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.toString());
    state = mode;
  }
}

/// Riverpod provider that exposes the current theme state
final themeProvider =
    StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  return ThemeNotifier();
});

/// Predefined ThemeData for each mode.
/// You can expand this to add more customization (fonts, shapes, etc.)
final themeDataMap = {
  AppThemeMode.light: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(254, 242,185,101),
      brightness: Brightness.light,
    ),
  ),
  AppThemeMode.dark: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color.fromARGB(254, 242,185,101),
      brightness: Brightness.dark,
    ),
  ),
  AppThemeMode.blue: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
  ),
  AppThemeMode.red: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.red,
      brightness: Brightness.light,
    ),
  ),
};

/// Maps [AppThemeMode] to Flutter's built-in [ThemeMode].
/// This is useful because Flutter's MaterialApp expects a ThemeMode.
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

/// Gets the actual [ThemeData] for a given [AppThemeMode].
/// Used inside `MaterialApp.theme` and `darkTheme`.
ThemeData getThemeData(AppThemeMode mode) {
  switch (mode) {
    case AppThemeMode.system:
      // Default to light for previews, actual system theme is handled by ThemeMode
      return themeDataMap[AppThemeMode.light]!;
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
