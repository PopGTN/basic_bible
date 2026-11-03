import 'google_auth_service.dart';

/// Unknown platforms (neither dart:io nor the browser): Google sync is not
/// available; use the mobile or desktop app for sync.
class _UnsupportedGoogleAuthService implements GoogleAuthService {
  const _UnsupportedGoogleAuthService();

  @override
  bool get isSupported => false;

  @override
  bool get isConfigured => false;

  @override
  Future<GoogleAccount?> restoreExistingSignIn() async => null;

  @override
  Future<GoogleAccount> signIn() {
    throw UnsupportedError(
      'Google sync is not supported on this platform yet.',
    );
  }

  @override
  Future<String> getAccessToken() {
    throw UnsupportedError(
      'Google sync is not supported on this platform yet.',
    );
  }

  @override
  Future<void> signOut() async {}
}

GoogleAuthService createGoogleAuthService() =>
    const _UnsupportedGoogleAuthService();
