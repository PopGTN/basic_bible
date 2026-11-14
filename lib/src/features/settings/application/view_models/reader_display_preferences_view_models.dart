import 'package:basic_bible/src/services/shared_preferences_provider.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

final boldDivineNameProvider =
    StateNotifierProvider<BoldDivineNameNotifier, bool>((ref) {
      return BoldDivineNameNotifier(ref.read(sharedPreferencesProvider));
    });

final underlineProperNamesProvider =
    StateNotifierProvider<UnderlineProperNamesNotifier, bool>((ref) {
      return UnderlineProperNamesNotifier(ref.read(sharedPreferencesProvider));
    });

final underlineWordMetadataProvider =
    StateNotifierProvider<UnderlineWordMetadataNotifier, bool>((ref) {
      return UnderlineWordMetadataNotifier(ref.read(sharedPreferencesProvider));
    });

final bracketTranslatorAdditionsProvider =
    StateNotifierProvider<BracketTranslatorAdditionsNotifier, bool>((ref) {
      return BracketTranslatorAdditionsNotifier(
        ref.read(sharedPreferencesProvider),
      );
    });

final useSourceBoldStylingProvider =
    StateNotifierProvider<UseSourceBoldStylingNotifier, bool>((ref) {
      return UseSourceBoldStylingNotifier(ref.read(sharedPreferencesProvider));
    });

final showSourceDetailsProvider =
    StateNotifierProvider<ShowSourceDetailsNotifier, bool>((ref) {
      return ShowSourceDetailsNotifier(ref.read(sharedPreferencesProvider));
    });

abstract class _ReaderDisplayPreferenceNotifier extends StateNotifier<bool> {
  _ReaderDisplayPreferenceNotifier(
    this._prefs,
    this._prefKey,
    bool defaultValue,
  ) : super(_prefs.getBool(_prefKey) ?? defaultValue);

  final SharedPreferences _prefs;
  final String _prefKey;

  Future<void> setEnabled(bool enabled) async {
    final previousState = state;
    state = enabled;

    try {
      final didPersist = await _prefs.setBool(_prefKey, enabled);
      if (!didPersist && state == enabled) {
        state = previousState;
      }
    } catch (_) {
      if (state == enabled) {
        state = previousState;
      }
      rethrow;
    }
  }
}

class BoldDivineNameNotifier extends _ReaderDisplayPreferenceNotifier {
  BoldDivineNameNotifier(SharedPreferences prefs)
    : super(prefs, 'reader_bold_divine_name', false);
}

class UnderlineProperNamesNotifier extends _ReaderDisplayPreferenceNotifier {
  UnderlineProperNamesNotifier(SharedPreferences prefs)
    : super(prefs, 'reader_underline_proper_names', true);
}

class UnderlineWordMetadataNotifier extends _ReaderDisplayPreferenceNotifier {
  UnderlineWordMetadataNotifier(SharedPreferences prefs)
    : super(prefs, 'reader_underline_word_metadata', false);
}

class BracketTranslatorAdditionsNotifier
    extends _ReaderDisplayPreferenceNotifier {
  BracketTranslatorAdditionsNotifier(SharedPreferences prefs)
    : super(prefs, 'reader_bracket_translator_additions', false);
}

class UseSourceBoldStylingNotifier extends _ReaderDisplayPreferenceNotifier {
  UseSourceBoldStylingNotifier(SharedPreferences prefs)
    : super(prefs, 'reader_use_source_bold_styling', true);
}

class ShowSourceDetailsNotifier extends _ReaderDisplayPreferenceNotifier {
  ShowSourceDetailsNotifier(SharedPreferences prefs)
    : super(prefs, 'reader_show_source_details', false);
}
