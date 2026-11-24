import 'package:basic_bible/src/features/hymns/data/hymn_layout.dart';
import 'package:basic_bible/src/features/hymns/models/hymn.dart';
import 'package:basic_bible/src/features/hymns/models/hymnal.dart';
import 'package:flutter_test/flutter_test.dart';

const _hymn = Hymn(
  number: 7,
  title: 'Test hymn',
  author: 'A. Writer',
  meter: 'C.M.',
  verses: [
    ['v1 a', 'v1 b'],
    ['v2 a', 'v2 b'],
    ['v3 a', 'v3 b'],
  ],
  chorus: ['c a', 'c b'],
  alternateChoruses: [
    HymnPart(lines: ['alt']),
  ],
  optionalVerses: [
    HymnPart(label: 'From hymn 8', lines: ['opt']),
  ],
  notes: ['Sung slowly'],
  copyright: '© 1941 Someone',
);

const _book = HymnalInfo(
  id: 'bhb',
  title: 'The Believers Hymn Book',
  copyright: '© Publisher',
  permissionNotice: 'Used by permission.',
);

List<HymnBlockKind> _kinds(ChorusPlacement placement) =>
    layoutHymn(_hymn, placement: placement).map((b) => b.kind).toList();

void main() {
  test('chorus after the first verse by default', () {
    expect(_kinds(ChorusPlacement.afterFirstVerse), [
      HymnBlockKind.verse,
      HymnBlockKind.chorus,
      HymnBlockKind.verse,
      HymnBlockKind.verse,
      HymnBlockKind.optionalVerse,
      HymnBlockKind.alternateChorus,
    ]);
  });

  test('chorus after every verse when chosen', () {
    expect(
      _kinds(
        ChorusPlacement.afterEveryVerse,
      ).where((k) => k == HymnBlockKind.chorus).length,
      3,
    );
  });

  test('optional parts can be hidden', () {
    final blocks = layoutHymn(_hymn, includeOptional: false);
    expect(blocks.any((b) => b.isOptional), isFalse);
  });

  test('a chorus-only hymn still shows its chorus', () {
    final blocks = layoutHymn(const Hymn(number: 1, title: 'x', chorus: ['c']));
    expect(blocks.single.kind, HymnBlockKind.chorus);
  });

  test('plain text always carries the credit lines', () {
    final text = formatHymnAsText(_hymn, _book);
    expect(text, startsWith('7. Test hymn\nA. Writer · C.M.'));
    expect(text, contains('Chorus:\n    c a'));
    expect(text, contains('* Sung slowly'));
    expect(
      text,
      endsWith(
        '© 1941 Someone\nFrom The Believers Hymn Book (#7)\n'
        '© Publisher\nUsed by permission.',
      ),
    );
  });
}
