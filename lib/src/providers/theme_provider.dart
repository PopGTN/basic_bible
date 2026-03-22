import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported app themes.
enum AppThemeMode { system, light, dark, black, white, blue, red }

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

final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  return ThemeNotifier();
});

final themeDataMap = {
  AppThemeMode.light: _buildSeedTheme(
    seedColor: const Color.fromARGB(254, 242, 185, 101),
    brightness: Brightness.light,
  ),
  AppThemeMode.dark: _buildSeedTheme(
    seedColor: const Color.fromARGB(254, 242, 185, 101),
    brightness: Brightness.dark,
  ),
  AppThemeMode.black: _buildMonochromeTheme(brightness: Brightness.dark),
  AppThemeMode.white: _buildMonochromeTheme(brightness: Brightness.light),
  AppThemeMode.blue: _buildSeedTheme(
    seedColor: Colors.blue,
    brightness: Brightness.light,
  ),
  AppThemeMode.red: _buildSeedTheme(
    seedColor: Colors.red,
    brightness: Brightness.light,
  ),
};

ThemeMode mapThemeMode(AppThemeMode mode) {
  switch (mode) {
    case AppThemeMode.system:
      return ThemeMode.system;
    case AppThemeMode.dark:
    case AppThemeMode.black:
      return ThemeMode.dark;
    case AppThemeMode.light:
    case AppThemeMode.white:
    case AppThemeMode.blue:
    case AppThemeMode.red:
      return ThemeMode.light;
  }
}

ThemeData getThemeData(AppThemeMode mode) {
  switch (mode) {
    case AppThemeMode.system:
      return themeDataMap[AppThemeMode.light]!;
    case AppThemeMode.light:
      return themeDataMap[AppThemeMode.light]!;
    case AppThemeMode.dark:
      return themeDataMap[AppThemeMode.dark]!;
    case AppThemeMode.black:
      return themeDataMap[AppThemeMode.black]!;
    case AppThemeMode.white:
      return themeDataMap[AppThemeMode.white]!;
    case AppThemeMode.blue:
      return themeDataMap[AppThemeMode.blue]!;
    case AppThemeMode.red:
      return themeDataMap[AppThemeMode.red]!;
  }
}

ThemeData getDarkThemeData(AppThemeMode mode) {
  switch (mode) {
    case AppThemeMode.system:
      // System dark mode should feel like the reader-first prototype: true
      // black surfaces instead of Flutter's default dark grey theme.
      return themeDataMap[AppThemeMode.black]!;
    case AppThemeMode.dark:
      return themeDataMap[AppThemeMode.dark]!;
    case AppThemeMode.black:
      return themeDataMap[AppThemeMode.black]!;
    case AppThemeMode.light:
    case AppThemeMode.white:
    case AppThemeMode.blue:
    case AppThemeMode.red:
      return themeDataMap[AppThemeMode.dark]!;
  }
}

ThemeData _buildSeedTheme({
  required Color seedColor,
  required Brightness brightness,
}) {
  final scheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: brightness,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
  );
}

ThemeData _buildMonochromeTheme({required Brightness brightness}) {
  final isDark = brightness == Brightness.dark;
  final background = isDark ? Colors.black : Colors.white;
  final foreground = isDark ? Colors.white : Colors.black;
  final lowSurface = isDark ? const Color(0xFF050505) : const Color(0xFFF7F7F7);
  final midSurface = isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF1F1F1);
  final highSurface = isDark
      ? const Color(0xFF151515)
      : const Color(0xFFEAEAEA);
  final outline = isDark ? const Color(0xFF5B5B5B) : const Color(0xFFC3C3C3);
  final outlineVariant = isDark
      ? const Color(0xFF3D3D3D)
      : const Color(0xFFD9D9D9);
  final secondary = isDark ? const Color(0xFFE6E6E6) : const Color(0xFF111111);
  final onSurfaceVariant = isDark
      ? const Color(0xFFD0D0D0)
      : const Color(0xFF3A3A3A);

  final scheme = (isDark ? const ColorScheme.dark() : const ColorScheme.light())
      .copyWith(
        brightness: brightness,
        primary: background,
        onPrimary: foreground,
        secondary: secondary,
        onSecondary: background,
        primaryContainer: highSurface,
        onPrimaryContainer: foreground,
        secondaryContainer: highSurface,
        onSecondaryContainer: foreground,
        tertiary: foreground,
        onTertiary: background,
        surface: background,
        onSurface: foreground,
        onSurfaceVariant: onSurfaceVariant,
        surfaceContainerLowest: background,
        surfaceContainerLow: lowSurface,
        surfaceContainer: midSurface,
        surfaceContainerHigh: midSurface,
        surfaceContainerHighest: highSurface,
        outline: outline,
        outlineVariant: outlineVariant,
        shadow: isDark ? Colors.black : const Color(0x22000000),
        surfaceTint: Colors.transparent,
      );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: background,
    canvasColor: background,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: foreground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    iconTheme: IconThemeData(color: foreground),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: foreground,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: foreground,
        side: BorderSide(color: outline),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: midSurface,
      hintStyle: TextStyle(color: onSurfaceVariant),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: foreground),
      ),
    ),
    dividerColor: outline,
  );
}
