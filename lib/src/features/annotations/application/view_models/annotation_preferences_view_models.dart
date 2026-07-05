import 'package:basic_bible/src/services/shared_preferences_provider.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

final confirmRemoveLinkedVerseProvider =
    StateNotifierProvider<ConfirmRemoveLinkedVerseNotifier, bool>((ref) {
      return ConfirmRemoveLinkedVerseNotifier(
        ref.read(sharedPreferencesProvider),
      );
    });

class ConfirmRemoveLinkedVerseNotifier extends StateNotifier<bool> {
  ConfirmRemoveLinkedVerseNotifier(this._prefs)
    : super(_prefs.getBool(_key) ?? true);

  static const _key = 'notes_confirm_remove_linked_verse';
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

/// When enabled, notes and highlights saved against one translation are also
/// shown while reading any other translation, matched by book/chapter/verse
/// alone. Off by default so notes stay scoped to the translation they were
/// created in.
final showNotesAcrossTranslationsProvider =
    StateNotifierProvider<ShowNotesAcrossTranslationsNotifier, bool>((ref) {
      return ShowNotesAcrossTranslationsNotifier(
        ref.read(sharedPreferencesProvider),
      );
    });

class ShowNotesAcrossTranslationsNotifier extends StateNotifier<bool> {
  ShowNotesAcrossTranslationsNotifier(this._prefs)
    : super(_prefs.getBool(_key) ?? false);

  static const _key = 'notes_show_across_translations';
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
