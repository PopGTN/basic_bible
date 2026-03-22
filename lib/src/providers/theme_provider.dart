import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported app themes.
enum AppThemeMode {
  system,
  light,
  dark,
  softDark,
  black,
  oledBlack,
  white,
  blue,
  red,
}

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
  AppThemeMode.softDark: _buildSoftDarkTheme(),
  AppThemeMode.black: _buildMonochromeTheme(brightness: Brightness.dark),
  AppThemeMode.oledBlack: _buildOledBlackTheme(),
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
    case AppThemeMode.softDark:
    case AppThemeMode.black:
    case AppThemeMode.oledBlack:
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
    case AppThemeMode.softDark:
      return themeDataMap[AppThemeMode.softDark]!;
    case AppThemeMode.black:
      return themeDataMap[AppThemeMode.black]!;
    case AppThemeMode.oledBlack:
      return themeDataMap[AppThemeMode.oledBlack]!;
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
    case AppThemeMode.softDark:
      return themeDataMap[AppThemeMode.softDark]!;
    case AppThemeMode.black:
      return themeDataMap[AppThemeMode.black]!;
    case AppThemeMode.oledBlack:
      return themeDataMap[AppThemeMode.oledBlack]!;
    case AppThemeMode.light:
    case AppThemeMode.white:
    case AppThemeMode.blue:
    case AppThemeMode.red:
      return themeDataMap[AppThemeMode.dark]!;
  }
}

ThemeData _buildOledBlackTheme() {
  const background = Colors.black;
  const foreground = Color(0xFFF5F5F5);
  const onSurfaceVariant = Color(0xFFBDBDBD);
  const outline = Color(0xFF5C5C5C);
  const outlineVariant = Color(0xFF2A2A2A);
  const controlFill = Color(0xFF101010);

  final scheme = const ColorScheme.dark().copyWith(
    brightness: Brightness.dark,
    primary: foreground,
    onPrimary: background,
    secondary: foreground,
    onSecondary: background,
    primaryContainer: controlFill,
    onPrimaryContainer: foreground,
    secondaryContainer: controlFill,
    onSecondaryContainer: foreground,
    tertiary: foreground,
    onTertiary: background,
    surface: background,
    onSurface: foreground,
    onSurfaceVariant: onSurfaceVariant,
    surfaceContainerLowest: background,
    surfaceContainerLow: background,
    surfaceContainer: background,
    surfaceContainerHigh: background,
    surfaceContainerHighest: controlFill,
    outline: outline,
    outlineVariant: outlineVariant,
    shadow: Colors.black,
    surfaceTint: Colors.transparent,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: background,
    canvasColor: background,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: foreground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    iconTheme: const IconThemeData(color: foreground),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return foreground;
        return onSurfaceVariant;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return foreground.withValues(alpha: 0.28);
        }
        return controlFill;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return foreground;
        return outline;
      }),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: background,
      selectedColor: controlFill,
      disabledColor: background,
      side: const BorderSide(color: outline),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      labelStyle: const TextStyle(color: foreground),
      secondaryLabelStyle: const TextStyle(color: foreground),
      brightness: Brightness.dark,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: foreground,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: foreground,
        side: const BorderSide(color: outline),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: background,
      hintStyle: const TextStyle(color: onSurfaceVariant),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: foreground),
      ),
    ),
    dividerColor: outline,
  );
}

ThemeData _buildSoftDarkTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  final scheme = base.colorScheme.copyWith(
    brightness: Brightness.dark,
    surface: const Color(0xFF16181C),
    onSurface: const Color(0xFFF4F4F5),
    onSurfaceVariant: const Color(0xFFD5D7DB),
    primaryContainer: const Color(0xFF2A2D33),
    onPrimaryContainer: const Color(0xFFF4F4F5),
    secondaryContainer: const Color(0xFF2A2D33),
    onSecondaryContainer: const Color(0xFFF4F4F5),
    surfaceContainerLowest: const Color(0xFF111317),
    surfaceContainerLow: const Color(0xFF1B1D22),
    surfaceContainer: const Color(0xFF23262C),
    surfaceContainerHigh: const Color(0xFF2B2F36),
    surfaceContainerHighest: const Color(0xFF343841),
    outline: const Color(0xFF70747D),
    outlineVariant: const Color(0xFF494D55),
    surfaceTint: Colors.transparent,
  );

  // This gives users a darker reader that still keeps selected controls
  // readable, without the harsher black-on-black contrast of pure black mode.
  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    canvasColor: scheme.surface,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.onSurface,
        side: BorderSide(color: scheme.outline),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerLow,
      hintStyle: TextStyle(color: scheme.onSurfaceVariant),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: scheme.onSurface),
      ),
    ),
    dividerColor: scheme.outlineVariant,
  );
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
