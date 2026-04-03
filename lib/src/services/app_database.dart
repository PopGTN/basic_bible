// This new file replaces database_service.dart AND bible_models.dart
// Temporarily ignore analyzer errors related to generated Drift code while
// build artifacts are regenerated and the analysis server catches up.
// Remove these ignores once the analyzer no longer reports generated-symbol
// errors (they are a temporary workaround).
// ignore_for_file: uri_has_not_been_generated, undefined_identifier, undefined_method, undefined_getter, override_on_non_overriding_member, unnecessary_brace_in_string_interps
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';

// Import your app's models. We will still need them in the repository.
import '../models/bible_models.dart';

part 'app_database.g.dart'; // This file will be generated

// --- 1. Define Tables ---

@DataClassName('TranslationEntry')
class Translations extends Table {
  // Track where a translation came from so the app can distinguish
  // bundled assets, downloads, and future user-imported Bibles.
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get language => text()();
  TextColumn get description => text()();
  TextColumn get format => text()();
  TextColumn get sourceType => text()();
  TextColumn get sourceLocation => text().nullable()();
  BoolColumn get isLocal => boolean().withDefault(const Constant(false))();
  DateTimeColumn get importedAt => dateTime().withDefault(currentDateAndTime)();
  // Parser version stored when the translation was cached. Used to detect
  // stale caches when parser output format changes. Bump _currentParserVersion
  // in app_bible_repository.dart when making incompatible changes.
  IntColumn get parserVersion => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

// SIMPLIFIED: We removed `extending: BibleBook`.
// Drift will now generate a class called `BookEntry`.
@DataClassName('BookEntry')
class Books extends Table {
  TextColumn get id => text()(); // e.g., "kjv_GEN"
  TextColumn get translationId => text().references(Translations, #id)();
  TextColumn get name => text()();
  TextColumn get shortName => text()();
  IntColumn get bookNumber => integer()();
  // store bookType as an integer index; mapping to enum happens at the model layer
  IntColumn get bookType => integer()();
  // Preserve richer parser metadata at the book level while the rest of the
  // app is still catching up to a more structured rendering pipeline.
  TextColumn get tocLabels =>
      text().map(const BibleTocLabelListConverter()).nullable()();
  TextColumn get introductionBlocks =>
      text().map(const BibleDocumentBlockListConverter()).nullable()();

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
  TextColumn get blocks =>
      text().map(const BibleDocumentBlockListConverter()).nullable()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {bookId, number},
  ];
}

// This converter is still correct
class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();
  @override
  List<String> fromSql(String fromDb) =>
      fromDb.isEmpty ? [] : fromDb.split(';');
  @override
  String toSql(List<String> value) => value.join(';');
}

class JsonStringListConverter extends TypeConverter<List<String>, String> {
  const JsonStringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return const [];
    final decoded = jsonDecode(fromDb) as List<dynamic>;
    return decoded.map((item) => item.toString()).toList();
  }

  @override
  String toSql(List<String> value) {
    if (value.isEmpty) return '';
    return jsonEncode(value);
  }
}

class JsonListConverter<T> extends TypeConverter<List<T>, String> {
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;

  const JsonListConverter({required this.fromJson, required this.toJson});

  @override
  List<T> fromSql(String fromDb) {
    if (fromDb.isEmpty) return const [];
    final decoded = jsonDecode(fromDb) as List<dynamic>;
    return decoded
        .map((item) => fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  String toSql(List<T> value) {
    if (value.isEmpty) return '';
    return jsonEncode(value.map(toJson).toList());
  }
}

class BibleTocLabelListConverter extends JsonListConverter<BibleTocLabel> {
  const BibleTocLabelListConverter()
    : super(fromJson: BibleTocLabel.fromJson, toJson: _bibleTocLabelToJson);
}

class BibleDocumentBlockListConverter
    extends JsonListConverter<BibleDocumentBlock> {
  const BibleDocumentBlockListConverter()
    : super(
        fromJson: BibleDocumentBlock.fromJson,
        toJson: _bibleDocumentBlockToJson,
      );
}

class BibleVerseSpanListConverter extends JsonListConverter<BibleVerseSpan> {
  const BibleVerseSpanListConverter()
    : super(fromJson: BibleVerseSpan.fromJson, toJson: _bibleVerseSpanToJson);
}

class BibleFootnoteListConverter extends JsonListConverter<BibleFootnote> {
  const BibleFootnoteListConverter()
    : super(fromJson: BibleFootnote.fromJson, toJson: _bibleFootnoteToJson);
}

class BibleCrossReferenceListConverter
    extends JsonListConverter<BibleCrossReference> {
  const BibleCrossReferenceListConverter()
    : super(
        fromJson: BibleCrossReference.fromJson,
        toJson: _bibleCrossReferenceToJson,
      );
}

Map<String, dynamic> _bibleTocLabelToJson(BibleTocLabel value) =>
    value.toJson();
Map<String, dynamic> _bibleDocumentBlockToJson(BibleDocumentBlock value) =>
    value.toJson();
Map<String, dynamic> _bibleVerseSpanToJson(BibleVerseSpan value) =>
    value.toJson();
Map<String, dynamic> _bibleFootnoteToJson(BibleFootnote value) =>
    value.toJson();
Map<String, dynamic> _bibleCrossReferenceToJson(BibleCrossReference value) =>
    value.toJson();

@DataClassName('UserAnnotationEntry')
class UserAnnotations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()();
  TextColumn get primaryBookId => text()();
  IntColumn get primaryChapter => integer()();
  IntColumn get primaryVerse => integer()();
  TextColumn get primaryTranslationId => text()();
  TextColumn get primaryTranslationName => text()();
  TextColumn get noteText => text().nullable()();
  IntColumn get highlightColorValue => integer().nullable()();
  TextColumn get labels => text()
      .map(const JsonStringListConverter())
      .withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('AnnotationVerseEntry')
class AnnotationVerses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get annotationId => integer().references(UserAnnotations, #id)();
  IntColumn get sortOrder => integer()();
  TextColumn get bookId => text()();
  IntColumn get chapter => integer()();
  IntColumn get verse => integer()();
  TextColumn get translationId => text()();
  TextColumn get translationName => text()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {annotationId, sortOrder},
  ];
}

// SIMPLIFIED: We removed `extending: BibleVerse`.
// Drift will now generate a class called `VerseEntry`.
@DataClassName('VerseEntry')
class Verses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get chapterId =>
      integer().references(Chapters, #id)(); // Foreign key
  IntColumn get number => integer()();
  // Avoid naming collision with the `text()` column builder by using
  // `verseText` as the column name in the generated class.
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

// --- 2. Define Database Class ---

@DriftDatabase(
  tables: [
    Translations,
    Books,
    Chapters,
    Verses,
    UserAnnotations,
    AnnotationVerses,
  ],
)
class AppDatabase extends _$AppDatabase {
  // Use super-parameters to keep the constructor concise and satisfy the
  // `use_super_parameters` analyzer hint.
  AppDatabase(super.e);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 5) {
        await customStatement(
          'ALTER TABLE translations ADD COLUMN parser_version INTEGER DEFAULT 0',
        );
      }
      if (from < 6) {
        await m.createTable(userAnnotations);
        await m.createTable(annotationVerses);
      }
    },
    onCreate: (m) => m.createAll(),
  );

  // --- 3. Define Data Access Methods ---

  // This insert logic is now slightly different because
  // we are using the models from bible_models.dart as input.
  Future<void> insertBible(
    String translationId,
    List<BibleBook> bibleBooks,
  ) async {
    // Use a single transaction and perform sequential inserts. Mixing
    // `batch` with nested `transaction` calls led to race conditions where
    // rows weren't reliably committed, causing lookups (like getChapter)
    // to fail. This sequential approach is simpler and deterministic.
    await transaction(() async {
      // Replace the existing translation payload as one unit so callers
      // don't end up with mixed old/new rows if the same translation is
      // re-imported or re-parsed later.
      await (delete(verses)..where(
            (v) => v.chapterId.isInQuery(
              selectOnly(chapters)
                ..addColumns([chapters.id])
                ..where(
                  chapters.bookId.isInQuery(
                    selectOnly(books)
                      ..addColumns([books.id])
                      ..where(books.translationId.equals(translationId)),
                  ),
                ),
            ),
          ))
          .go();
      await (delete(chapters)..where(
            (c) => c.bookId.isInQuery(
              selectOnly(books)
                ..addColumns([books.id])
                ..where(books.translationId.equals(translationId)),
            ),
          ))
          .go();
      await (delete(
        books,
      )..where((b) => b.translationId.equals(translationId))).go();

      for (final book in bibleBooks) {
        // Always uppercase the book ID segment so lookups are consistent
        // regardless of whether the source used OSIS mixed-case IDs (Gen, Ps)
        // or the standard 3-letter uppercase codes (GEN, PSA).
        final bookId = '${translationId}_${book.id.toUpperCase()}';

        // Insert or replace the book to avoid UNIQUE constraint errors
        await into(books).insert(
          BooksCompanion.insert(
            id: bookId,
            translationId: translationId,
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
          final chapterId = await into(chapters).insert(
            ChaptersCompanion.insert(
              bookId: bookId,
              number: chapter.number,
              blocks: Value(chapter.blocks),
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

  Future<void> upsertTranslationMetadata({
    required BibleTranslation translation,
    String? sourceLocation,
    BibleSourceType? sourceTypeOverride,
  }) async {
    // Metadata is stored separately from parsed content so the app can later
    // build a local "library" view without reparsing the Bible files.
    await into(translations).insertOnConflictUpdate(
      TranslationsCompanion.insert(
        id: translation.id,
        name: translation.name,
        language: translation.language,
        description: translation.description,
        format: translation.format.name,
        sourceType: (sourceTypeOverride ?? translation.sourceType).name,
        sourceLocation: Value(sourceLocation),
        isLocal: Value(translation.isLocal),
        importedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<List<BibleTranslation>> getStoredTranslations() async {
    final rows = await (select(
      translations,
    )..orderBy([(t) => OrderingTerm.desc(t.importedAt)])).get();

    return rows
        .map(
          (row) => BibleTranslation(
            id: row.id,
            name: row.name,
            language: row.language,
            description: row.description,
            isLocal: row.isLocal,
            filePath:
                row.sourceType == BibleSourceType.asset.name ||
                    row.sourceType == BibleSourceType.import.name
                ? row.sourceLocation
                : null,
            format: BibleFormat.values.firstWhere(
              (format) => format.name == row.format,
              orElse: () => BibleFormat.auto,
            ),
            sourceType: BibleSourceType.values.firstWhere(
              (sourceType) => sourceType.name == row.sourceType,
              orElse: () => BibleSourceType.import,
            ),
            githubUrl: row.sourceType == BibleSourceType.download.name
                ? row.sourceLocation
                : null,
          ),
        )
        .toList();
  }

  /// Get translation metadata (including parser version) for cache validation.
  /// Returns `null` if translation is not in the database.
  Future<TranslationEntry?> getTranslationMeta(String translationId) async {
    return (select(
      translations,
    )..where((t) => t.id.equals(translationId))).getSingleOrNull();
  }

  /// Update the parser version for a cached translation.
  /// Called after successfully parsing and storing a translation.
  Future<void> updateTranslationParserVersion(
    String translationId,
    int versionNumber,
  ) async {
    await customStatement(
      'UPDATE translations SET parser_version = ? WHERE id = ?',
      [versionNumber, translationId],
    );
  }

  // This method now maps the generated classes (e.g., BookEntry)
  // back to your UI models (e.g., BibleBook).
  Future<List<BibleBook>> getBible(String translationId) async {
    final bookRows =
        await (select(books)
              ..where((b) => b.translationId.equals(translationId))
              ..orderBy([(b) => OrderingTerm(expression: b.bookNumber)]))
            .get();

    if (bookRows.isEmpty) return const [];

    final bookIds = bookRows.map((row) => row.id).toList();
    final chapterRows =
        await (select(chapters)
              ..where((c) => c.bookId.isIn(bookIds))
              ..orderBy([
                (c) => OrderingTerm(expression: c.bookId),
                (c) => OrderingTerm(expression: c.number),
              ]))
            .get();

    final chapterIds = chapterRows.map((row) => row.id).toList();
    final verseRows = chapterIds.isEmpty
        ? const <VerseEntry>[]
        : await (select(verses)
                ..where((v) => v.chapterId.isIn(chapterIds))
                ..orderBy([
                  (v) => OrderingTerm(expression: v.chapterId),
                  (v) => OrderingTerm(expression: v.number),
                ]))
              .get();

    final versesByChapterId = <int, List<BibleVerse>>{};
    for (final verseRow in verseRows) {
      versesByChapterId
          .putIfAbsent(verseRow.chapterId, () => <BibleVerse>[])
          .add(
            BibleVerse(
              number: verseRow.number,
              text: verseRow.verseText,
              notes: verseRow.notes,
              references: verseRow.references,
              spans: verseRow.spans ?? const [],
              footnotes: verseRow.footnotes ?? const [],
              crossReferences: verseRow.crossReferences ?? const [],
            ),
          );
    }

    final chaptersByBookId = <String, List<BibleChapter>>{};
    for (final chapterRow in chapterRows) {
      chaptersByBookId
          .putIfAbsent(chapterRow.bookId, () => <BibleChapter>[])
          .add(
            BibleChapter(
              number: chapterRow.number,
              verses: versesByChapterId[chapterRow.id] ?? const [],
              blocks: chapterRow.blocks ?? const [],
            ),
          );
    }

    return [
      for (final bookRow in bookRows)
        BibleBook(
          id: bookRow.id.split('_').last.toUpperCase(),
          name: bookRow.name,
          shortName: bookRow.shortName.toUpperCase(),
          bookNumber: bookRow.bookNumber,
          bookType: _bookTypeFromRow(bookRow.bookType),
          chapters: chaptersByBookId[bookRow.id] ?? const [],
          tocLabels: bookRow.tocLabels ?? const [],
          introductionBlocks: bookRow.introductionBlocks ?? const [],
        ),
    ];
  }

  /// Load books and chapter metadata (no verses) for quick shell rendering.
  /// Each chapter has empty verses list; verses are loaded on demand per chapter.
  Future<List<BibleBook>> getBooksShell(String translationId) async {
    final bookRows =
        await (select(books)
              ..where((b) => b.translationId.equals(translationId))
              ..orderBy([(b) => OrderingTerm(expression: b.bookNumber)]))
            .get();

    if (bookRows.isEmpty) return const [];

    final bookIds = bookRows.map((row) => row.id).toList();
    final chapterRows =
        await (select(chapters)
              ..where((c) => c.bookId.isIn(bookIds))
              ..orderBy([
                (c) => OrderingTerm(expression: c.bookId),
                (c) => OrderingTerm(expression: c.number),
              ]))
            .get();

    final chaptersByBookId = <String, List<BibleChapter>>{};
    for (final chapterRow in chapterRows) {
      chaptersByBookId
          .putIfAbsent(chapterRow.bookId, () => <BibleChapter>[])
          .add(
            BibleChapter(
              number: chapterRow.number,
              verses: const [], // Empty shell - verses loaded on demand
              blocks: chapterRow.blocks ?? const [],
            ),
          );
    }

    return [
      for (final bookRow in bookRows)
        BibleBook(
          id: bookRow.id.split('_').last.toUpperCase(),
          name: bookRow.name,
          shortName: bookRow.shortName.toUpperCase(),
          bookNumber: bookRow.bookNumber,
          bookType: _bookTypeFromRow(bookRow.bookType),
          chapters: chaptersByBookId[bookRow.id] ?? const [],
          tocLabels: bookRow.tocLabels ?? const [],
          introductionBlocks: bookRow.introductionBlocks ?? const [],
        ),
    ];
  }

  /// Retrieve a single chapter (with verses) for a translation/book/chapter.
  /// Returns `null` if not found.
  Future<BibleChapter?> getChapter(
    String translationId,
    String bookId,
    int chapterNumber,
  ) async {
    final compositeBookId = '${translationId}_${bookId}';
    final lowerCompositeBookId = '${translationId}_${bookId.toLowerCase()}';

    final bookRow =
        await (select(books)..where(
              (b) =>
                  b.id.equals(compositeBookId) |
                  b.id.equals(lowerCompositeBookId),
            ))
            .getSingleOrNull();
    if (bookRow == null) return null;

    final chapterRow =
        await (select(chapters)..where(
              (c) =>
                  c.bookId.equals(bookRow.id) & c.number.equals(chapterNumber),
            ))
            .getSingleOrNull();

    if (chapterRow == null) return null;

    final verseRows =
        await (select(verses)
              ..where((v) => v.chapterId.equals(chapterRow.id))
              ..orderBy([(t) => OrderingTerm(expression: t.number)]))
            .get();

    final mappedVerses = verseRows
        .map(
          (v) => BibleVerse(
            number: v.number,
            text: v.verseText,
            notes: v.notes,
            references: v.references,
            spans: v.spans ?? const [],
            footnotes: v.footnotes ?? const [],
            crossReferences: v.crossReferences ?? const [],
          ),
        )
        .toList();

    return BibleChapter(
      number: chapterRow.number,
      verses: mappedVerses,
      blocks: chapterRow.blocks ?? const [],
    );
  }

  // Helper to accept either an int index or an enum value (depends on
  // whether code generation mapped the column) and return a BibleBookType.
  BibleBookType _bookTypeFromRow(dynamic value) {
    if (value is int) {
      return BibleBookType.values[value.clamp(
        0,
        BibleBookType.values.length - 1,
      )];
    }
    if (value is BibleBookType) return value;
    return BibleBookType.oldTestament;
  }

  Future<bool> isBibleCached(String translationId) async {
    // Use a regular select to ensure columns are included in the generated SQL.
    final rows =
        await (select(books)
              ..where((b) => b.translationId.equals(translationId))
              ..limit(1))
            .get();

    return rows.isNotEmpty;
  }

  Future<void> deleteBibleContent(String translationId) async {
    await transaction(() async {
      await _deleteBibleRows(translationId);
    });
  }

  Future<void> deleteBible(String translationId) async {
    await transaction(() async {
      await _deleteBibleRows(translationId);
      await (delete(
        translations,
      )..where((t) => t.id.equals(translationId))).go();
    });
  }

  Future<void> _deleteBibleRows(String translationId) async {
    await (delete(verses)..where(
          (v) => v.chapterId.isInQuery(
            selectOnly(chapters)
              ..addColumns([chapters.id])
              ..where(
                chapters.bookId.isInQuery(
                  selectOnly(books)
                    ..addColumns([books.id])
                    ..where(books.translationId.equals(translationId)),
                ),
              ),
          ),
        ))
        .go();
    await (delete(chapters)..where(
          (c) => c.bookId.isInQuery(
            selectOnly(books)
              ..addColumns([books.id])
              ..where(books.translationId.equals(translationId)),
          ),
        ))
        .go();
    await (delete(
      books,
    )..where((b) => b.translationId.equals(translationId))).go();
  }

  Future<void> deleteAllBibles() async {
    await delete(verses).go();
    await delete(chapters).go();
    await delete(books).go();
    await delete(translations).go();
  }

  Stream<List<UserAnnotation>> watchAllUserAnnotations() {
    final query = select(userAnnotations)
      ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);

    return query.watch().asyncMap(_mapUserAnnotations);
  }

  Future<List<UserAnnotation>> getAllUserAnnotations() async {
    final rows = await (select(
      userAnnotations,
    )..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])).get();
    return _mapUserAnnotations(rows);
  }

  Future<UserAnnotation?> getUserAnnotationById(int id) async {
    final row = await (select(
      userAnnotations,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    final mapped = await _mapUserAnnotations([row]);
    return mapped.isEmpty ? null : mapped.first;
  }

  Future<int> saveUserAnnotation(UserAnnotation annotation) async {
    return transaction(() async {
      final now = DateTime.now();
      final entry = UserAnnotationsCompanion(
        type: Value(annotation.type.name),
        primaryBookId: Value(annotation.primaryVerse.bookId),
        primaryChapter: Value(annotation.primaryVerse.chapter),
        primaryVerse: Value(annotation.primaryVerse.verse),
        primaryTranslationId: Value(annotation.primaryVerse.translationId),
        primaryTranslationName: Value(annotation.primaryVerse.translationName),
        noteText: Value(
          annotation.hasNoteText ? annotation.noteText!.trim() : null,
        ),
        highlightColorValue: Value(annotation.highlightColorValue),
        labels: Value(annotation.labels),
        updatedAt: Value(now),
        createdAt: annotation.id == null ? Value(now) : const Value.absent(),
      );

      final annotationId = annotation.id == null
          ? await into(userAnnotations).insert(entry)
          : await () async {
              await (update(
                userAnnotations,
              )..where((t) => t.id.equals(annotation.id!))).write(entry);
              return annotation.id!;
            }();

      await (delete(
        annotationVerses,
      )..where((t) => t.annotationId.equals(annotationId))).go();

      if (annotation.linkedVerses.isNotEmpty) {
        await batch((batch) {
          batch.insertAll(annotationVerses, [
            for (var i = 0; i < annotation.linkedVerses.length; i++)
              AnnotationVersesCompanion.insert(
                annotationId: annotationId,
                sortOrder: i,
                bookId: annotation.linkedVerses[i].bookId,
                chapter: annotation.linkedVerses[i].chapter,
                verse: annotation.linkedVerses[i].verse,
                translationId: annotation.linkedVerses[i].translationId,
                translationName: annotation.linkedVerses[i].translationName,
              ),
          ]);
        });
      }

      return annotationId;
    });
  }

  Future<void> deleteUserAnnotation(int annotationId) async {
    await transaction(() async {
      await (delete(
        annotationVerses,
      )..where((t) => t.annotationId.equals(annotationId))).go();
      await (delete(
        userAnnotations,
      )..where((t) => t.id.equals(annotationId))).go();
    });
  }

  Future<List<UserAnnotation>> _mapUserAnnotations(
    List<UserAnnotationEntry> rows,
  ) async {
    if (rows.isEmpty) return const [];
    final ids = rows.map((row) => row.id).toList();
    final verseRows =
        await (select(annotationVerses)
              ..where((t) => t.annotationId.isIn(ids))
              ..orderBy([
                (t) => OrderingTerm(expression: t.annotationId),
                (t) => OrderingTerm(expression: t.sortOrder),
              ]))
            .get();

    final linkedByAnnotationId = <int, List<AnnotationVerseLink>>{};
    for (final row in verseRows) {
      linkedByAnnotationId
          .putIfAbsent(row.annotationId, () => [])
          .add(
            AnnotationVerseLink(
              id: row.id,
              bookId: row.bookId,
              chapter: row.chapter,
              verse: row.verse,
              translationId: row.translationId,
              translationName: row.translationName,
              sortOrder: row.sortOrder,
            ),
          );
    }

    return [
      for (final row in rows)
        UserAnnotation(
          id: row.id,
          type: UserAnnotationType.values.firstWhere(
            (value) => value.name == row.type,
            orElse: () => UserAnnotationType.note,
          ),
          primaryVerse: AnnotationVerseLink(
            bookId: row.primaryBookId,
            chapter: row.primaryChapter,
            verse: row.primaryVerse,
            translationId: row.primaryTranslationId,
            translationName: row.primaryTranslationName,
          ),
          noteText: row.noteText,
          highlightColorValue: row.highlightColorValue,
          labels: row.labels,
          linkedVerses: linkedByAnnotationId[row.id] ?? const [],
          createdAt: row.createdAt,
          updatedAt: row.updatedAt,
        ),
    ];
  }
}

// --- 4. Database Connection & Provider ---

// FIXED: This now *correctly* uses the factories you set up in main.dart
// for all platforms.
QueryExecutor _connect() {
  return LazyDatabase(() async {
    if (kIsWeb) {
      // Web persistence is still a follow-up task. Keep behavior explicit
      // instead of pretending the desktop/mobile file-backed path exists here.
      return NativeDatabase.memory();
    }

    final dir = await getApplicationSupportDirectory();
    final dbDir = Directory(p.join(dir.path, 'database'));
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }

    final file = File(p.join(dbDir.path, 'basic_bible.sqlite'));
    // Use a background isolate so opening the file-backed database does not
    // block startup more than necessary on desktop/mobile platforms.
    return NativeDatabase.createInBackground(file);
  });
}

// This provider is unchanged and correct.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(_connect());
  ref.onDispose(() => db.close());
  return db;
});
