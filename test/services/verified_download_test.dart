import 'dart:convert';

import 'package:basic_bible/src/services/verified_download.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final body = utf8.encode('hello hymnal');
  final goodSha = sha256.convert(body).toString();
  final client = MockClient((request) async => http.Response.bytes(body, 200));

  Future<List<int>> fetch(
    String url, {
    String? sha,
    int maxBytes = 1024,
    int? expectedSize,
    bool allowLocal = false,
  }) => fetchVerifiedHttps(
    Uri.parse(url),
    client: client,
    maxBytes: maxBytes,
    actionLabel: 'download test',
    expectedSha256: sha,
    expectedSize: expectedSize,
    allowLocalhostHttp: allowLocal,
  );

  test('returns the bytes when the checksum matches', () async {
    expect(await fetch('https://example.org/a.json', sha: goodSha), body);
    expect(
      await fetch('https://example.org/a.json'),
      body,
      reason: 'no checksum is allowed',
    );
  });

  test('refuses a checksum mismatch', () {
    expect(
      fetch('https://example.org/a.json', sha: 'ab' * 32),
      throwsA(
        isA<VerifiedDownloadException>().having(
          (e) => e.message,
          'message',
          contains('SHA-256'),
        ),
      ),
    );
  });

  test('refuses plain http, except localhost when allowed', () async {
    expect(
      fetch('http://example.org/a.json'),
      throwsA(isA<VerifiedDownloadException>()),
    );
    expect(
      fetch('http://example.org/a.json', allowLocal: true),
      throwsA(isA<VerifiedDownloadException>()),
    );
    expect(await fetch('http://localhost:8000/a.json', allowLocal: true), body);
  });

  test('enforces the size cap on declared and streamed sizes', () {
    expect(
      fetch('https://example.org/a.json', expectedSize: 5000),
      throwsA(isA<VerifiedDownloadException>()),
    );
    expect(
      fetch('https://example.org/a.json', maxBytes: 4),
      throwsA(isA<VerifiedDownloadException>()),
    );
  });

  test('reports non-200 responses', () {
    final failing = MockClient((request) async => http.Response('nope', 404));
    expect(
      fetchVerifiedHttps(
        Uri.parse('https://example.org/x'),
        client: failing,
        maxBytes: 1024,
        actionLabel: 'x',
      ),
      throwsA(
        isA<VerifiedDownloadException>().having(
          (e) => e.message,
          'message',
          contains('404'),
        ),
      ),
    );
  });
}
