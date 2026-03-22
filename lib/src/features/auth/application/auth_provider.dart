import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

// StateNotifier handles async saving/loading of login state
class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier() : super(false) {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) { // ensures state is only updated if the notifier is still alive
        state = prefs.getBool('isLoggedIn') ?? false;
      }
    } catch (e) {
      // Handle errors if needed
      state = false;
      debugPrint('Login error: $e');

    }
  }

  Future<void> login() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      if (mounted) state = true;
    } catch (e) {
      // handle error
      debugPrint('Login error: $e');
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      if (mounted) state = false;
    } catch (e) {
      // handle error
      debugPrint('Logout error: $e');
    }
  }
}

// Riverpod provider
final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier();
});
