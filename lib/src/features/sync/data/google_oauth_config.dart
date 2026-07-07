/// OAuth client configuration for Google Drive notes sync.
///
/// These come from your Google Cloud project (APIs & Services → Credentials).
/// See docs/google_sync_setup.md for the exact console steps. Values can be
/// hardcoded here or injected at build time with --dart-define, e.g.
///   flutter run --dart-define=GOOGLE_DESKTOP_CLIENT_ID=... \
///               --dart-define=GOOGLE_DESKTOP_CLIENT_SECRET=...
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

/// "iOS" OAuth client id. Android needs no value here — its client is matched
/// by package name + SHA-1 in the Cloud console.
const String googleIosClientId = String.fromEnvironment(
  'GOOGLE_IOS_CLIENT_ID',
  defaultValue: '',
);

/// Hidden, app-private space inside the user's own Drive. This scope can only
/// see files this app created — never the user's real Drive contents.
const String driveAppDataScope = 'https://www.googleapis.com/auth/drive.appdata';
