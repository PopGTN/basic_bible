# Google Drive notes sync — one-time setup

Notes sync stores each note as a small JSON file in the **hidden app-data
area of the user's own Google Drive** (`drive.appdata` scope). The app can
only see files it created — never the user's real Drive contents — and the
data never touches a server you operate.

Before sync can work, you (the app owner) must create OAuth credentials in
Google Cloud Console. This is a one-time task; users just tap "Sign in with
Google".

## 1. Create the project and enable the Drive API

1. Go to <https://console.cloud.google.com/> and create a project
   (e.g. `basic-bible-sync`).
2. **APIs & Services → Library** → search **Google Drive API** → **Enable**.

## 2. Configure the OAuth consent screen

**APIs & Services → OAuth consent screen** (Google is migrating this to
"Google Auth Platform" — same settings):

1. User type: **External**.
2. App name, support email, developer contact — fill in.
3. **Scopes** → *Add or remove scopes* → add
   `https://www.googleapis.com/auth/drive.appdata`.
4. **Test users** → add your own Google account(s) (and any testers).

The app starts in **Testing** mode: up to 100 test users, refresh tokens for
desktop expire after 7 days, and users see an "unverified app" notice.
That's fine for development. Before a public release you must submit the app
for Google's verification review (standard for any app using a sensitive
scope like `drive.appdata`).

## 3. Create OAuth client IDs (APIs & Services → Credentials)

Create one **OAuth client ID** per platform you ship:

### Desktop (Linux / Windows / macOS loopback flow)
- Type: **Desktop app**.
- Copy the **Client ID** and **Client secret**. (A desktop client secret is
  not confidential — shipping it in the binary is Google's intended usage
  for installed apps.)

### Android
- Type: **Android**.
- Package name: `ca.joshuamc.basic_bible`
- SHA-1: from the repo's `android/` folder run `./gradlew signingReport`
  and copy the debug (and later, release) SHA-1.
- Also create a **Web application** OAuth client. Copy its **Client ID** and
  use it as the `serverClientId` in the Google Sign-In initialization. This is
  required for the mobile Google Sign-In flow and is the missing step behind
  the "serverClientId must be provided" error.

### iOS (only if you ship iOS)
- Type: **iOS**, bundle ID from `ios/Runner.xcodeproj`
  (currently `com.example.basicBible` — change it to a real ID first).
- Add the **reversed client ID** as a URL scheme in `ios/Runner/Info.plist`
  (`CFBundleURLTypes`), per the google_sign_in package README.

## 4. Run / build with the credentials

Client IDs are injected at build time from a **gitignored** file (see
`lib/src/features/sync/data/google_oauth_config.dart`). Never commit real
values: this repository is public.

```bash
cp dart_defines.example.json dart_defines.json
# fill in GOOGLE_DESKTOP_CLIENT_ID / _SECRET, GOOGLE_WEB_CLIENT_ID,
# GOOGLE_IOS_CLIENT_ID in dart_defines.json, then:
flutter run -d linux   --dart-define-from-file=dart_defines.json
flutter run -d android --dart-define-from-file=dart_defines.json
flutter build apk      --dart-define-from-file=dart_defines.json
```

- Desktop needs `GOOGLE_DESKTOP_CLIENT_ID` and `GOOGLE_DESKTOP_CLIENT_SECRET`.
- Android needs `GOOGLE_WEB_CLIENT_ID` (used as the server client id).
- iOS needs `GOOGLE_IOS_CLIENT_ID`.

The VS Code launch configurations already pass this flag.

Until the desktop values are provided, the Settings → Sync section shows
"Google sync is not configured for this build" and everything else in the
app works normally.

## How the sync stays safe

- Every note has a permanent UUID; each note is its own Drive file
  (`<uuid>.json`), so changing one note physically cannot touch another.
- Merging is per-note last-write-wins with deterministic tie-breaking;
  deletes are tombstones, so a device that syncs late sees the deletion
  instead of resurrecting the note.
- An unchanged library syncs with a single HTTP call (each file's
  `updatedAt` is stamped into Drive `appProperties`, so planning happens on
  the listing alone).
