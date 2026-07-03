// Guards the gzipped bundled-KJV assets: they must exist, decompress, and
// contain what the loaders expect (a SQLite database / a USFX document).
// If someone replaces an asset with a raw (non-gzipped) file or the paths in
// bible_translation_catalog.dart drift, this fails before a release does.

import 'dart:convert';

import 'package:archive/archive.dart' show GZipDecoder;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  List<int> gunzipAsset(ByteData data) {
    return GZipDecoder().decodeBytes(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
  }

  test('bundled kjv.sqlite.gz decompresses to a SQLite database', () async {
    final data = await rootBundle.load('assets/bible/kjv.sqlite.gz');
    final bytes = gunzipAsset(data);

    // Every SQLite file starts with this exact 16-byte header string.
    final header = String.fromCharCodes(bytes.take(15));
    expect(header, 'SQLite format 3');
    expect(bytes.length, greaterThan(10 * 1024 * 1024));
  });

  test('bundled eng-kjv2006_usfx.xml.gz decompresses to a USFX document',
      () async {
    final data = await rootBundle.load('assets/bible/eng-kjv2006_usfx.xml.gz');
    final content = utf8.decode(gunzipAsset(data));

    expect(content, contains('<usfx'));
    expect(content.length, greaterThan(10 * 1024 * 1024));
  });
}
