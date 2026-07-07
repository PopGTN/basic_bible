import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'google_auth_service.dart';
import 'google_oauth_config.dart';

/// Linux/Windows/macOS auth via OAuth 2.0 Authorization Code + PKCE with a
/// loopback redirect (RFC 8252 "OAuth for Native Apps"): open the consent
/// page in the system browser and catch the redirect on a short-lived local
/// HTTP server. Tokens persist in the OS keyring via flutter_secure_storage.
class DesktopGoogleAuthService implements GoogleAuthService {
  DesktopGoogleAuthService({
    FlutterSecureStorage? storage,
    http.Client? client,
  }) : _storage = storage ?? const FlutterSecureStorage(),
       _client = client ?? http.Client();

  final FlutterSecureStorage _storage;
  final http.Client _client;

  static const _scopes = 'openid email $driveAppDataScope';
  static const _keyRefreshToken = 'google_sync_refresh_token';
  static const _keyAccessToken = 'google_sync_access_token';
  static const _keyAccessExpiry = 'google_sync_access_expiry';
  static const _keyEmail = 'google_sync_email';

  @override
  bool get isSupported => true;

  @override
  bool get isConfigured =>
      googleDesktopClientId.isNotEmpty && googleDesktopClientSecret.isNotEmpty;

  @override
  Future<GoogleAccount?> restoreExistingSignIn() async {
    if (!isConfigured) return null;
    final refreshToken = await _storage.read(key: _keyRefreshToken);
    final email = await _storage.read(key: _keyEmail);
    if (refreshToken == null || email == null) return null;
    return GoogleAccount(email: email);
  }

  @override
  Future<GoogleAccount> signIn() async {
    if (!isConfigured) {
      throw StateError(
        'Google sync is not configured: missing desktop OAuth client id/secret.',
      );
    }

    final verifier = _randomUrlSafeString(64);
    final challenge = base64UrlEncode(
      sha256.convert(ascii.encode(verifier)).bytes,
    ).replaceAll('=', '');
    final state = _randomUrlSafeString(32);

    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    try {
      final redirectUri = 'http://${server.address.address}:${server.port}';
      final consentUrl = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
        'client_id': googleDesktopClientId,
        'redirect_uri': redirectUri,
        'response_type': 'code',
        'scope': _scopes,
        'code_challenge': challenge,
        'code_challenge_method': 'S256',
        'state': state,
        // Always get a refresh token, not just on first consent.
        'access_type': 'offline',
        'prompt': 'consent',
      });

      if (!await launchUrl(consentUrl, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not open the browser for Google sign-in.');
      }

      final request = await server.first.timeout(
        const Duration(minutes: 5),
        onTimeout: () => throw TimeoutException(
          'Google sign-in timed out waiting for the browser.',
        ),
      );
      final params = request.uri.queryParameters;
      final isValid = params['state'] == state && params['code'] != null;
      request.response
        ..statusCode = 200
        ..headers.contentType = ContentType.html
        ..write(
          isValid
              ? '<html><body><h3>Signed in.</h3>'
                    'You can close this tab and return to the Bible app.'
                    '</body></html>'
              : '<html><body><h3>Sign-in failed.</h3></body></html>',
        );
      await request.response.close();

      if (params['error'] != null) {
        throw Exception('Google sign-in was denied: ${params['error']}');
      }
      if (!isValid) {
        throw Exception('Google sign-in failed: invalid redirect.');
      }

      final tokens = await _postToken({
        'code': params['code']!,
        'client_id': googleDesktopClientId,
        'client_secret': googleDesktopClientSecret,
        'redirect_uri': redirectUri,
        'grant_type': 'authorization_code',
        'code_verifier': verifier,
      });

      final refreshToken = tokens['refresh_token'] as String?;
      if (refreshToken == null) {
        throw Exception('Google did not return a refresh token.');
      }
      final accessToken = tokens['access_token'] as String;
      final email = await _fetchEmail(accessToken);

      await _storage.write(key: _keyRefreshToken, value: refreshToken);
      await _storage.write(key: _keyEmail, value: email);
      await _storeAccessToken(accessToken, tokens['expires_in'] as int? ?? 0);
      return GoogleAccount(email: email);
    } finally {
      await server.close(force: true);
    }
  }

  @override
  Future<String> getAccessToken() async {
    final cached = await _storage.read(key: _keyAccessToken);
    final expiryRaw = await _storage.read(key: _keyAccessExpiry);
    final expiry = expiryRaw == null ? null : DateTime.tryParse(expiryRaw);
    if (cached != null &&
        expiry != null &&
        expiry.isAfter(DateTime.now().add(const Duration(minutes: 1)))) {
      return cached;
    }

    final refreshToken = await _storage.read(key: _keyRefreshToken);
    if (refreshToken == null) {
      throw const GoogleSignInRequiredException();
    }
    final Map<String, dynamic> tokens;
    try {
      tokens = await _postToken({
        'refresh_token': refreshToken,
        'client_id': googleDesktopClientId,
        'client_secret': googleDesktopClientSecret,
        'grant_type': 'refresh_token',
      });
    } on _TokenEndpointException catch (e) {
      if (e.error == 'invalid_grant') {
        // Refresh token revoked or expired — a full sign-in is required.
        await signOut();
        throw const GoogleSignInRequiredException(
          'Your Google session expired. Please sign in again.',
        );
      }
      rethrow;
    }
    final accessToken = tokens['access_token'] as String;
    await _storeAccessToken(accessToken, tokens['expires_in'] as int? ?? 0);
    return accessToken;
  }

  @override
  Future<void> signOut() async {
    final refreshToken = await _storage.read(key: _keyRefreshToken);
    if (refreshToken != null) {
      // Best effort — clearing local state matters more than the revoke call.
      try {
        await _client.post(
          Uri.https('oauth2.googleapis.com', '/revoke', {
            'token': refreshToken,
          }),
        );
      } catch (_) {}
    }
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyAccessExpiry);
    await _storage.delete(key: _keyEmail);
  }

  Future<void> _storeAccessToken(String token, int expiresInSeconds) async {
    await _storage.write(key: _keyAccessToken, value: token);
    await _storage.write(
      key: _keyAccessExpiry,
      value: DateTime.now()
          .add(Duration(seconds: expiresInSeconds))
          .toIso8601String(),
    );
  }

  Future<Map<String, dynamic>> _postToken(Map<String, String> body) async {
    final response = await _client.post(
      Uri.https('oauth2.googleapis.com', '/token'),
      body: body,
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw _TokenEndpointException(
        json['error'] as String? ?? 'http_${response.statusCode}',
        json['error_description'] as String?,
      );
    }
    return json;
  }

  Future<String> _fetchEmail(String accessToken) async {
    final response = await _client.get(
      Uri.https('openidconnect.googleapis.com', '/v1/userinfo'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode != 200) {
      throw Exception('Could not read the Google account profile.');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return json['email'] as String? ?? 'Google account';
  }

  static String _randomUrlSafeString(int bytes) {
    final random = Random.secure();
    final values = List<int>.generate(bytes, (_) => random.nextInt(256));
    return base64UrlEncode(values).replaceAll('=', '');
  }
}

class _TokenEndpointException implements Exception {
  const _TokenEndpointException(this.error, this.description);

  final String error;
  final String? description;

  @override
  String toString() =>
      'Google token request failed: $error${description == null ? '' : ' — $description'}';
}
