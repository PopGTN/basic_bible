import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:basic_bible/src/features/library/data/bible_archive_support.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('decodeBibleArchiveText', () {
    test('extracts USFX content from a zip archive', () {
      final bytes = _zipBytes({
        'eng-kjv2006_usfx.xml': _sampleUsfx,
      });

      final document = decodeBibleArchiveText(
        bytes,
        sourceName: 'eng-kjv2006_usfx.zip',
        hintedFormat: BibleFormat.zip,
      );

      expect(document.wasArchived, isTrue);
      expect(document.format, BibleFormat.usfx);
      expect(document.sourceName, 'eng-kjv2006_usfx.xml');
      expect(document.content, contains('<usfx'));
    });

    test('rejects zip archives that only contain USFM files', () {
      final bytes = _zipBytes({
        '70-MATeng-kjv2006.usfm': '\\id MAT\n\\c 1\n\\v 1 Hello',
      });

      expect(
        () => decodeBibleArchiveText(
          bytes,
          sourceName: 'eng-kjv2006_usfm.zip',
          hintedFormat: BibleFormat.zip,
        ),
        throwsA(
          isA<UnsupportedBibleArchiveException>().having(
            (e) => e.toString(),
            'message',
            contains('USFM'),
          ),
        ),
      );
    });

    test('reports invalid zip archives with a friendly error', () {
      final invalidZipBytes = <int>[0x50, 0x4B, 0x03, 0x04, 0x00, 0x01];

      expect(
        () => decodeBibleArchiveText(
          invalidZipBytes,
          sourceName: 'broken.zip',
          hintedFormat: BibleFormat.zip,
        ),
        throwsA(isA<InvalidBibleArchiveException>()),
      );
    });
  });

  group('normalizeBibleFormat', () {
    test('prefers zip when the file name is a zip archive', () {
      final normalized = normalizeBibleFormat(
        declaredFormat: BibleFormat.usfx,
        fileName: 'eng-kjv2006_usfx.zip',
        bytes: _zipBytes({'eng-kjv2006_usfx.xml': _sampleUsfx}),
      );

      expect(normalized, BibleFormat.zip);
    });
  });
}

List<int> _zipBytes(Map<String, String> entries) {
  final archive = Archive();
  for (final entry in entries.entries) {
    archive.addFile(
      ArchiveFile(
        entry.key,
        entry.value.length,
        utf8.encode(entry.value),
      ),
    );
  }
  return ZipEncoder().encode(archive);
}

const String _sampleUsfx = '''
<?xml version="1.0" encoding="utf-8"?>
<usfx version="2.5">
  <book id="MAT">
    <c id="1" />
    <v id="1" />The book of the generation of Jesus Christ.
  </book>
</usfx>
''';
