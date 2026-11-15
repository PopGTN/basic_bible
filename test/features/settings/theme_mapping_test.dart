// Guards issue #8: with the app theme on "System" and the device in dark
// mode, MaterialApp used to fall back to Flutter's stock ThemeData.dark()
// (default purple seed) instead of one of the app's own dark themes.

import 'package:basic_bible/src/features/settings/application/view_models/theme_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every mode supplies an app-defined dark theme, never the stock one',
      () {
    final stockDark = ThemeData.dark(useMaterial3: true).colorScheme;
    for (final mode in AppThemeMode.values) {
      final dark = getDarkThemeData(mode);
      expect(dark.brightness, Brightness.dark, reason: '$mode');
      expect(
        themeDataMap.values.any((t) => identical(t, dark)),
        isTrue,
        reason: '$mode must use one of the app themes',
      );
      expect(dark.colorScheme, isNot(stockDark), reason: '$mode');
    }
  });

  test('System follows the device: light theme by day, app dark by night', () {
    expect(mapThemeMode(AppThemeMode.system), ThemeMode.system);
    expect(getThemeData(AppThemeMode.system).brightness, Brightness.light);
    // Deliberate product choice (1d30edc): System dark uses the pure-black
    // reader theme.
    expect(
      identical(
        getDarkThemeData(AppThemeMode.system),
        themeDataMap[AppThemeMode.black],
      ),
      isTrue,
    );
  });
}
