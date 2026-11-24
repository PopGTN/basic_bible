import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart' show GZipEncoder;
import 'package:basic_bible/src/features/hymns/data/hymnal_json_codec.dart';
import 'package:basic_bible/src/features/hymns/models/hymnal.dart';
import 'package:flutter_test/flutter_test.dart';

Uint8List _bytes(Object json) =>
    Uint8List.fromList(utf8.encode(jsonEncode(json)));

Hymnal _parse(Object json, {String title = 'My Book'}) => parseHymnalBytes(
  HymnalParseRequest(
    bytes: _bytes(json),
    fallbackId: 'my-book',
    fallbackTitle: title,
  ),
);

Map<String, dynamic> _legacyHymn(
  int id, {
  String? title,
  List<String>? chorus,
}) => {
  'id': id,
  'title': title ?? 'Hymn title $id',
  'author': 'Author $id',
  'meter': 'C.M.',
  'tuneName': '',
  'verses': [
    ['Line one of $id,', 'Line two.'],
    ['Second verse,', 'ends here.'],
  ],
  'chorus': chorus ?? <String>[],
  'addedChorus': <String>[],
};

void main() {
  test('reads the legacy bare-array format', () {
    final hymnal = _parse([
      _legacyHymn(2),
      _legacyHymn(1, chorus: ['Refrain']),
    ]);

    expect(hymnal.info.id, 'my-book');
    expect(hymnal.info.title, 'My Book');
    expect(hymnal.info.schemaVersion, 0);
    expect(hymnal.info.hymnCount, 2);
    expect(hymnal.hymns.map((h) => h.number), [
      1,
      2,
    ], reason: 'sorted by number');
    expect(hymnal.byNumber(1)!.chorus, ['Refrain']);
    expect(hymnal.byNumber(2)!.verses, hasLength(2));
  });

  test('reads the hymnal v1 format with book metadata and extras', () {
    final hymnal = _parse({
      'format': 'hymnal',
      'schemaVersion': 1,
      'book': {
        'id': 'bhb',
        'title': 'The Believers Hymn Book',
        'publisher': 'John Ritchie Ltd',
        'copyright': '© Publisher',
        'permissionNotice': 'Used by permission.',
        'somethingNew': 'ignored',
      },
      'hymns': [
        {
          ..._legacyHymn(1),
          'addedChorus': ['Optional refrain'],
          'notes': ['Sung twice'],
          'optionalVerses': [
            {
              'label': 'Verse 1 of Hymn #2',
              'lines': ['Extra line'],
            },
          ],
          'copyright': '© 1941 Someone',
          'unknownKey': 42,
        },
      ],
    });

    expect(hymnal.info.id, 'bhb');
    expect(hymnal.info.publisher, 'John Ritchie Ltd');
    expect(hymnal.info.schemaVersion, 1);
    expect(hymnal.info.creditLines, ['© Publisher', 'Used by permission.']);
    final hymn = hymnal.byNumber(1)!;
    expect(hymn.alternateChoruses.single.lines, ['Optional refrain']);
    expect(hymn.alternateChoruses.single.label, isNull);
    expect(hymn.optionalVerses.single.label, 'Verse 1 of Hymn #2');
    expect(hymn.notes, ['Sung twice']);
    expect(hymn.copyright, '© 1941 Someone');
  });

  test('decompresses gzipped files', () {
    final gz = Uint8List.fromList(
      GZipEncoder().encode(utf8.encode(jsonEncode([_legacyHymn(7)]))),
    );
    final hymnal = parseHymnalBytes(
      HymnalParseRequest(bytes: gz, fallbackId: 'x', fallbackTitle: 'X'),
    );
    expect(hymnal.byNumber(7), isNotNull);
  });

  test('keeps the first hymn when numbers repeat, skips unusable entries', () {
    final hymnal = _parse([
      _legacyHymn(5, title: 'First'),
      _legacyHymn(5, title: 'Duplicate'),
      {
        'id': 'not a number',
        'verses': [
          ['x'],
        ],
      },
      {'id': 6, 'title': 'No lyrics', 'verses': []},
      'not even a map',
    ]);
    expect(hymnal.hymns, hasLength(1));
    expect(hymnal.byNumber(5)!.title, 'First');
  });

  test('accepts numeric-string ids and fills blank or (c) titles', () {
    final hymnal = _parse([
      {..._legacyHymn(1), 'id': '12', 'title': ''},
      {..._legacyHymn(1), 'id': 13, 'title': '(c)'},
    ]);
    expect(hymnal.byNumber(12)!.title, 'Line one of 1,');
    expect(hymnal.byNumber(13)!.title, 'Line one of 1,');
  });

  test('gives a plain error for files that are not hymnals', () {
    for (final bad in <Object>[
      {'translations': []},
      42,
      <Object>[],
    ]) {
      expect(() => _parse(bad), throwsA(isA<HymnalFormatException>()));
    }
    expect(
      () => parseHymnalBytes(
        HymnalParseRequest(
          bytes: Uint8List.fromList(utf8.encode('{nope')),
          fallbackId: 'x',
          fallbackTitle: 'X',
        ),
      ),
      throwsA(isA<HymnalFormatException>()),
    );
  });
}
