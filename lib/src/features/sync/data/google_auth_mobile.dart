import 'dart:async';
import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';

import 'google_auth_service.dart' as api;
import 'google_oauth_config.dart';

/// Android/iOS auth via the google_sign_in plugin (v7 API).
class MobileGoogleAuthService implements api.GoogleAuthService {
  static const _scopes = [driveAppDataScope];

  bool _initialized = false;
  GoogleSignInAccount? _account;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await GoogleSignIn.instance.initialize(
      // Android resolves its client by package name + SHA-1; iOS can also be
      // configured via Info.plist, in which case this stays empty.
      clientId: Platform.isIOS && googleIosClientId.isNotEmpty
          ? googleIosClientId
          : null,
    );
    _initialized = true;
  }

  @override
  bool get isSupported => true;

  @override
  // Mobile clients are registered in the Cloud console, not passed in code,
  // so there is nothing to check at runtime here.
  bool get isConfigured => true;

  @override
  Future<api.GoogleAccount?> restoreExistingSignIn() async {
    await _ensureInitialized();
    final attempt = GoogleSignIn.instance.attemptLightweightAuthentication();
    final account = attempt == null ? null : await attempt;
    _account = account;
    return account == null ? null : api.GoogleAccount(email: account.email);
  }

  @override
  Future<api.GoogleAccount> signIn() async {
    await _ensureInitialized();
    final account = await GoogleSignIn.instance.authenticate(
      scopeHint: _scopes,
    );
    _account = account;
    // Complete Drive consent as part of sign-in so the first sync doesn't
    // surprise the user with a second prompt.
    await account.authorizationClient.authorizationForScopes(_scopes) ??
        await account.authorizationClient.authorizeScopes(_scopes);
    return api.GoogleAccount(email: account.email);
  }

  @override
  Future<String> getAccessToken() async {
    await _ensureInitialized();
    final account = _account ??
        await (GoogleSignIn.instance.attemptLightweightAuthentication() ??
            Future<GoogleSignInAccount?>.value());
    if (account == null) {
      throw const api.GoogleSignInRequiredException();
    }
    _account = account;
    try {
      final authorization =
          await account.authorizationClient.authorizationForScopes(_scopes) ??
          await account.authorizationClient.authorizeScopes(_scopes);
      return authorization.accessToken;
    } on GoogleSignInException catch (e) {
      throw api.GoogleSignInRequiredException(
        'Google authorization failed: ${e.description ?? e.code.name}',
      );
    }
  }

  @override
  Future<void> signOut() async {
    await _ensureInitialized();
    _account = null;
    await GoogleSignIn.instance.signOut();
  }
}
