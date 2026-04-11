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

class BoldDivineNameNotifier extends StateNotifier<bool> {
  BoldDivineNameNotifier(this._prefs)
    : super(_prefs.getBool(_prefKey) ?? false);

  static const _prefKey = 'reader_bold_divine_name';
  final SharedPreferences _prefs;

  Future<void> setEnabled(bool enabled) async {
    await _prefs.setBool(_prefKey, enabled);
    state = enabled;
  }
}

class UnderlineProperNamesNotifier extends StateNotifier<bool> {
  UnderlineProperNamesNotifier(this._prefs)
    : super(_prefs.getBool(_prefKey) ?? true);

  static const _prefKey = 'reader_underline_proper_names';
  final SharedPreferences _prefs;

  Future<void> setEnabled(bool enabled) async {
    await _prefs.setBool(_prefKey, enabled);
    state = enabled;
  }
}
