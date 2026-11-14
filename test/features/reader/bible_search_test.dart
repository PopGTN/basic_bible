// Issue #69: Bible text search behind the reader's search button.

import 'package:basic_bible/src/features/reader/application/view_models/bible_search_view_models.dart';
import 'package:basic_bible/src/features/reader/presentation/search/bible_search_screen.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/services/translation_database.dart';
import 'package:drift/native.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

BibleBook _book(String id, int number, Map<int, List<String>> chapters) =>
    BibleBook(
      id: id,
      name: id,
      shortName: id,
      bookNumber: number,
      chapters: [
        for (final entry in chapters.entries)
          BibleChapter(
            number: entry.key,
            verses: [
              for (final (i, text) in entry.value.indexed)
                BibleVerse(number: i + 1, text: text),
            ],
          ),
      ],
    );

final _books = [
  _book('GEN', 1, {
    1: ['In the beginning God created the heaven and the earth.'],
  }),
  _book('JHN', 43, {
    3: [
      'There was a man of the Pharisees.',
      'For God so loved the world, that he gave his only begotten Son.',
    ],
  }),
  _book('1JN', 62, {
    4: ['God is love; and he that dwelleth in love dwelleth in God.'],
  }),
];

List<String> _refs(List<BibleSearchHit> hits) => [
  for (final h in hits) '${h.bookId} ${h.chapter}:${h.verse}',
];

void main() {
  test('terms are lower-cased and stripped of punctuation', () {
    expect(bibleSearchTerms('  Love, GOD!  '), ['love', 'god']);
    expect(bibleSearchTerms(' , '), isEmpty);
  });

  group('database search', () {
    late TranslationDatabase db;
    setUp(() async {
      db = TranslationDatabase(NativeDatabase.memory());
      await db.insertBible(_books);
    });
    tearDown(() => db.close());

    test('every term must appear, in any order, case-insensitively', () async {
      expect(_refs(await db.searchVerses(['god', 'love'])), [
        'JHN 3:2',
        '1JN 4:1',
      ]);
      expect(_refs(await db.searchVerses(['beginning'])), ['GEN 1:1']);
    });

    test('results come in canonical order and respect the limit', () async {
      expect(_refs(await db.searchVerses(['god'])), [
        'GEN 1:1',
        'JHN 3:2',
        '1JN 4:1',
      ]);
      expect(await db.searchVerses(['god'], limit: 1), hasLength(1));
    });

    test('book scope restricts results', () async {
      expect(_refs(await db.searchVerses(['god'], bookIds: {'1JN'})), [
        '1JN 4:1',
      ]);
    });

    test('LIKE wildcards in the query are matched literally', () async {
      expect(await db.searchVerses(['%']), isEmpty);
      expect(await db.searchVerses(['_']), isEmpty);
    });
  });

  test('in-memory search matches the database semantics', () {
    final hits = searchBooksInMemory(_books, ['god', 'love']);
    expect(_refs(hits), ['JHN 3:2', '1JN 4:1']);
  });

  test('testament scopes', () {
    expect(
      bookIdsForSearchScope(
        BibleSearchScope.newTestament,
        _books,
        currentBookId: 'GEN',
      ),
      {'JHN', '1JN'},
    );
    expect(
      bookIdsForSearchScope(
        BibleSearchScope.currentBook,
        _books,
        currentBookId: 'GEN',
      ),
      {'GEN'},
    );
    expect(
      bookIdsForSearchScope(BibleSearchScope.all, _books, currentBookId: 'GEN'),
      isNull,
    );
  });

  test('matches are highlighted case-insensitively', () {
    const bold = TextStyle(fontWeight: FontWeight.bold);
    final span = highlightSearchTerms('God is love', ['love', 'god'], highlight: bold);
    final parts = [
      for (final child in span.children!.cast<TextSpan>())
        (child.text, child.style == bold),
    ];
    expect(parts, [('God', true), (' is ', false), ('love', true)]);
  });
}
