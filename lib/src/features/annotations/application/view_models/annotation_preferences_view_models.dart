import 'package:basic_bible/src/features/settings/application/view_models/advanced_preferences_view_models.dart';
import 'package:basic_bible/src/services/shared_preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// Nested under Advanced Mode: lets the user drag across a verse to highlight
/// only the words dragged over, instead of always highlighting the whole
/// verse. Stored independently of [advancedModeEnabledProvider] so the
/// preference survives toggling Advanced Mode off and back on, but it only
/// takes effect while Advanced Mode is also enabled — see
/// [partialHighlightingActiveProvider].
final partialHighlightsEnabledProvider =
    StateNotifierProvider<PartialHighlightsEnabledNotifier, bool>((ref) {
      return PartialHighlightsEnabledNotifier(
        ref.read(sharedPreferencesProvider),
      );
    });

class PartialHighlightsEnabledNotifier extends StateNotifier<bool> {
  PartialHighlightsEnabledNotifier(this._prefs)
    : super(_prefs.getBool(_key) ?? false);

  static const _key = 'notes_partial_highlights_enabled';
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

/// Whether the reader should actually offer the partial-highlight drag
/// gesture right now — requires both the global Advanced Mode switch and the
/// nested Partial Highlights switch to be on.
final partialHighlightingActiveProvider = Provider<bool>((ref) {
  return ref.watch(advancedModeEnabledProvider) &&
      ref.watch(partialHighlightsEnabledProvider);
});
