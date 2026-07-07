import 'google_auth_service.dart';

/// Web / unknown platforms: Google sync is not available in v1. Notes on web
/// live in browser storage; use the mobile or desktop app for sync.
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
