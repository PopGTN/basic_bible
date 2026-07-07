// On-disk migration tests.
//
// These build real SQLite files that replicate the historical schemas
// (reconstructed from git history: v4 pre-parser_version, v6 pre-registry),
// then open them with today's AppDatabase and assert that user data —
// especially annotations — survives the upgrade to the current version.
//
// If you bump [AppDatabase.schemaVersion], add a fixture for the previous
// version here so the new migration path is covered.

import 'dart:io';

import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/services/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as raw;

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('app_db_migration_test');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  String fixturePath(String name) => p.join(tempDir.path, name);

  /// Legacy `translations` table as it existed at v6 (v4 is identical minus
  /// the parser_version column, which the v5 migration adds).
  void createLegacyTranslationsTable(
    raw.Database db, {
    required bool withParserVersion,
  }) {
    db.execute('''
      CREATE TABLE translations (
        id TEXT NOT NULL PRIMARY KEY,
        name TEXT NOT NULL,
        language TEXT NOT NULL,
        description TEXT NOT NULL,
        format TEXT NOT NULL,
        source_type TEXT NOT NULL,
        source_location TEXT,
        is_local INTEGER NOT NULL DEFAULT 0,
        imported_at INTEGER NOT NULL
        ${withParserVersion ? ', parser_version INTEGER DEFAULT 0' : ''}
      )
    ''');
  }

  /// Legacy shared Bible content tables (dropped by the v7 migration).
  void createLegacyContentTables(raw.Database db) {
    db.execute('''
      CREATE TABLE books (
        id TEXT NOT NULL PRIMARY KEY,
        translation_id TEXT NOT NULL REFERENCES translations(id),
        name TEXT NOT NULL,
        short_name TEXT NOT NULL,
        book_number INTEGER NOT NULL,
        book_type INTEGER NOT NULL,
        toc_labels TEXT,
        introduction_blocks TEXT
      )
    ''');
    db.execute('''
      CREATE TABLE chapters (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book_id TEXT NOT NULL REFERENCES books(id),
        number INTEGER NOT NULL,
        blocks TEXT
      )
    ''');
    db.execute('''
      CREATE TABLE verses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        chapter_id INTEGER NOT NULL REFERENCES chapters(id),
        number INTEGER NOT NULL,
        verse_text TEXT NOT NULL,
        notes TEXT,
        "references" TEXT,
        spans TEXT,
        footnotes TEXT,
        cross_references TEXT,
        UNIQUE(chapter_id, number)
      )
    ''');
    db.execute(
      "INSERT INTO books VALUES ('kjv_GEN', 'kjv', 'Genesis', 'GEN', 1, 0, NULL, NULL)",
    );
    db.execute("INSERT INTO chapters (book_id, number) VALUES ('kjv_GEN', 1)");
    db.execute(
      "INSERT INTO verses (chapter_id, number, verse_text) "
      "VALUES (1, 1, 'In the beginning...')",
    );
  }

  /// user_annotations + annotation_verses exactly as the v6 migration
  /// created them.
  void createV6AnnotationTables(raw.Database db) {
    db.execute('''
      CREATE TABLE user_annotations (
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
    db.execute('''
      CREATE TABLE annotation_verses (
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

  Future<Set<String>> tableNames(AppDatabase db) async {
    final rows = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table'",
        )
        .get();
    return rows.map((row) => row.read<String>('name')).toSet();
  }

  test('v6 database upgrades to current schema without losing user data',
      () async {
    final path = fixturePath('app_v6.sqlite');
    final fixture = raw.sqlite3.open(path);
    createLegacyTranslationsTable(fixture, withParserVersion: true);
    createLegacyContentTables(fixture);
    createV6AnnotationTables(fixture);
    fixture.execute(
      "INSERT INTO translations "
      "(id, name, language, description, format, source_type, "
      " source_location, is_local, imported_at, parser_version) VALUES "
      "('web', 'World English Bible', 'en', 'Public domain', 'usfx', "
      " 'download', 'https://example.com/web.zip', 1, 1700000000, 3)",
    );
    fixture.execute(
      "INSERT INTO user_annotations "
      "(type, primary_book_id, primary_chapter, primary_verse, "
      " primary_translation_id, primary_translation_name, note_text, "
      " highlight_color_value, labels, created_at, updated_at) VALUES "
      "('note', 'JHN', 3, 16, 'kjv', 'King James Version', "
      " 'God so loved the world', NULL, '[\"favorites\"]', "
      " 1700000000, 1700000000)",
    );
    fixture.execute(
      "INSERT INTO annotation_verses "
      "(annotation_id, sort_order, book_id, chapter, verse, "
      " translation_id, translation_name) VALUES "
      "(1, 0, 'JHN', 3, 16, 'kjv', 'King James Version'), "
      "(1, 1, 'JHN', 3, 17, 'kjv', 'King James Version')",
    );
    fixture.execute('PRAGMA user_version = 6');
    fixture.dispose();

    final db = AppDatabase(NativeDatabase(File(path)));
    addTearDown(db.close);

    // Translation metadata was copied into the new registry, with
    // parser_version reset to 0 so content is re-parsed on next load.
    final translations = await db.getInstalledTranslations();
    expect(translations, hasLength(1));
    expect(translations.single.id, 'web');
    expect(translations.single.name, 'World English Bible');
    expect(translations.single.githubUrl, 'https://example.com/web.zip');
    final entry = await db.getInstalledTranslation('web');
    expect(entry!.parserVersion, 0);

    // Annotations survived the upgrade completely.
    final annotations = await db.getAllUserAnnotations();
    expect(annotations, hasLength(1));
    final note = annotations.single;
    expect(note.noteText, 'God so loved the world');
    expect(note.labels, ['favorites']);
    expect(note.primaryVerse.bookId, 'JHN');
    expect(note.primaryVerse.chapter, 3);
    expect(note.primaryVerse.verse, 16);
    expect(note.linkedVerses, hasLength(2));
    expect(note.linkedVerses.last.verse, 17);

    // Legacy shared content tables are gone; the new registry exists.
    final tables = await tableNames(db);
    expect(tables, contains('installed_translations'));
    expect(tables, isNot(contains('translations')));
    expect(tables, isNot(contains('books')));
    expect(tables, isNot(contains('chapters')));
    expect(tables, isNot(contains('verses')));

    final version = await db
        .customSelect('PRAGMA user_version')
        .getSingle();
    expect(version.read<int>('user_version'), db.schemaVersion);
  });

  test('v4 database (no parser_version, no annotations) upgrades cleanly',
      () async {
    final path = fixturePath('app_v4.sqlite');
    final fixture = raw.sqlite3.open(path);
    createLegacyTranslationsTable(fixture, withParserVersion: false);
    createLegacyContentTables(fixture);
    fixture.execute(
      "INSERT INTO translations "
      "(id, name, language, description, format, source_type, "
      " source_location, is_local, imported_at) VALUES "
      "('kjv', 'King James Version', 'en', 'Bundled', 'usfx', "
      " 'asset', 'assets/bible/eng-kjv2006_usfx.xml', 1, 1700000000)",
    );
    fixture.execute('PRAGMA user_version = 4');
    fixture.dispose();

    final db = AppDatabase(NativeDatabase(File(path)));
    addTearDown(db.close);

    final translations = await db.getInstalledTranslations();
    expect(translations, hasLength(1));
    expect(translations.single.id, 'kjv');
    expect(
      translations.single.filePath,
      'assets/bible/eng-kjv2006_usfx.xml',
    );

    // Annotation tables were created by the v6 step and are usable.
    final tables = await tableNames(db);
    expect(tables, contains('user_annotations'));
    expect(tables, contains('annotation_verses'));
    final annotations = await db.getAllUserAnnotations();
    expect(annotations, isEmpty);

    expect(tables, isNot(contains('translations')));
    expect(tables, isNot(contains('verses')));
  });

  /// installed_translations exactly as the v7 migration created it.
  void createV7RegistryTable(raw.Database db) {
    db.execute('''
      CREATE TABLE installed_translations (
        id TEXT NOT NULL PRIMARY KEY,
        name TEXT NOT NULL,
        language TEXT NOT NULL,
        description TEXT NOT NULL,
        format TEXT NOT NULL,
        source_type TEXT NOT NULL,
        source_location TEXT,
        is_local INTEGER NOT NULL DEFAULT 0,
        imported_at INTEGER NOT NULL,
        parser_version INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  test('v7 database gains backfilled unique uuids and tombstone column',
      () async {
    final path = fixturePath('app_v7.sqlite');
    final fixture = raw.sqlite3.open(path);
    createV7RegistryTable(fixture);
    createV6AnnotationTables(fixture);
    fixture.execute(
      "INSERT INTO user_annotations "
      "(type, primary_book_id, primary_chapter, primary_verse, "
      " primary_translation_id, primary_translation_name, note_text, "
      " highlight_color_value, labels, created_at, updated_at) VALUES "
      "('note', 'JHN', 3, 16, 'kjv', 'King James Version', "
      " 'God so loved the world', NULL, '', 1700000000, 1700000000), "
      "('highlight', 'GEN', 1, 1, 'kjv', 'King James Version', NULL, "
      " 4294901760, '', 1700000100, 1700000100)",
    );
    fixture.execute('PRAGMA user_version = 7');
    fixture.dispose();

    final db = AppDatabase(NativeDatabase(File(path)));
    addTearDown(db.close);

    final annotations = await db.getAllUserAnnotations();
    expect(annotations, hasLength(2));

    // Every existing row was backfilled with a distinct non-null uuid and no
    // tombstone, without touching note content.
    final uuids = annotations.map((a) => a.uuid).toSet();
    expect(uuids, isNot(contains(null)));
    expect(uuids, hasLength(2));
    expect(annotations.every((a) => a.deletedAt == null), isTrue);
    expect(
      annotations.map((a) => a.noteText).toSet(),
      containsAll(<String?>['God so loved the world', null]),
    );

    // uuid uniqueness is enforced at the SQL level.
    final indexes = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index' "
          "AND tbl_name = 'user_annotations'",
        )
        .get();
    expect(
      indexes.map((r) => r.read<String>('name')),
      contains('idx_user_annotations_uuid'),
    );

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), db.schemaVersion);
  });

  test('soft delete hides the annotation but keeps a syncable tombstone',
      () async {
    final path = fixturePath('app_soft_delete.sqlite');
    final db = AppDatabase(NativeDatabase(File(path)));
    addTearDown(db.close);

    final now = DateTime.now();
    const verse = AnnotationVerseLink(
      bookId: 'JHN',
      chapter: 3,
      verse: 16,
      translationId: 'kjv',
      translationName: 'King James Version',
    );
    final keepId = await db.saveUserAnnotation(
      UserAnnotation(
        type: UserAnnotationType.note,
        primaryVerse: verse,
        noteText: 'keep me',
        createdAt: now,
        updatedAt: now,
      ),
    );
    final deleteId = await db.saveUserAnnotation(
      UserAnnotation(
        type: UserAnnotationType.note,
        primaryVerse: verse,
        noteText: 'delete me',
        createdAt: now,
        updatedAt: now,
      ),
    );

    await db.deleteUserAnnotation(deleteId);

    // UI queries only see the surviving note, untouched.
    final visible = await db.getAllUserAnnotations();
    expect(visible, hasLength(1));
    expect(visible.single.id, keepId);
    expect(visible.single.noteText, 'keep me');

    // Sync queries still see the tombstone with its uuid intact.
    final all = await db.getAllUserAnnotationsIncludingDeleted();
    expect(all, hasLength(2));
    final tombstone = all.singleWhere((a) => a.id == deleteId);
    expect(tombstone.deletedAt, isNotNull);
    expect(tombstone.uuid, isNotNull);
  });

  test('upsertAnnotationFromSync preserves timestamps and matches by uuid',
      () async {
    final path = fixturePath('app_sync_upsert.sqlite');
    final db = AppDatabase(NativeDatabase(File(path)));
    addTearDown(db.close);

    const verse = AnnotationVerseLink(
      bookId: 'PSA',
      chapter: 23,
      verse: 1,
      translationId: 'kjv',
      translationName: 'King James Version',
    );
    final created = DateTime.fromMillisecondsSinceEpoch(1700000000 * 1000);
    final updated = DateTime.fromMillisecondsSinceEpoch(1700000500 * 1000);

    await db.upsertAnnotationFromSync(
      UserAnnotation(
        uuid: 'remote-uuid-1',
        type: UserAnnotationType.note,
        primaryVerse: verse,
        noteText: 'from another device',
        createdAt: created,
        updatedAt: updated,
      ),
    );

    final inserted = (await db.getAllUserAnnotations()).single;
    expect(inserted.uuid, 'remote-uuid-1');
    expect(inserted.noteText, 'from another device');
    // Timestamps come through verbatim — re-stamping them would make applied
    // remote changes ping-pong between devices forever.
    expect(inserted.updatedAt, updated);
    expect(inserted.createdAt, created);

    // Same uuid again → update in place, not a duplicate row.
    await db.upsertAnnotationFromSync(
      UserAnnotation(
        uuid: 'remote-uuid-1',
        type: UserAnnotationType.note,
        primaryVerse: verse,
        noteText: 'edited remotely',
        createdAt: created,
        updatedAt: updated.add(const Duration(seconds: 5)),
      ),
    );
    final afterUpdate = await db.getAllUserAnnotations();
    expect(afterUpdate, hasLength(1));
    expect(afterUpdate.single.id, inserted.id);
    expect(afterUpdate.single.noteText, 'edited remotely');
  });

  test('reopening an already-migrated database is a no-op', () async {
    final path = fixturePath('app_reopen.sqlite');

    final first = AppDatabase(NativeDatabase(File(path)));
    await first.upsertInstalledTranslation(
      translation: const BibleTranslation(
        id: 'web',
        name: 'World English Bible',
        language: 'en',
        description: 'Public domain',
        isLocal: true,
        format: BibleFormat.usfx,
        sourceType: BibleSourceType.download,
      ),
      sourceLocation: 'https://example.com/web.zip',
      parserVersion: 5,
    );
    await first.close();

    final second = AppDatabase(NativeDatabase(File(path)));
    addTearDown(second.close);
    final translations = await second.getInstalledTranslations();
    expect(translations, hasLength(1));
    final entry = await second.getInstalledTranslation(translations.single.id);
    expect(entry!.parserVersion, 5);
  });
}
