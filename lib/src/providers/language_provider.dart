import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// This provider holds the current language code (e.g., 'en', 'es')
final languageProvider = StateNotifierProvider<LanguageNotifier, String>(
  (ref) => LanguageNotifier(),
);

class LanguageNotifier extends StateNotifier<String> {
  LanguageNotifier() : super('en') {
    _loadLanguage();
  }

  /// Load saved language from persistent storage
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('languageCode');
    if (savedLang != null) {
      state = savedLang;
    } else {
      // Optionally auto-detect system locale on first launch
      final defaultLang = WidgetsBinding.instance.window.locale.languageCode;
      state = defaultLang;
      await prefs.setString('languageCode', defaultLang);
    }
  }

  /// Update language and save it persistently
  Future<void> setLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', code);
    state = code;
  }
}
