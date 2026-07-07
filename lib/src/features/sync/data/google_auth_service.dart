import 'google_auth_service_stub.dart'
    if (dart.library.io) 'google_auth_service_native.dart'
    as impl;

/// The signed-in Google account, reduced to what the sync UI needs.
class GoogleAccount {
  const GoogleAccount({required this.email});

  final String email;
}

/// Thrown when a sync operation needs the user to sign in (again) —
/// e.g. tokens were revoked from another device.
class GoogleSignInRequiredException implements Exception {
  const GoogleSignInRequiredException([this.message = 'Please sign in again.']);

  final String message;

  @override
  String toString() => message;
}

/// Platform-agnostic Google auth boundary for Drive notes sync.
///
/// Android/iOS use the google_sign_in plugin; Linux/Windows/macOS use a
/// hand-rolled OAuth loopback flow (google_sign_in has no Linux/Windows
/// support); web reports unsupported in v1.
abstract class GoogleAuthService {
  /// Whether Google sync can work on this platform at all.
  bool get isSupported;

  /// Whether the OAuth client ids this platform needs have been provided.
  bool get isConfigured;

  /// Restores a previous session without user interaction, or returns null.
  Future<GoogleAccount?> restoreExistingSignIn();

  /// Interactive sign-in + Drive scope consent.
  Future<GoogleAccount> signIn();

  /// A currently valid bearer token for the Drive appdata scope, refreshing
  /// behind the scenes when needed. Throws [GoogleSignInRequiredException]
  /// when interaction is unavoidable.
  Future<String> getAccessToken();

  Future<void> signOut();
}

GoogleAuthService createGoogleAuthService() => impl.createGoogleAuthService();
