import 'package:basic_bible/src/features/annotations/models/annotation_verse_ranges.dart';
import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';
import 'package:flutter_test/flutter_test.dart';

AnnotationVerseLink _v(
  int verse, {
  String book = 'GEN',
  int chapter = 1,
  String translation = 'kjv',
}) => AnnotationVerseLink(
  bookId: book,
  chapter: chapter,
  verse: verse,
  translationId: translation,
  translationName: translation.toUpperCase(),
);

List<String> _labels(Iterable<AnnotationVerseLink> links) => [
  for (final range in groupConsecutiveVerses(links)) range.label('Genesis'),
];

void main() {
  test('a contiguous reader selection collapses into one range', () {
    expect(_labels([for (var v = 1; v <= 10; v++) _v(v)]), ['Genesis 1:1-10']);
  });

  test('a single verse keeps the plain label', () {
    expect(_labels([_v(4)]), ['Genesis 1:4']);
  });

  test('gaps start a new range', () {
    expect(_labels([_v(1), _v(2), _v(5), _v(6), _v(9)]), [
      'Genesis 1:1-2',
      'Genesis 1:5-6',
      'Genesis 1:9',
    ]);
  });

  test('chapter, book and translation boundaries are never merged', () {
    final ranges = groupConsecutiveVerses([
      _v(31),
      _v(32, chapter: 2),
      _v(33, chapter: 2, book: 'EXO'),
      _v(34, chapter: 2, book: 'EXO', translation: 'web'),
    ]);
    expect(ranges, hasLength(4));
  });

  test('stored order is preserved rather than sorted', () {
    expect(_labels([_v(3), _v(1), _v(2)]), ['Genesis 1:3', 'Genesis 1:1-2']);
  });

  test('verseRanges puts the primary verse range first', () {
    final note = UserAnnotation(
      type: UserAnnotationType.note,
      primaryVerse: _v(1),
      linkedVerses: [_v(2), _v(3), _v(7)],
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
    final ranges = note.verseRanges;
    expect(ranges.first.label('Genesis'), 'Genesis 1:1-3');
    expect(ranges.skip(1).map((r) => r.label('Genesis')), ['Genesis 1:7']);
  });

  test('verses tapped out of order still read as one passage', () {
    // The screenshot case: Luke 15 selected in tap order, primary = 15:23.
    final tapOrder = [24, 25, 26, 28, 27, 29, 30, 31, 32, 22, 21, 20, 18, 19,
      17, 16, 15, 14, 13, 3, 1, 2, 4, 5, 6, 7, 8, 9, 10, 11, 12];
    final note = UserAnnotation(
      type: UserAnnotationType.note,
      primaryVerse: _v(23, book: 'LUK', chapter: 15),
      linkedVerses: [for (final v in tapOrder) _v(v, book: 'LUK', chapter: 15)],
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
    final ranges = note.verseRanges;
    expect(ranges, hasLength(1));
    expect(ranges.single.label('Luke'), 'Luke 15:1-32');
  });

  test('the range containing the primary verse is the heading', () {
    final note = UserAnnotation(
      type: UserAnnotationType.note,
      primaryVerse: _v(10),
      linkedVerses: [_v(1), _v(2), _v(11)],
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
    expect(note.verseRanges.map((r) => r.label('Genesis')), [
      'Genesis 1:10-11',
      'Genesis 1:1-2',
    ]);
  });

  test('reading order spans books canonically, not alphabetically', () {
    final sorted = sortVerseLinksInReadingOrder([
      _v(1, book: 'REV'),
      _v(1, book: 'EXO'),
      _v(1, book: 'GEN', chapter: 2),
      _v(1, book: 'GEN'),
    ]);
    expect([for (final l in sorted) '${l.bookId} ${l.chapter}'], [
      'GEN 1',
      'GEN 2',
      'EXO 1',
      'REV 1',
    ]);
  });
}
