import 'dart:io';

import 'google_auth_desktop.dart';
import 'google_auth_mobile.dart';
import 'google_auth_service.dart';

/// Conditional imports can only split io/web, not per-OS, so the io build
/// picks the concrete service at runtime: google_sign_in where it's actually
/// supported (Android/iOS), the OAuth loopback flow on desktop.
GoogleAuthService createGoogleAuthService() {
  if (Platform.isAndroid || Platform.isIOS) {
    return MobileGoogleAuthService();
  }
  return DesktopGoogleAuthService();
}
