import 'package:basic_bible/src/services/shared_preferences_provider.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

final openBibleTabByDefaultProvider =
    StateNotifierProvider<OpenBibleTabByDefaultNotifier, bool>((ref) {
      return OpenBibleTabByDefaultNotifier(ref.read(sharedPreferencesProvider));
    });

final requireDummyLoginProvider =
    StateNotifierProvider<RequireDummyLoginNotifier, bool>((ref) {
      return RequireDummyLoginNotifier(ref.read(sharedPreferencesProvider));
    });

class OpenBibleTabByDefaultNotifier extends StateNotifier<bool> {
  OpenBibleTabByDefaultNotifier(this._prefs)
    : super(_prefs.getBool(_prefKey) ?? false);

  static const _prefKey = 'app_open_bible_tab_by_default';
  final SharedPreferences _prefs;

  Future<void> setEnabled(bool enabled) async {
    await _prefs.setBool(_prefKey, enabled);
    state = enabled;
  }
}

class RequireDummyLoginNotifier extends StateNotifier<bool> {
  RequireDummyLoginNotifier(this._prefs)
    : super(_prefs.getBool(_prefKey) ?? true);

  static const _prefKey = 'app_require_dummy_login';
  final SharedPreferences _prefs;

  Future<void> setEnabled(bool enabled) async {
    await _prefs.setBool(_prefKey, enabled);
    state = enabled;
  }
}
