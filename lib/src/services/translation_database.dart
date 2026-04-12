import 'package:drift/drift.dart';

import '../models/bible_models.dart';
import 'app_database.dart'; // shared type converters
import 'translation_database_executor.dart';

part 'translation_database.g.dart';

// ---------------------------------------------------------------------------
// Tables — no translationId FK needed; the file itself is the translation.
// ---------------------------------------------------------------------------

@DataClassName('TBookEntry')
class TBooks extends Table {
  /// 3-letter uppercase book code, e.g. 'GEN'.
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get shortName => text()();
  IntColumn get bookNumber => integer()();
  IntColumn get bookType => integer()();
  TextColumn get tocLabels =>
      text().map(const BibleTocLabelListConverter()).nullable()();
  TextColumn get introductionBlocks =>
      text().map(const BibleDocumentBlockListConverter()).nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TChapterEntry')
class TChapters extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get bookId => text().references(TBooks, #id)();
  IntColumn get number => integer()();
  TextColumn get blocks =>
      text().map(const BibleDocumentBlockListConverter()).nullable()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {bookId, number},
  ];
}

@DataClassName('TVerseEntry')
class TVerses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get chapterId => integer().references(TChapters, #id)();
  IntColumn get number => integer()();
  TextColumn get verseText => text()();
  TextColumn get notes => text().map(const StringListConverter()).nullable()();
  TextColumn get references =>
      text().map(const StringListConverter()).nullable()();
  TextColumn get spans =>
      text().map(const BibleVerseSpanListConverter()).nullable()();
  TextColumn get footnotes =>
      text().map(const BibleFootnoteListConverter()).nullable()();
  TextColumn get crossReferences =>
      text().map(const BibleCrossReferenceListConverter()).nullable()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {chapterId, number},
  ];
}

// ---------------------------------------------------------------------------
// Database class
// ---------------------------------------------------------------------------

@DriftDatabase(tables: [TBooks, TChapters, TVerses])
class TranslationDatabase extends _$TranslationDatabase {
  TranslationDatabase(super.e);

  @override
  int get schemaVersion => 1;

  // -------------------------------------------------------------------------
  // Write
  // -------------------------------------------------------------------------

  Future<void> insertBible(List<BibleBook> books) async {
    await transaction(() async {
      // Replace all content atomically so re-imports are safe.
      await delete(tVerses).go();
      await delete(tChapters).go();
      await delete(tBooks).go();

      for (final book in books) {
        final bookId = book.id.toUpperCase();

        await into(tBooks).insert(
          TBooksCompanion.insert(
            id: bookId,
            name: book.name,
            shortName: book.shortName,
            bookNumber: book.bookNumber,
            bookType: book.bookType.index,
            tocLabels: Value(book.tocLabels),
            introductionBlocks: Value(book.introductionBlocks),
          ),
          mode: InsertMode.insertOrReplace,
        );

        for (final chapter in book.chapters) {
          final chapterId = await into(tChapters).insert(
            TChaptersCompanion.insert(
              bookId: bookId,
              number: chapter.number,
              blocks: Value(chapter.blocks),
            ),
            mode: InsertMode.insertOrReplace,
          );

          if (chapter.verses.isNotEmpty) {
            await batch((b) {
              b.insertAll(tVerses, [
                for (final verse in chapter.verses)
                  TVersesCompanion.insert(
                    chapterId: chapterId,
                    number: verse.number,
                    verseText: verse.text,
                    notes: Value(verse.notes),
                    references: Value(verse.references),
                    spans: Value(verse.spans),
                    footnotes: Value(verse.footnotes),
                    crossReferences: Value(verse.crossReferences),
                  ),
              ], mode: InsertMode.insertOrReplace);
            });
          }
        }
      }
    });
  }

  Future<void> clearBible() async {
    await transaction(() async {
      await delete(tVerses).go();
      await delete(tChapters).go();
      await delete(tBooks).go();
    });
  }

  // -------------------------------------------------------------------------
  // Read — shell (no verses, fast)
  // -------------------------------------------------------------------------

  Future<List<BibleBook>> getBooksShell() async {
    final bookRows = await (select(
      tBooks,
    )..orderBy([(b) => OrderingTerm(expression: b.bookNumber)])).get();

    if (bookRows.isEmpty) return const [];

    final bookIds = bookRows.map((r) => r.id).toList();
    final chapterRows =
        await (select(tChapters)
              ..where((c) => c.bookId.isIn(bookIds))
              ..orderBy([
                (c) => OrderingTerm(expression: c.bookId),
                (c) => OrderingTerm(expression: c.number),
              ]))
            .get();

    final chaptersByBookId = <String, List<BibleChapter>>{};
    for (final c in chapterRows) {
      chaptersByBookId
          .putIfAbsent(c.bookId, () => [])
          .add(
            BibleChapter(
              number: c.number,
              verses: const [],
              blocks: c.blocks ?? const [],
            ),
          );
    }

    return [
      for (final b in bookRows)
        BibleBook(
          id: b.id,
          name: b.name,
          shortName: b.shortName,
          bookNumber: b.bookNumber,
          bookType: _bookTypeFromIndex(b.bookType),
          chapters: chaptersByBookId[b.id] ?? const [],
          tocLabels: b.tocLabels ?? const [],
          introductionBlocks: b.introductionBlocks ?? const [],
        ),
    ];
  }

  // -------------------------------------------------------------------------
  // Read — full (with verses)
  // -------------------------------------------------------------------------

  Future<List<BibleBook>> getBible() async {
    final bookRows = await (select(
      tBooks,
    )..orderBy([(b) => OrderingTerm(expression: b.bookNumber)])).get();

    if (bookRows.isEmpty) return const [];

    final bookIds = bookRows.map((r) => r.id).toList();
    final chapterRows =
        await (select(tChapters)
              ..where((c) => c.bookId.isIn(bookIds))
              ..orderBy([
                (c) => OrderingTerm(expression: c.bookId),
                (c) => OrderingTerm(expression: c.number),
              ]))
            .get();

    final chapterIds = chapterRows.map((r) => r.id).toList();
    final verseRows = chapterIds.isEmpty
        ? const <TVerseEntry>[]
        : await (select(tVerses)
                ..where((v) => v.chapterId.isIn(chapterIds))
                ..orderBy([
                  (v) => OrderingTerm(expression: v.chapterId),
                  (v) => OrderingTerm(expression: v.number),
                ]))
              .get();

    final versesByChapterId = <int, List<BibleVerse>>{};
    for (final v in verseRows) {
      versesByChapterId.putIfAbsent(v.chapterId, () => []).add(_mapVerse(v));
    }

    final chaptersByBookId = <String, List<BibleChapter>>{};
    for (final c in chapterRows) {
      chaptersByBookId
          .putIfAbsent(c.bookId, () => [])
          .add(
            BibleChapter(
              number: c.number,
              verses: versesByChapterId[c.id] ?? const [],
              blocks: c.blocks ?? const [],
            ),
          );
    }

    return [
      for (final b in bookRows)
        BibleBook(
          id: b.id,
          name: b.name,
          shortName: b.shortName,
          bookNumber: b.bookNumber,
          bookType: _bookTypeFromIndex(b.bookType),
          chapters: chaptersByBookId[b.id] ?? const [],
          tocLabels: b.tocLabels ?? const [],
          introductionBlocks: b.introductionBlocks ?? const [],
        ),
    ];
  }

  // -------------------------------------------------------------------------
  // Read — single chapter with verses (on-demand hydration)
  // -------------------------------------------------------------------------

  Future<BibleChapter?> getChapter(String bookId, int chapterNumber) async {
    final bookRow = await (select(
      tBooks,
    )..where((b) => b.id.equals(bookId.toUpperCase()))).getSingleOrNull();
    if (bookRow == null) return null;

    final chapterRow =
        await (select(tChapters)..where(
              (c) =>
                  c.bookId.equals(bookRow.id) & c.number.equals(chapterNumber),
            ))
            .getSingleOrNull();
    if (chapterRow == null) return null;

    final verseRows =
        await (select(tVerses)
              ..where((v) => v.chapterId.equals(chapterRow.id))
              ..orderBy([(v) => OrderingTerm(expression: v.number)]))
            .get();

    return BibleChapter(
      number: chapterRow.number,
      verses: verseRows.map(_mapVerse).toList(),
      blocks: chapterRow.blocks ?? const [],
    );
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  BibleVerse _mapVerse(TVerseEntry v) => BibleVerse(
    number: v.number,
    text: v.verseText,
    notes: v.notes,
    references: v.references,
    spans: v.spans ?? const [],
    footnotes: v.footnotes ?? const [],
    crossReferences: v.crossReferences ?? const [],
  );
}

BibleBookType _bookTypeFromIndex(int index) =>
    BibleBookType.values[index.clamp(0, BibleBookType.values.length - 1)];

// ---------------------------------------------------------------------------
// Connection factory — called by TranslationDatabaseManager
// ---------------------------------------------------------------------------

TranslationDatabase openTranslationDatabase(String filePath) {
  return TranslationDatabase(openTranslationDatabaseExecutor(filePath));
}
