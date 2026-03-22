import 'package:flutter/foundation.dart';
import 'package:basic_bible/src/services/shared_preferences_provider.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier(this._prefs) : super(_prefs.getBool(_prefKey) ?? false);

  static const _prefKey = 'isLoggedIn';
  final SharedPreferences _prefs;

  Future<void> login() async {
    try {
      await _prefs.setBool(_prefKey, true);
      if (mounted) state = true;
    } catch (e) {
      debugPrint('Login error: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _prefs.setBool(_prefKey, false);
      if (mounted) state = false;
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier(ref.read(sharedPreferencesProvider));
});
