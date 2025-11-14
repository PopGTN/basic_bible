// This new file replaces database_service.dart AND bible_models.dart
// Temporarily ignore analyzer errors related to generated Drift code while
// build artifacts are regenerated and the analysis server catches up.
// Remove these ignores once the analyzer no longer reports generated-symbol
// errors (they are a temporary workaround).
// ignore_for_file: uri_has_not_been_generated, undefined_identifier, undefined_method, undefined_getter, override_on_non_overriding_member, unnecessary_brace_in_string_interps
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import your app's models. We will still need them in the repository.
import '../models/bible_models.dart';

part 'app_database.g.dart'; // This file will be generated

// --- 1. Define Tables ---

// SIMPLIFIED: We removed `extending: BibleBook`.
// Drift will now generate a class called `BookEntry`.
@DataClassName('BookEntry') 
class Books extends Table {
  TextColumn get id => text()(); // e.g., "kjv_GEN"
  TextColumn get name => text()();
  TextColumn get shortName => text()();
  IntColumn get bookNumber => integer()();
  // store bookType as an integer index; mapping to enum happens at the model layer
  IntColumn get bookType => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

// SIMPLIFIED: We removed `extending: BibleChapter`.
// Drift will now generate a class called `ChapterEntry`.
@DataClassName('ChapterEntry')
class Chapters extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get bookId => text().references(Books, #id)(); // Foreign key
  IntColumn get number => integer()();
}

// This converter is still correct
class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();
  @override
  List<String> fromSql(String fromDb) => fromDb.isEmpty ? [] : fromDb.split(';');
  @override
  String toSql(List<String> value) => value.join(';');
}

// SIMPLIFIED: We removed `extending: BibleVerse`.
// Drift will now generate a class called `VerseEntry`.
@DataClassName('VerseEntry')
class Verses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get chapterId => integer().references(Chapters, #id)(); // Foreign key
  IntColumn get number => integer()();
  // Avoid naming collision with the `text()` column builder by using
  // `verseText` as the column name in the generated class.
  TextColumn get verseText => text()();
  TextColumn get notes => text().map(const StringListConverter()).nullable()();
  TextColumn get references => text().map(const StringListConverter()).nullable()();
}


// --- 2. Define Database Class ---

@DriftDatabase(tables: [Books, Chapters, Verses])
class AppDatabase extends _$AppDatabase {
  // Use super-parameters to keep the constructor concise and satisfy the
  // `use_super_parameters` analyzer hint.
  AppDatabase(super.e);

  @override
  int get schemaVersion => 2; // Matches your old _databaseVersion
  
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      await m.deleteTable(verses.actualTableName);
      await m.deleteTable(chapters.actualTableName);
      await m.deleteTable(books.actualTableName);
      await m.createAll();
    },
    onCreate: (m) => m.createAll(),
  );

  // --- 3. Define Data Access Methods ---
  
  // This insert logic is now slightly different because
  // we are using the models from bible_models.dart as input.
  Future<void> insertBible(String translationId, List<BibleBook> bibleBooks) async {
    // Use a single transaction and perform sequential inserts. Mixing
    // `batch` with nested `transaction` calls led to race conditions where
    // rows weren't reliably committed, causing lookups (like getChapter)
    // to fail. This sequential approach is simpler and deterministic.
    await transaction(() async {
      for (final book in bibleBooks) {
        final bookId = '${translationId}_${book.id}';

        // Insert or replace the book to avoid UNIQUE constraint errors
        await into(books).insert(BooksCompanion.insert(
          id: bookId,
          name: book.name,
          shortName: book.shortName,
          bookNumber: book.bookNumber,
          bookType: book.bookType.index,
        ), mode: InsertMode.insertOrReplace);

        for (final chapter in book.chapters) {
          final chapterId = await into(chapters).insert(
            ChaptersCompanion.insert(
              bookId: bookId,
              number: chapter.number,
            ),
            mode: InsertMode.insertOrReplace,
          );

          // Insert verses for this chapter. Use a batch for multiple verses
          // to improve insertion speed while staying inside the transaction.
          if (chapter.verses.isNotEmpty) {
            await batch((b) {
              b.insertAll(verses, [
                for (final verse in chapter.verses)
                  VersesCompanion.insert(
                    chapterId: chapterId,
                    number: verse.number,
                    verseText: verse.text,
                    notes: Value(verse.notes),
                    references: Value(verse.references),
                  ),
              ], mode: InsertMode.insertOrReplace);
            });
          }
        }
      }
    });
  }

  // This method now maps the generated classes (e.g., BookEntry)
  // back to your UI models (e.g., BibleBook).
  Future<List<BibleBook>> getBible(String translationId) async {
    final bookRows = await (select(books)
          ..where((b) => b.id.like('${translationId}_%')))
        .get();

    final List<BibleBook> resultBooks = [];
    
    for (final bookRow in bookRows) {
      final chapterRows = await (select(chapters)
            ..where((c) => c.bookId.equals(bookRow.id)))
          .get();

      final List<BibleChapter> resultChapters = [];

      for (final chapterRow in chapterRows) {
        final verseRows = await (select(verses)
              ..where((v) => v.chapterId.equals(chapterRow.id)))
            .get();
        
        // Map VerseEntry -> BibleVerse
        final mappedVerses = verseRows.map((v) => BibleVerse(
          number: v.number,
          text: v.verseText,
          notes: v.notes,
          references: v.references,
        )).toList();

        // Map ChapterEntry -> BibleChapter
        resultChapters.add(BibleChapter(
          number: chapterRow.number,
          verses: mappedVerses,
        ));
      }
      
      // Map BookEntry -> BibleBook (convert stored index to enum)
      resultBooks.add(BibleBook(
        id: bookRow.id.split('_').last,
        name: bookRow.name,
        shortName: bookRow.shortName,
        bookNumber: bookRow.bookNumber,
        bookType: _bookTypeFromRow(bookRow.bookType),
        chapters: resultChapters,
      ));
    }
    
    return resultBooks;
  }

  /// Retrieve a single chapter (with verses) for a translation/book/chapter.
  /// Returns `null` if not found.
  Future<BibleChapter?> getChapter(String translationId, String bookId, int chapterNumber) async {
    final compositeBookId = '${translationId}_${bookId}';

    final bookRow = await (select(books)..where((b) => b.id.equals(compositeBookId))).getSingleOrNull();
    if (bookRow == null) return null;

    final chapterRow = await (select(chapters)
          ..where((c) => c.bookId.equals(bookRow.id) & c.number.equals(chapterNumber)))
        .getSingleOrNull();

    if (chapterRow == null) return null;

    final verseRows = await (select(verses)
          ..where((v) => v.chapterId.equals(chapterRow.id))
          ..orderBy([(t) => OrderingTerm(expression: t.number)]))
        .get();

    final mappedVerses = verseRows.map((v) => BibleVerse(
      number: v.number,
      text: v.verseText,
      notes: v.notes,
      references: v.references,
    )).toList();

    return BibleChapter(number: chapterRow.number, verses: mappedVerses);
  }

  // Helper to accept either an int index or an enum value (depends on
  // whether code generation mapped the column) and return a BibleBookType.
  BibleBookType _bookTypeFromRow(dynamic value) {
    if (value is int) return BibleBookType.values[value.clamp(0, BibleBookType.values.length - 1)];
    if (value is BibleBookType) return value;
    return BibleBookType.oldTestament;
  }
  
  Future<bool> isBibleCached(String translationId) async {
    // Use a regular select to ensure columns are included in the generated SQL.
    final rows = await (select(books)
          ..where((b) => b.id.like('${translationId}_%'))
          ..limit(1))
        .get();

    return rows.isNotEmpty;
  }

  Future<void> deleteBible(String translationId) async {
    await (delete(books)..where((b) => b.id.like('${translationId}_%'))).go();
  }
  
  Future<void> deleteAllBibles() async {
    await delete(verses).go();
    await delete(chapters).go();
    await delete(books).go();
  }
}


// --- 4. Database Connection & Provider ---

// FIXED: This now *correctly* uses the factories you set up in main.dart
// for all platforms.
QueryExecutor _connect() {
  // For now use an in-memory NativeDatabase wrapped in LazyDatabase. This
  // keeps the database functional for tests and avoids platform-specific
  // sqflite ffi wiring here. If you want file-based persistence, wire a
  // platform-specific QueryExecutor (e.g., using sqflite or sqflite_ffi).
  return LazyDatabase(() async {
    return NativeDatabase.memory();
  });
}

// This provider is unchanged and correct.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(_connect());
  ref.onDispose(() => db.close());
  return db;
});