// ignore_for_file: uri_has_not_been_generated, undefined_identifier, undefined_method, undefined_getter, override_on_non_overriding_member, unnecessary_brace_in_string_interps, undefined_class, argument_type_not_assignable, return_of_invalid_type
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';

import '../models/bible_models.dart';

part 'app_database.g.dart';

// =============================================================================
// 1. Type converters — shared with translation_database.dart
// =============================================================================

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
    : super(fromJson: BibleTocLabel.fromJson, toJson: _tocLabelToJson);
}

class BibleDocumentBlockListConverter
    extends JsonListConverter<BibleDocumentBlock> {
  const BibleDocumentBlockListConverter()
    : super(
        fromJson: BibleDocumentBlock.fromJson,
        toJson: _documentBlockToJson,
      );
}

class BibleVerseSpanListConverter extends JsonListConverter<BibleVerseSpan> {
  const BibleVerseSpanListConverter()
    : super(fromJson: BibleVerseSpan.fromJson, toJson: _verseSpanToJson);
}

class BibleFootnoteListConverter extends JsonListConverter<BibleFootnote> {
  const BibleFootnoteListConverter()
    : super(fromJson: BibleFootnote.fromJson, toJson: _footnoteToJson);
}

class BibleCrossReferenceListConverter
    extends JsonListConverter<BibleCrossReference> {
  const BibleCrossReferenceListConverter()
    : super(
        fromJson: BibleCrossReference.fromJson,
        toJson: _crossReferenceToJson,
      );
}

Map<String, dynamic> _tocLabelToJson(BibleTocLabel v) => v.toJson();
Map<String, dynamic> _documentBlockToJson(BibleDocumentBlock v) => v.toJson();
Map<String, dynamic> _verseSpanToJson(BibleVerseSpan v) => v.toJson();
Map<String, dynamic> _footnoteToJson(BibleFootnote v) => v.toJson();
Map<String, dynamic> _crossReferenceToJson(BibleCrossReference v) => v.toJson();

// =============================================================================
// 2. Tables
// =============================================================================

/// Registry of every translation the user has installed (parsed from XML or
/// downloaded as a SQLite file). Content lives in per-translation SQLite files
/// managed by [TranslationDatabaseManager]; this table holds only metadata.
@DataClassName('InstalledTranslationEntry')
class InstalledTranslations extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get language => text()();
  TextColumn get description => text()();
  TextColumn get format => text()();
  TextColumn get sourceType => text()();

  /// Original source: asset bundle path, download URL, or imported file path.
  /// Used to re-parse when [parserVersion] is bumped.
  TextColumn get sourceLocation => text().nullable()();
  BoolColumn get isLocal => boolean().withDefault(const Constant(false))();
  DateTimeColumn get importedAt => dateTime().withDefault(currentDateAndTime)();

  /// Recorded parser version at last parse. Compare against
  /// [AppBibleRepository._currentParserVersion] to detect stale caches.
  IntColumn get parserVersion => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

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

// =============================================================================
// 3. Database class
// =============================================================================

@DriftDatabase(
  tables: [InstalledTranslations, UserAnnotations, AnnotationVerses],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 5) {
        await customStatement(
          'ALTER TABLE translations ADD COLUMN parser_version INTEGER DEFAULT 0',
        );
      }
      if (from < 6) {
        // user_annotations and annotation_verses were added in v6.
        // They may already exist if this is a fresh install path.
        await customStatement('''
          CREATE TABLE IF NOT EXISTS user_annotations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL,
            primary_book_id TEXT NOT NULL,
            primary_chapter INTEGER NOT NULL,
            primary_verse INTEGER NOT NULL,
            primary_translation_id TEXT NOT NULL,
            primary_translation_name TEXT NOT NULL,
            note_text TEXT,
            highlight_color_value INTEGER,
            labels TEXT NOT NULL DEFAULT '',
            created_at INTEGER NOT NULL DEFAULT (strftime('%s','now')),
            updated_at INTEGER NOT NULL DEFAULT (strftime('%s','now'))
          )
        ''');
        await customStatement('''
          CREATE TABLE IF NOT EXISTS annotation_verses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            annotation_id INTEGER NOT NULL REFERENCES user_annotations(id),
            sort_order INTEGER NOT NULL,
            book_id TEXT NOT NULL,
            chapter INTEGER NOT NULL,
            verse INTEGER NOT NULL,
            translation_id TEXT NOT NULL,
            translation_name TEXT NOT NULL,
            UNIQUE(annotation_id, sort_order)
          )
        ''');
      }
      if (from < 7) {
        // Create the new translation registry table.
        await m.createTable(installedTranslations);

        // Copy existing translation metadata. Set parser_version = 0 so each
        // translation is re-parsed into its own SQLite file on next load.
        await customStatement('''
          INSERT OR IGNORE INTO installed_translations
            (id, name, language, description, format, source_type,
             source_location, is_local, imported_at, parser_version)
          SELECT
            id, name, language, description, format, source_type,
            source_location, is_local, imported_at, 0
          FROM translations
        ''');

        // Drop legacy shared Bible content tables once registry metadata has
        // been copied into the new v7 layout.
        await customStatement('DROP TABLE IF EXISTS verses');
        await customStatement('DROP TABLE IF EXISTS chapters');
        await customStatement('DROP TABLE IF EXISTS books');
        await customStatement('DROP TABLE IF EXISTS translations');
      }
    },
    onCreate: (m) => m.createAll(),
  );

  // ===========================================================================
  // Translation registry
  // ===========================================================================

  Future<List<BibleTranslation>> getInstalledTranslations() async {
    final rows = await (select(
      installedTranslations,
    )..orderBy([(t) => OrderingTerm.desc(t.importedAt)])).get();
    return rows.map(_entryToTranslation).toList();
  }

  Future<InstalledTranslationEntry?> getInstalledTranslation(String id) async {
    return (select(
      installedTranslations,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> upsertInstalledTranslation({
    required BibleTranslation translation,
    String? sourceLocation,
    BibleSourceType? sourceTypeOverride,
  }) async {
    await into(installedTranslations).insertOnConflictUpdate(
      InstalledTranslationsCompanion.insert(
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

  Future<void> deleteInstalledTranslation(String id) async {
    await (delete(installedTranslations)..where((t) => t.id.equals(id))).go();
  }

  Future<void> deleteAllInstalledTranslations() async {
    await delete(installedTranslations).go();
  }

  Future<void> updateInstalledTranslationParserVersion(
    String id,
    int version,
  ) async {
    await (update(installedTranslations)..where((t) => t.id.equals(id))).write(
      InstalledTranslationsCompanion(parserVersion: Value(version)),
    );
  }

  BibleTranslation _entryToTranslation(InstalledTranslationEntry row) {
    return BibleTranslation(
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
        (f) => f.name == row.format,
        orElse: () => BibleFormat.auto,
      ),
      sourceType: BibleSourceType.values.firstWhere(
        (s) => s.name == row.sourceType,
        orElse: () => BibleSourceType.import,
      ),
      githubUrl: row.sourceType == BibleSourceType.download.name
          ? row.sourceLocation
          : null,
    );
  }

  // ===========================================================================
  // User annotations
  // ===========================================================================

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
        await batch((b) {
          b.insertAll(annotationVerses, [
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
    final ids = rows.map((r) => r.id).toList();
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
            (v) => v.name == row.type,
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

// =============================================================================
// 4. Connection & provider
// =============================================================================

QueryExecutor _connectAppDatabase() {
  return LazyDatabase(() async {
    if (kIsWeb) return NativeDatabase.memory();

    final dir = await getApplicationSupportDirectory();
    final dbDir = Directory(p.join(dir.path, 'database'));
    if (!await dbDir.exists()) await dbDir.create(recursive: true);

    final file = File(p.join(dbDir.path, 'app.sqlite'));
    return NativeDatabase.createInBackground(
      file,
      setup: (db) {
        db.execute('PRAGMA journal_mode=WAL;');
        db.execute('PRAGMA synchronous=NORMAL;');
        db.execute('PRAGMA temp_store=MEMORY;');
      },
    );
  });
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(_connectAppDatabase());
  ref.onDispose(() => db.close());
  return db;
});
