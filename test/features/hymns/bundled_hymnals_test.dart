// Guards the bundled hymnal assets: each one listed in kBundledHymnals must
// exist, parse, and carry the book metadata the About sheet and every
// copy/share/print rely on.
//
// The "no TODO_ placeholders" test is the RELEASE GATE for the legal text:
// it fails until the real publisher copyright and permission wording is
// filled into tool/hymnals/<id>.meta.json and the asset is rebuilt.

import 'dart:io';

import 'package:basic_bible/src/features/hymns/data/hymnal_json_codec.dart';
import 'package:basic_bible/src/features/hymns/data/hymnal_repository.dart';
import 'package:basic_bible/src/features/hymns/models/hymnal.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<Hymnal> _load(BundledHymnal book) async {
  final data = await rootBundle.load(book.assetPath);
  return parseHymnalBytes(
    HymnalParseRequest(
      bytes: data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      fallbackId: book.id,
      fallbackTitle: book.title,
      sourceKind: HymnalSourceKind.bundled,
    ),
  );
}

/// The assets are built from the private hymnal sources (`make hymnals`).
/// In a clone without access, skip instead of failing.
String? _skipIfMissing(BundledHymnal book) => File(book.assetPath).existsSync()
    ? null
    : '${book.assetPath} not built (needs the private submodule; run make hymnals)';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final book in kBundledHymnals) {
    final skip = _skipIfMissing(book);
    test(
      '${book.id}: asset parses as a hymnal v1 book with metadata',
      () async {
        final hymnal = await _load(book);
        expect(
          hymnal.info.schemaVersion,
          1,
          reason: 'must be the copyright format',
        );
        expect(hymnal.info.id, book.id);
        expect(hymnal.info.title, book.title);
        expect(hymnal.info.publisher, isNotNull);
        expect(hymnal.info.copyright, isNotNull);
        expect(hymnal.info.permissionNotice, isNotNull);
        expect(hymnal.hymns.length, greaterThan(100));
        final numbers = hymnal.hymns.map((h) => h.number).toList();
        expect(
          numbers.toSet().length,
          numbers.length,
          reason: 'unique numbers',
        );
        for (final hymn in hymnal.hymns) {
          expect(hymn.title.trim(), isNotEmpty, reason: 'hymn ${hymn.number}');
          expect(
            hymn.verses.isNotEmpty || hymn.chorus.isNotEmpty,
            isTrue,
            reason: 'hymn ${hymn.number} has lyrics',
          );
        }
      },
      skip: skip,
    );

    test('${book.id}: no TODO_ placeholders remain (release gate)', () async {
      final info = (await _load(book)).info;
      final todo = info
          .toJson()
          .entries
          .where((e) => '${e.value}'.contains('TODO_'))
          .map((e) => e.key)
          .toList();
      expect(
        todo,
        isEmpty,
        reason:
            'Fill in the real publisher wording in tool/hymnals/${book.id}.meta.json '
            'and rebuild with: dart run tool/hymnals/build_hymnal.dart ${book.id}',
      );
    }, skip: skip);
  }

  test('the default book is bundled', () {
    expect(kBundledHymnals.map((b) => b.id), contains(kDefaultHymnalId));
  });
}
