import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:basic_bible/src/features/library/data/usfm_bundle_support.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('tryExtractUsfmBundle', () {
    test('extracts a plain usfm file', () {
      final bundle = tryExtractUsfmBundle(
        utf8.encode(r'\id GEN \c 1 \v 1 In the beginning'),
        sourceName: '01-GEN.usfm',
      );

      expect(bundle, isNotNull);
      expect(bundle!.files, hasLength(1));
      expect(bundle.files.single.name, '01-GEN.usfm');
    });

    test('extracts usfm entries from a zip archive', () {
      final archive = Archive()
        ..addFile(
          ArchiveFile(
            '70-MAT.usfm',
            24,
            utf8.encode(r'\id MAT \c 1 \v 1 Test'),
          ),
        );

      final bundle = tryExtractUsfmBundle(
        ZipEncoder().encode(archive),
        sourceName: 'mat.zip',
      );

      expect(bundle, isNotNull);
      expect(bundle!.files, hasLength(1));
      expect(bundle.files.single.name, '70-MAT.usfm');
    });
  });
}
