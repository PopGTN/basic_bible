import 'dart:io';

import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';
import 'package:basic_bible/src/features/sync/data/note_merge_engine.dart';
import 'package:basic_bible/src/features/sync/data/notes_backup_sqlite.dart';
import 'package:basic_bible/src/services/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('notes_backup_test');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  AppDatabase openDb(String name) {
    final db = AppDatabase(NativeDatabase(File(p.join(tempDir.path, name))));
    addTearDown(db.close);
    return db;
  }

  const verse = AnnotationVerseLink(
    bookId: 'JHN',
    chapter: 3,
    verse: 16,
    translationId: 'kjv',
    translationName: 'King James Version',
  );

  UserAnnotation newNote(String text) {
    final now = DateTime.now();
    return UserAnnotation(
      type: UserAnnotationType.note,
      primaryVerse: verse,
      noteText: text,
      labels: const ['study'],
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> importInto(AppDatabase db, String backupPath) async {
    final imported = parseNotesBackupDatabase(backupPath);
    final local = await db.getAllUserAnnotationsIncludingDeleted();
    final plan = mergeNotes(local: local, remote: imported);
    for (final note in plan.toApplyLocally) {
      await db.upsertAnnotationFromSync(note);
    }
  }

  test('backup round-trips into a fresh database (device move)', () async {
    final source = openDb('source.sqlite');
    await source.saveUserAnnotation(newNote('first'));
    await source.saveUserAnnotation(newNote('second'));

    final backupPath = p.join(tempDir.path, 'backup.sqlite');
    buildNotesBackupDatabase(
      backupPath,
      await source.getAllUserAnnotations(),
    );

    final target = openDb('target.sqlite');
    await importInto(target, backupPath);

    final restored = await target.getAllUserAnnotations();
    expect(restored, hasLength(2));
    expect(
      restored.map((n) => n.noteText).toSet(),
      {'first', 'second'},
    );
    // Identity travelled with the notes.
    final sourceUuids =
        (await source.getAllUserAnnotations()).map((n) => n.uuid).toSet();
    expect(restored.map((n) => n.uuid).toSet(), sourceUuids);

    // Importing the same backup again changes nothing.
    await importInto(target, backupPath);
    expect(await target.getAllUserAnnotations(), hasLength(2));
  });

  test('importing an old backup never regresses newer local edits', () async {
    final db = openDb('app.sqlite');
    final id = await db.saveUserAnnotation(newNote('original'));

    final backupPath = p.join(tempDir.path, 'old_backup.sqlite');
    buildNotesBackupDatabase(backupPath, await db.getAllUserAnnotations());

    // Edit after the backup was taken (updatedAt has 1s resolution in the
    // DB, so push the edit clearly past the backup timestamp).
    final saved = (await db.getAllUserAnnotations()).single;
    await db.upsertAnnotationFromSync(
      saved.copyWith(
        noteText: 'edited after backup',
        updatedAt: saved.updatedAt.add(const Duration(minutes: 1)),
      ),
    );

    await importInto(db, backupPath);

    final after = (await db.getAllUserAnnotations()).single;
    expect(after.id, id);
    expect(after.noteText, 'edited after backup');
  });

  test('a note deleted after the backup stays deleted on re-import', () async {
    final db = openDb('deleted.sqlite');
    final id = await db.saveUserAnnotation(newNote('to be deleted'));

    final backupPath = p.join(tempDir.path, 'pre_delete.sqlite');
    buildNotesBackupDatabase(backupPath, await db.getAllUserAnnotations());

    // The tombstone's updatedAt must clearly exceed the backup's (1s column
    // resolution), so stamp it via the sync path instead of sleeping.
    final saved = (await db.getAllUserAnnotations()).single;
    await db.upsertAnnotationFromSync(
      saved.copyWith(
        updatedAt: saved.updatedAt.add(const Duration(minutes: 1)),
        deletedAt: saved.updatedAt.add(const Duration(minutes: 1)),
      ),
    );
    expect(await db.getAllUserAnnotations(), isEmpty);

    await importInto(db, backupPath);

    // The older backup copy must not resurrect the deleted note.
    expect(await db.getAllUserAnnotations(), isEmpty);
    final all = await db.getAllUserAnnotationsIncludingDeleted();
    expect(all.single.id, id);
    expect(all.single.isDeleted, isTrue);
  });

  test('rejects files that are not notes backups', () async {
    final junkPath = p.join(tempDir.path, 'junk.sqlite');
    File(junkPath).writeAsStringSync('not a database');
    expect(() => parseNotesBackupDatabase(junkPath), throwsException);

    final otherDb = openDb('other.sqlite'); // valid SQLite, wrong tables
    await otherDb.customStatement('SELECT 1');
    expect(
      () => parseNotesBackupDatabase(p.join(tempDir.path, 'other.sqlite')),
      throwsException,
    );
  });
}
