import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';

import 'google_auth_service.dart' as api;
import 'google_oauth_config.dart';

/// Web auth uses the browser OAuth client. The browser client is different from
/// the Android `serverClientId`, so this is a separate platform branch.
class WebGoogleAuthService implements api.GoogleAuthService {
  static const _scopes = [driveAppDataScope];

  bool _initialized = false;
  GoogleSignInAccount? _account;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await GoogleSignIn.instance.initialize(
      clientId: googleWebClientId.isNotEmpty ? googleWebClientId : null,
    );
    _initialized = true;
  }

  // google_sign_in v7 can't run authenticate() on web (it needs the
  // rendered GIS button instead), so report unsupported until that UI exists.
  @override
  bool get isSupported =>
      googleWebClientId.isNotEmpty &&
      GoogleSignIn.instance.supportsAuthenticate();

  @override
  bool get isConfigured => googleWebClientId.isNotEmpty;

  @override
  Future<api.GoogleAccount?> restoreExistingSignIn() async {
    await _ensureInitialized();
    final attempt = GoogleSignIn.instance.attemptLightweightAuthentication();
    final account = attempt == null ? null : await attempt;
    if (account == null) {
      return null;
    }
    _account = account;
    return api.GoogleAccount(email: account.email);
  }

  @override
  Future<api.GoogleAccount> signIn() async {
    await _ensureInitialized();
    final account = await GoogleSignIn.instance.authenticate(
      scopeHint: _scopes,
    );
    _account = account;
    await account.authorizationClient.authorizationForScopes(_scopes) ??
        await account.authorizationClient.authorizeScopes(_scopes);
    return api.GoogleAccount(email: account.email);
  }

  @override
  Future<String> getAccessToken() async {
    await _ensureInitialized();
    final account =
        _account ??
        await (GoogleSignIn.instance.attemptLightweightAuthentication() ??
            Future<GoogleSignInAccount?>.value());
    if (account == null) {
      throw const api.GoogleSignInRequiredException();
    }
    _account = account;
    // Never fall back to interactive authorizeScopes() here: this runs from
    // automatic background syncs, which must not pop a consent dialog the
    // user didn't ask for. Interactive consent happens only in signIn().
    try {
      final authorization = await account.authorizationClient
          .authorizationForScopes(_scopes);
      if (authorization == null) {
        throw const api.GoogleSignInRequiredException(
          'Google Drive access needs to be approved again. Please sign in.',
        );
      }
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

api.GoogleAuthService createGoogleAuthService() => WebGoogleAuthService();
