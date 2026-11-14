// Issue #87: books without chapters (e.g. a USFX FRT preface) were listed in
// the book picker and reachable via next/previous chapter, but can't be read.

import 'package:basic_bible/src/features/reader/application/view_models/bible_library_view_models.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:flutter_test/flutter_test.dart';

BibleBook _book(String id, int chapters) => BibleBook(
  id: id,
  name: id,
  shortName: id,
  bookNumber: 0,
  chapters: [for (var c = 1; c <= chapters; c++) BibleChapter(number: c)],
);

void main() {
  test('chapterless books are dropped, order kept', () {
    final books = [_book('FRT', 0), _book('GEN', 50), _book('GLO', 0), _book('EXO', 40)];
    expect(booksWithChapters(books).map((b) => b.id), ['GEN', 'EXO']);
  });

  test('the same list instance is returned when nothing is removed', () {
    final books = [_book('GEN', 50), _book('EXO', 40)];
    expect(identical(booksWithChapters(books), books), isTrue);
  });

  test('an all-chapterless translation is left as is', () {
    final books = [_book('FRT', 0)];
    expect(identical(booksWithChapters(books), books), isTrue);
  });

  test('next chapter from the last chapter of Genesis skips front matter', () {
    // Navigation steps through the filtered list, so a chapterless book in
    // between is never landed on.
    final readable = booksWithChapters([_book('GEN', 1), _book('XXX', 0), _book('EXO', 1)]);
    final genIndex = readable.indexWhere((b) => b.id == 'GEN');
    expect(readable[genIndex + 1].id, 'EXO');
  });
}
