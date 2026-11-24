import 'dart:async';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

/// Reports bytes received so far and the expected total (null if unknown).
typedef VerifiedDownloadProgress = void Function(int received, int? total);

/// Thrown for every download failure; [message] is safe to show the user.
class VerifiedDownloadException implements Exception {
  const VerifiedDownloadException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Downloads [uri] with the safety rules every content download shares
/// (Bible translations, hymnals):
///
/// - https only (plain http is refused unless [allowLocalhostHttp] and the
///   host is localhost, for testing a local repository);
/// - a hard [maxBytes] ceiling, checked against the declared size, the
///   Content-Length header *and* the streamed body, so a server that lies
///   about its size still can't fill memory;
/// - an optional SHA-256 check: a mismatch means corruption or tampering, so
///   the bytes are refused. A missing checksum is allowed.
Future<Uint8List> fetchVerifiedHttps(
  Uri uri, {
  required http.Client client,
  required int maxBytes,
  required String actionLabel,
  int? expectedSize,
  String? expectedSha256,
  Duration timeout = const Duration(seconds: 20),
  VerifiedDownloadProgress? onProgress,
  bool allowLocalhostHttp = false,
}) async {
  final isLocalHttp =
      allowLocalhostHttp &&
      uri.scheme == 'http' &&
      (uri.host == 'localhost' || uri.host == '127.0.0.1');
  if (uri.scheme != 'https' && !isLocalHttp) {
    throw VerifiedDownloadException(
      'Refusing to $actionLabel: only https:// download URLs are allowed '
      '(got "${uri.scheme}://").',
    );
  }
  final limitMb = maxBytes ~/ (1024 * 1024);
  if (expectedSize != null && expectedSize > maxBytes) {
    throw VerifiedDownloadException(
      'Refusing to $actionLabel: the file is larger than the $limitMb MB '
      'download limit.',
    );
  }

  try {
    final response = await client
        .send(http.Request('GET', uri))
        .timeout(timeout);
    if (response.statusCode != 200) {
      throw VerifiedDownloadException('HTTP ${response.statusCode}');
    }
    if ((response.contentLength ?? 0) > maxBytes) {
      throw VerifiedDownloadException(
        'The file is larger than the $limitMb MB download limit.',
      );
    }

    final builder = BytesBuilder(copy: false);
    final total = response.contentLength ?? expectedSize;
    onProgress?.call(0, total);
    await for (final chunk in response.stream.timeout(timeout)) {
      builder.add(chunk);
      onProgress?.call(builder.length, total);
      if (builder.length > maxBytes) {
        throw VerifiedDownloadException(
          'The download exceeded the $limitMb MB limit and was aborted.',
        );
      }
    }
    final bytes = builder.takeBytes();
    verifySha256(bytes, expectedSha256);
    return bytes;
  } on TimeoutException {
    throw VerifiedDownloadException(
      'Timed out trying to $actionLabel. Please check your internet '
      'connection and try again.',
    );
  } catch (error) {
    throw VerifiedDownloadException('Failed to $actionLabel: $error');
  }
}

/// Throws when [expected] is set and does not match [bytes].
void verifySha256(List<int> bytes, String? expected) {
  final want = expected?.trim().toLowerCase();
  if (want == null || want.isEmpty) return;
  if (sha256.convert(bytes).toString() != want) {
    throw const VerifiedDownloadException(
      'The downloaded file failed its integrity check (SHA-256 mismatch). '
      'It may have been corrupted or tampered with — please try again.',
    );
  }
}
