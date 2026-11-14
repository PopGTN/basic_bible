// Issue #87: books without chapters (the WEB's FRT preface and GLO glossary)
// were listed in the book picker but only led to "Chapter not found". They
// now get one readable front-matter page; chapterless books with no text are
// dropped.

import 'package:basic_bible/src/features/library/data/bible_parser_worker.dart';
import 'package:basic_bible/src/features/reader/application/view_models/bible_library_view_models.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/utils/reference_utils.dart';
import 'package:flutter_test/flutter_test.dart';

BibleBook _book(String id, int chapters, {String? intro}) => BibleBook(
  id: id,
  name: id,
  shortName: id,
  bookNumber: 0,
  chapters: [for (var c = 1; c <= chapters; c++) BibleChapter(number: c)],
  introductionBlocks: [
    if (intro != null)
      BibleDocumentBlock(kind: BibleDocumentBlockKind.preface, text: intro),
  ],
);

void main() {
  test('a chapterless book with text gets one front-matter page', () {
    final books = readableBooks([
      _book('FRT', 0, intro: 'Preface to the World English Bible'),
      _book('GEN', 50),
    ]);
    expect(books.map((b) => b.id), ['FRT', 'GEN']);
    expect(books.first.chapters.map((c) => c.number), [kFrontMatterChapter]);
    expect(books.first.introductionBlocks, isNotEmpty);
  });

  test('a chapterless book with no text is dropped', () {
    final books = readableBooks([
      _book('XXX', 0),
      _book('BLANK', 0, intro: '   '),
      _book('GEN', 50),
    ]);
    expect(books.map((b) => b.id), ['GEN']);
  });

  test('the same list instance is returned when nothing changes', () {
    final books = [_book('GEN', 50), _book('EXO', 40)];
    expect(identical(readableBooks(books), books), isTrue);
  });

  test('labels drop the number for a front-matter page', () {
    expect(chapterReferenceLabel('Preface', kFrontMatterChapter), 'Preface');
    expect(chapterReferenceLabel('Genesis', 3), 'Genesis 3');
  });

  test('real USFX front matter becomes a readable page', () async {
    final parsed = await parseBibleContentToBooks(_usfx);
    final books = readableBooks(parsed);
    final preface = books.firstWhere((b) => b.id == 'FRT');
    expect(preface.chapters.single.number, kFrontMatterChapter);
    expect(preferredBookName(preface), 'Preface');
    expect(
      preface.introductionBlocks.map((b) => b.text),
      contains('What is the Holy Bible?'),
    );
  });
}

// Trimmed from the WEB's eng-web.usfx.xml.
const _usfx = '''<?xml version="1.0" encoding="utf-8"?>
<usfx>
<book id="FRT"><id id="FRT">Preface to the World English Bible </id><h>Preface </h><toc level="1">Preface </toc><toc level="2">Preface </toc>
<p sfm="mt">Preface to the World English Bible </p><p sfm="is">What is the Holy Bible? </p>
<p sfm="ip">The Holy Bible is a collection of books and letters. </p></book>
<book id="GEN"><h>Genesis</h><c id="1"/><p><v id="1"/>In the beginning.<ve/></p></book>
</usfx>''';
