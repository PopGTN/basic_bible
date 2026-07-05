import 'package:basic_bible/src/services/shared_preferences_provider.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gates experimental/in-progress reader features (currently: partial
/// highlights) behind an explicit opt-in. Off by default.
final advancedModeEnabledProvider =
    StateNotifierProvider<AdvancedModeNotifier, bool>((ref) {
      return AdvancedModeNotifier(ref.read(sharedPreferencesProvider));
    });

class AdvancedModeNotifier extends StateNotifier<bool> {
  AdvancedModeNotifier(this._prefs) : super(_prefs.getBool(_key) ?? false);

  static const _key = 'settings_advanced_mode_enabled';
  final SharedPreferences _prefs;

  Future<void> setEnabled(bool enabled) async {
    final previous = state;
    state = enabled;
    try {
      final ok = await _prefs.setBool(_key, enabled);
      if (!ok && state == enabled) state = previous;
    } catch (_) {
      if (state == enabled) state = previous;
      rethrow;
    }
  }
}

final translationCatalogUrlOverrideProvider =
    StateNotifierProvider<TranslationCatalogUrlOverrideNotifier, String?>((
      ref,
    ) {
      return TranslationCatalogUrlOverrideNotifier(
        ref.read(sharedPreferencesProvider),
      );
    });

class TranslationCatalogUrlOverrideNotifier extends StateNotifier<String?> {
  TranslationCatalogUrlOverrideNotifier(this._prefs)
    : super(_normalize(_prefs.getString(_prefKey)));

  static const _prefKey = 'advanced_translation_catalog_url_override';
  final SharedPreferences _prefs;

  static String? _normalize(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> setUrl(String url) async {
    final normalized = _normalize(url);
    if (normalized == null) {
      await resetToDefault();
      return;
    }
    await _prefs.setString(_prefKey, normalized);
    state = normalized;
  }

  Future<void> resetToDefault() async {
    await _prefs.remove(_prefKey);
    state = null;
  }
}
