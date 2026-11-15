import 'package:basic_bible/src/services/shared_preferences_provider.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
