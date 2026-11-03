/// OAuth client configuration for Google Drive notes sync.
///
/// These come from your Google Cloud project (APIs & Services → Credentials).
/// See docs/google_sync_setup.md for the exact console steps. Values are
/// injected at build time from a gitignored file — never hardcode them here
/// (this repo is public):
///   flutter run --dart-define-from-file=dart_defines.json
/// Copy dart_defines.example.json to dart_defines.json to get started.
library;

/// "Desktop app" OAuth client — used by the loopback flow on Linux, Windows,
/// and macOS. Despite the name, a desktop client secret is not confidential
/// (Google's docs say so explicitly); shipping it in the binary is the
/// intended usage for installed apps.
const String googleDesktopClientId = String.fromEnvironment(
  'GOOGLE_DESKTOP_CLIENT_ID',
  defaultValue: '',
);

const String googleDesktopClientSecret = String.fromEnvironment(
  'GOOGLE_DESKTOP_CLIENT_SECRET',
  defaultValue: '',
);

/// Android needs a valid Web OAuth client ID as the "server client ID" when
/// using google_sign_in on mobile. This is required for the serverClientId
/// parameter in GoogleSignIn.instance.initialize().
const String googleWebClientId = String.fromEnvironment(
  'GOOGLE_WEB_CLIENT_ID',
  defaultValue: '',
);

/// "iOS" OAuth client id. Android needs no value here — its client is matched
/// by package name + SHA-1 in the Cloud console.
const String googleIosClientId = String.fromEnvironment(
  'GOOGLE_IOS_CLIENT_ID',
  defaultValue: '',
);

/// Hidden, app-private space inside the user's own Drive. This scope can only
/// see files this app created — never the user's real Drive contents.
const String driveAppDataScope =
    'https://www.googleapis.com/auth/drive.appdata';
