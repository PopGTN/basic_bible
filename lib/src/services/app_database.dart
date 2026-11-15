// ignore_for_file: uri_has_not_been_generated, undefined_identifier, undefined_method, undefined_getter, override_on_non_overriding_member, unnecessary_brace_in_string_interps, undefined_class, argument_type_not_assignable, return_of_invalid_type
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';
import 'package:uuid/uuid.dart';

import '../models/bible_models.dart';
import 'app_database_executor.dart';

part 'app_database.g.dart';

/// Per-note metadata needed to plan a sync without loading full notes.
class SyncIndexEntry {
  const SyncIndexEntry({required this.updatedAt, required this.isDeleted});

  final DateTime updatedAt;
  final bool isDeleted;
}

class AnnotationStorageSummary {
  const AnnotationStorageSummary({
    required this.totalNotes,
    required this.activeNotes,
    required this.deletedNotes,
    required this.databaseBytes,
  });

  final int totalNotes;
  final int activeNotes;
  final int deletedNotes;
  final int databaseBytes;

  bool get hasDeletedNotes => deletedNotes > 0;
}

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
@TableIndex(name: 'idx_user_annotations_uuid', columns: {#uuid}, unique: true)
class UserAnnotations extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Globally stable identity used by sync/export merging. Nullable in the
  /// schema only to keep the v8 ALTER TABLE migration simple; application
  /// code always populates it on insert/backfill.
  TextColumn get uuid => text().nullable()();
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

  /// Soft-delete tombstone. Deleted notes keep their row (invisible to the
  /// UI) so other devices/imports see a deterministic deletion instead of a
  /// silently missing note.
  DateTimeColumn get deletedAt => dateTime().nullable()();
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
  int get schemaVersion => 8;

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
      if (from < 8) {
        // v8: stable sync identity + soft-delete tombstones.
        await customStatement(
          'ALTER TABLE user_annotations ADD COLUMN uuid TEXT',
        );
        await customStatement(
          'ALTER TABLE user_annotations ADD COLUMN deleted_at INTEGER',
        );
        const uuidGen = Uuid();
        final rows = await customSelect(
          'SELECT id FROM user_annotations WHERE uuid IS NULL',
        ).get();
        for (final row in rows) {
          await customStatement(
            'UPDATE user_annotations SET uuid = ? WHERE id = ?',
            [uuidGen.v4(), row.read<int>('id')],
          );
        }
        await customStatement(
          'CREATE UNIQUE INDEX IF NOT EXISTS idx_user_annotations_uuid '
          'ON user_annotations (uuid)',
        );
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

  /// Single-row lookup that returns a mapped [BibleTranslation] or null.
  /// Prefer this over [getInstalledTranslations] when only one translation is needed.
  Future<BibleTranslation?> getInstalledTranslationModel(String id) async {
    final entry = await getInstalledTranslation(id);
    return entry != null ? _entryToTranslation(entry) : null;
  }

  /// Returns only the IDs of all installed translations.
  /// Use this instead of [getInstalledTranslations] when full metadata is not needed.
  Future<Set<String>> getInstalledTranslationIds() async {
    final rows = await (selectOnly(
      installedTranslations,
    )..addColumns([installedTranslations.id])).get();
    return rows.map((r) => r.read(installedTranslations.id)!).toSet();
  }

  Future<void> upsertInstalledTranslation({
    required BibleTranslation translation,
    String? sourceLocation,
    BibleSourceType? sourceTypeOverride,
    int? parserVersion,
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
        parserVersion: parserVersion != null
            ? Value(parserVersion)
            : const Value.absent(),
      ),
    );
  }

  Future<void> deleteInstalledTranslation(String id) async {
    await (delete(installedTranslations)..where((t) => t.id.equals(id))).go();
  }

  Future<void> deleteAllInstalledTranslations() async {
    await delete(installedTranslations).go();
  }

  Future<AnnotationStorageSummary> getAnnotationStorageSummary() async {
    final row = await customSelect('''
      SELECT
        COUNT(*) AS total_notes,
        SUM(CASE WHEN deleted_at IS NULL THEN 1 ELSE 0 END) AS active_notes,
        SUM(CASE WHEN deleted_at IS NOT NULL THEN 1 ELSE 0 END) AS deleted_notes
      FROM user_annotations
    ''').getSingle();
    final pageSizeRow = await customSelect('PRAGMA page_size').getSingle();
    final pageCountRow = await customSelect('PRAGMA page_count').getSingle();

    final pageSize = pageSizeRow.read<int?>('page_size') ?? 0;
    final pageCount = pageCountRow.read<int?>('page_count') ?? 0;

    return AnnotationStorageSummary(
      totalNotes: row.read<int?>('total_notes') ?? 0,
      activeNotes: row.read<int?>('active_notes') ?? 0,
      deletedNotes: row.read<int?>('deleted_notes') ?? 0,
      databaseBytes: pageSize * pageCount,
    );
  }

  Future<int> purgeDeletedAnnotations({
    Duration olderThan = const Duration(days: 30),
  }) async {
    final cutoff = DateTime.now().subtract(olderThan);
    final staleIds =
        await (selectOnly(userAnnotations)
              ..addColumns([userAnnotations.id])
              ..where(
                userAnnotations.deletedAt.isNotNull() &
                    userAnnotations.deletedAt.isSmallerThanValue(cutoff),
              ))
            .map((row) => row.read(userAnnotations.id)!)
            .get();

    if (staleIds.isEmpty) return 0;

    await transaction(() async {
      await (delete(
        annotationVerses,
      )..where((t) => t.annotationId.isIn(staleIds))).go();
      await (delete(userAnnotations)..where((t) => t.id.isIn(staleIds))).go();
    });

    return staleIds.length;
  }

  /// Minimum number of purged tombstones before a VACUUM is worth it.
  static const vacuumThreshold = 50;

  Future<int> runLocalRetentionCleanup({
    Duration olderThan = const Duration(days: 30),
  }) async {
    final removed = await purgeDeletedAnnotations(olderThan: olderThan);
    // VACUUM rewrites the whole database file. Freed pages are reused by
    // SQLite anyway, so only pay that I/O when a meaningful amount was freed.
    if (removed >= vacuumThreshold) {
      await customStatement('VACUUM');
    }
    return removed;
  }

  Future<void> deleteAllUserAnnotations() async {
    await transaction(() async {
      await delete(annotationVerses).go();
      await delete(userAnnotations).go();
    });
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
    final sourceType = BibleSourceType.values.firstWhere(
      (s) => s.name == row.sourceType,
      orElse: () => BibleSourceType.import,
    );
    return BibleTranslation(
      id: row.id,
      name: row.name,
      language: row.language,
      // No languageName column in the DB schema; leave empty so that
      // _mergeStoredTranslation falls through to the catalog/built-in value.
      languageName: '',
      description: row.description,
      isLocal: row.isLocal,
      filePath: switch (sourceType) {
        BibleSourceType.asset || BibleSourceType.import => row.sourceLocation,
        BibleSourceType.download || BibleSourceType.session => null,
      },
      format: BibleFormat.values.firstWhere(
        (f) => f.name == row.format,
        orElse: () => BibleFormat.auto,
      ),
      sourceType: sourceType,
      githubUrl: switch (sourceType) {
        BibleSourceType.download ||
        BibleSourceType.session => row.sourceLocation,
        BibleSourceType.asset || BibleSourceType.import => null,
      },
    );
  }

  // ===========================================================================
  // User annotations
  // ===========================================================================

  // O(1) type resolution — avoids firstWhere scan on every mapped row.
  static final _annotationTypeByName = {
    for (final t in UserAnnotationType.values) t.name: t,
  };

  JoinedSelectStatement<HasResultSet, dynamic> _annotationJoinQuery({
    bool includeDeleted = false,
  }) {
    final query = select(userAnnotations).join([
      leftOuterJoin(
        annotationVerses,
        annotationVerses.annotationId.equalsExp(userAnnotations.id),
      ),
    ]);
    if (!includeDeleted) {
      query.where(userAnnotations.deletedAt.isNull());
    }
    return query;
  }

  List<UserAnnotation> _mapJoinRows(List<TypedResult> rows) {
    // LinkedHashMap preserves insertion order, which matches the query's
    // ORDER BY updatedAt DESC — so the returned list is already sorted.
    final annotationEntries = <int, UserAnnotationEntry>{};
    final versesByAnnotation = <int, List<AnnotationVerseLink>>{};

    for (final row in rows) {
      final a = row.readTable(userAnnotations);
      annotationEntries.putIfAbsent(a.id, () => a);
      final v = row.readTableOrNull(annotationVerses);
      if (v != null) {
        versesByAnnotation
            .putIfAbsent(v.annotationId, () => [])
            .add(
              AnnotationVerseLink(
                id: v.id,
                bookId: v.bookId,
                chapter: v.chapter,
                verse: v.verse,
                translationId: v.translationId,
                translationName: v.translationName,
                sortOrder: v.sortOrder,
              ),
            );
      }
    }

    return [
      for (final a in annotationEntries.values)
        UserAnnotation(
          id: a.id,
          uuid: a.uuid,
          type: _annotationTypeByName[a.type] ?? UserAnnotationType.note,
          primaryVerse: AnnotationVerseLink(
            bookId: a.primaryBookId,
            chapter: a.primaryChapter,
            verse: a.primaryVerse,
            translationId: a.primaryTranslationId,
            translationName: a.primaryTranslationName,
          ),
          noteText: a.noteText,
          highlightColorValue: a.highlightColorValue,
          labels: a.labels,
          linkedVerses: versesByAnnotation[a.id] ?? const [],
          createdAt: a.createdAt,
          updatedAt: a.updatedAt,
          deletedAt: a.deletedAt,
        ),
    ];
  }

  Stream<List<UserAnnotation>> watchAllUserAnnotations() {
    final query = _annotationJoinQuery()
      ..orderBy([
        OrderingTerm.desc(userAnnotations.updatedAt),
        OrderingTerm.desc(userAnnotations.id),
        OrderingTerm(expression: annotationVerses.sortOrder),
      ]);
    return query.watch().map(_mapJoinRows);
  }

  Future<List<UserAnnotation>> getAllUserAnnotations() async {
    final query = _annotationJoinQuery()
      ..orderBy([
        OrderingTerm.desc(userAnnotations.updatedAt),
        OrderingTerm.desc(userAnnotations.id),
        OrderingTerm(expression: annotationVerses.sortOrder),
      ]);
    return _mapJoinRows(await query.get());
  }

  Future<UserAnnotation?> getUserAnnotationById(int id) async {
    final query = _annotationJoinQuery()..where(userAnnotations.id.equals(id));
    final rows = await query.get();
    final mapped = _mapJoinRows(rows);
    return mapped.isEmpty ? null : mapped.first;
  }

  Future<int> saveUserAnnotation(UserAnnotation annotation) async {
    return transaction(() async {
      final now = DateTime.now();
      final entry = UserAnnotationsCompanion(
        // New notes get a fresh sync uuid; updates never touch the column so
        // the existing uuid is preserved.
        uuid: annotation.id == null
            ? Value(annotation.uuid ?? const Uuid().v4())
            : const Value.absent(),
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

  /// Soft delete: keeps the row as a tombstone (hidden from all UI queries)
  /// so sync/import can propagate the deletion deterministically. Child
  /// verse links are hard-deleted; they are not synced independently.
  Future<void> deleteUserAnnotation(int annotationId) async {
    await transaction(() async {
      final now = DateTime.now();
      await (delete(
        annotationVerses,
      )..where((t) => t.annotationId.equals(annotationId))).go();
      await (update(
        userAnnotations,
      )..where((t) => t.id.equals(annotationId))).write(
        UserAnnotationsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
      );
    });
  }

  // ===========================================================================
  // Sync/export support
  // ===========================================================================

  /// All annotations including tombstones — for sync and export, never UI.
  Future<List<UserAnnotation>> getAllUserAnnotationsIncludingDeleted() async {
    final query = _annotationJoinQuery(includeDeleted: true)
      ..orderBy([
        OrderingTerm.desc(userAnnotations.updatedAt),
        OrderingTerm.desc(userAnnotations.id),
        OrderingTerm(expression: annotationVerses.sortOrder),
      ]);
    return _mapJoinRows(await query.get());
  }

  /// Write path used by Drive sync and file import: upserts by [uuid], never
  /// by local int id (which differs across devices), and preserves the given
  /// createdAt/updatedAt/deletedAt verbatim. Re-stamping updatedAt here would
  /// make every applied remote change look newer than its source and ping-pong
  /// between devices forever.
  ///
  /// Returns false when skipped because the local copy was edited after the
  /// sync plan was computed (newer local `updatedAt` always wins).
  Future<bool> upsertAnnotationFromSync(UserAnnotation annotation) {
    return transaction(() => _upsertAnnotationFromSyncInTxn(annotation));
  }

  /// Applies many synced/imported notes in a single transaction, so the
  /// annotation watch streams (and the reader UI) refresh once instead of
  /// once per note. Returns how many were actually written.
  Future<int> applySyncedAnnotations(List<UserAnnotation> annotations) async {
    if (annotations.isEmpty) return 0;
    return transaction(() async {
      var written = 0;
      for (final annotation in annotations) {
        if (await _upsertAnnotationFromSyncInTxn(annotation)) written++;
      }
      return written;
    });
  }

  /// Lightweight sync-planning index: one narrow query on the parent
  /// table, no verse-link join, no model mapping.
  Future<Map<String, SyncIndexEntry>> getSyncIndex() async {
    final rows =
        await (selectOnly(userAnnotations)..addColumns([
              userAnnotations.uuid,
              userAnnotations.updatedAt,
              userAnnotations.deletedAt,
            ]))
            .get();
    return {
      for (final row in rows)
        if (row.read(userAnnotations.uuid) case final uuid?)
          uuid: SyncIndexEntry(
            updatedAt: row.read(userAnnotations.updatedAt)!,
            isDeleted: row.read(userAnnotations.deletedAt) != null,
          ),
    };
  }

  /// Full notes (tombstones included) for the given uuids only.
  Future<List<UserAnnotation>> getUserAnnotationsByUuids(
    Iterable<String> uuids,
  ) async {
    final list = uuids.toList();
    if (list.isEmpty) return const [];
    final result = <UserAnnotation>[];
    // Stay well under SQLite's bound-parameter limit.
    const chunk = 500;
    for (var i = 0; i < list.length; i += chunk) {
      final slice = list.sublist(
        i,
        i + chunk > list.length ? list.length : i + chunk,
      );
      final query = _annotationJoinQuery(includeDeleted: true)
        ..where(userAnnotations.uuid.isIn(slice))
        ..orderBy([OrderingTerm(expression: annotationVerses.sortOrder)]);
      result.addAll(_mapJoinRows(await query.get()));
    }
    return result;
  }

  Future<bool> _upsertAnnotationFromSyncInTxn(UserAnnotation annotation) async {
    final uuid = annotation.uuid;
    if (uuid == null) {
      throw ArgumentError('upsertAnnotationFromSync requires a uuid');
    }
    final existing = await (select(
      userAnnotations,
    )..where((t) => t.uuid.equals(uuid))).getSingleOrNull();
    if (existing != null && existing.updatedAt.isAfter(annotation.updatedAt)) {
      return false;
    }

    final entry = UserAnnotationsCompanion(
      uuid: Value(uuid),
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
      createdAt: Value(annotation.createdAt),
      updatedAt: Value(annotation.updatedAt),
      deletedAt: Value(annotation.deletedAt),
    );

    final annotationId = existing == null
        ? await into(userAnnotations).insert(entry)
        : await () async {
            await (update(
              userAnnotations,
            )..where((t) => t.id.equals(existing.id))).write(entry);
            return existing.id;
          }();

    await (delete(
      annotationVerses,
    )..where((t) => t.annotationId.equals(annotationId))).go();

    // Tombstones carry no verse links.
    if (annotation.deletedAt == null && annotation.linkedVerses.isNotEmpty) {
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
    return true;
  }
}

// =============================================================================
// 4. Connection & provider
// =============================================================================

QueryExecutor _connectAppDatabase() {
  return openAppDatabaseExecutor();
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(_connectAppDatabase());
  ref.onDispose(() => db.close());
  return db;
});
