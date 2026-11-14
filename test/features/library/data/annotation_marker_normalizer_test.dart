import 'package:basic_bible/src/features/library/data/annotation_marker_normalizer.dart';
import 'package:basic_bible/src/features/library/data/bible_parser_worker.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:flutter_test/flutter_test.dart';

/// A verse shaped like parser output: per-verse markers starting at "a",
/// attached inline to the first span and mirrored on the footnote list.
BibleVerse _verse(int number, {int footnotes = 0, int references = 0}) {
  final footnoteMarkers = [
    for (var i = 0; i < footnotes; i++) String.fromCharCode(97 + i),
  ];
  final referenceMarkers = [
    for (var i = 0; i < references; i++)
      String.fromCharCode(97 + footnotes + i),
  ];
  return BibleVerse(
    number: number,
    text: 'Verse $number',
    spans: [
      BibleVerseSpan(
        text: 'Verse $number',
        metadata: {
          if (footnoteMarkers.isNotEmpty)
            'footnoteMarkers': footnoteMarkers.join('|'),
          if (referenceMarkers.isNotEmpty)
            'referenceMarkers': referenceMarkers.join('|'),
        },
      ),
    ],
    footnotes: [
      for (final m in footnoteMarkers) BibleFootnote(text: 'note', marker: m),
    ],
    crossReferences: [
      for (final m in referenceMarkers)
        BibleCrossReference(label: 'Gen 1:1', marker: m),
    ],
  );
}

List<String> _inline(BibleVerse v) => [
  for (final span in v.spans)
    for (final key in ['footnoteMarkers', 'referenceMarkers'])
      ...?span.metadata[key]?.split('|'),
];

List<String?> _listed(BibleVerse v) => [
  ...v.footnotes.map((f) => f.marker),
  ...v.crossReferences.map((r) => r.marker),
];

void main() {
  test('markers run across the chapter instead of restarting each verse', () {
    final verses = normalizeChapterAnnotationMarkers([
      _verse(1, footnotes: 1),
      _verse(2),
      _verse(3, footnotes: 2),
      _verse(4, footnotes: 1, references: 1),
    ]);

    expect(verses.expand(_inline), ['a', 'b', 'c', 'd', 'e']);
    // The sheet's lists carry exactly the letters shown inline.
    for (final v in verses) {
      expect(_listed(v), _inline(v));
    }
  });

  test('markers without an inline position still get a unique letter', () {
    final verses = normalizeChapterAnnotationMarkers([
      _verse(1, footnotes: 1),
      const BibleVerse(
        number: 2,
        text: 'x',
        footnotes: [BibleFootnote(text: 'orphan')],
      ),
    ]);
    expect(verses[1].footnotes.single.marker, 'b');
  });

  test('is idempotent, so re-normalizing stored data changes nothing', () {
    final once = normalizeChapterAnnotationMarkers([
      _verse(1, footnotes: 2),
      _verse(2, references: 1),
    ]);
    expect(normalizeChapterAnnotationMarkers(once), once);
  });

  test('chapters with no annotations are returned untouched', () {
    final verses = [_verse(1), _verse(2)];
    expect(identical(normalizeChapterAnnotationMarkers(verses), verses), isTrue);
  });

  test('parsed USFX gets one marker sequence per chapter', () async {
    final books = await parseBibleContentToBooks(_usfx);
    final verses = books.single.chapters.single.verses;
    expect(verses.expand(_inline), ['a', 'b', 'c', 'd']);
    expect(verses.expand(_listed), ['a', 'b', 'c', 'd']);
  });

  test('marker sequence continues past z', () {
    expect(chapterAnnotationMarker(0), 'a');
    expect(chapterAnnotationMarker(25), 'z');
    expect(chapterAnnotationMarker(26), 'aa');
    expect(chapterAnnotationMarker(27), 'ab');
  });
}

// End-to-end through the real parser: KJV-style USFX uses caller="+", so the
// parser generates markers itself and restarts at "a" every verse.
const _usfx = '''<?xml version="1.0" encoding="utf-8"?>
<usfx><book id="GEN"><h>Genesis</h><c id="1"/>
<p><v id="1"/>In the beginning<f caller="+"><fr>1.1 </fr><ft>first</ft></f> God created.<ve/>
<v id="2"/>And the earth<f caller="+"><fr>1.2 </fr><ft>second</ft></f> was void<f caller="+"><fr>1.2 </fr><ft>third</ft></f>.<ve/>
<v id="3"/>And God said<f caller="+"><fr>1.3 </fr><ft>fourth</ft></f>.<ve/></p>
</book></usfx>''';
