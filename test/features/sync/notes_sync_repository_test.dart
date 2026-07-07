import 'dart:io';

import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';
import 'package:basic_bible/src/features/sync/data/google_auth_service.dart';
import 'package:basic_bible/src/features/sync/data/google_drive_notes_api.dart';
import 'package:basic_bible/src/features/sync/data/notes_sync_repository.dart';
import 'package:basic_bible/src/features/sync/models/note_sync_codec.dart';
import 'package:basic_bible/src/services/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

class _FakeAuth implements GoogleAuthService {
  @override
  bool get isSupported => true;
  @override
  bool get isConfigured => true;
  @override
  Future<GoogleAccount?> restoreExistingSignIn() async =>
      const GoogleAccount(email: 'test@example.com');
  @override
  Future<GoogleAccount> signIn() async =>
      const GoogleAccount(email: 'test@example.com');
  @override
  Future<String> getAccessToken() async => 'fake-token';
  @override
  Future<void> signOut() async {}
}

class _FakeDriveFile {
  _FakeDriveFile(this.content, this.updatedAtMillis);
  String content;
  int? updatedAtMillis;
}

/// In-memory stand-in for the Drive appDataFolder, tracking call counts so
/// tests can assert the "one listing call when nothing changed" optimization.
class _FakeDrive implements DriveNotesApi {
  final files = <String, _FakeDriveFile>{}; // fileId → file
  int listCalls = 0;
  int downloadCalls = 0;
  int uploadCalls = 0;

  String _fileIdFor(String uuid) => 'file-$uuid';

  void seedNote(UserAnnotation note, {bool stampUpdatedAt = true}) {
    files[_fileIdFor(note.uuid!)] = _FakeDriveFile(
      annotationToSyncJsonString(note),
      stampUpdatedAt ? note.updatedAt.toUtc().millisecondsSinceEpoch : null,
    );
  }

  UserAnnotation noteFor(String uuid) =>
      annotationFromSyncJsonString(files[_fileIdFor(uuid)]!.content);

  @override
  Future<List<DriveNoteFile>> listNoteFiles(String accessToken) async {
    listCalls++;
    return [
      for (final entry in files.entries)
        DriveNoteFile(
          fileId: entry.key,
          uuid: entry.key.substring('file-'.length),
          updatedAtMillis: entry.value.updatedAtMillis,
        ),
    ];
  }

  @override
  Future<String> downloadNoteContent(String accessToken, String fileId) async {
    downloadCalls++;
    return files[fileId]!.content;
  }

  @override
  Future<void> uploadNote({
    required String accessToken,
    required String uuid,
    required String jsonContent,
    required int updatedAtMillis,
    String? existingFileId,
  }) async {
    uploadCalls++;
    if (existingFileId != null) {
      expect(files.containsKey(existingFileId), isTrue,
          reason: 'PATCH of a file that does not exist');
    }
    files[existingFileId ?? _fileIdFor(uuid)] = _FakeDriveFile(
      jsonContent,
      updatedAtMillis,
    );
  }
}

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('notes_sync_test');
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
      createdAt: now,
      updatedAt: now,
    );
  }

  NotesSyncRepository repo(AppDatabase db, _FakeDrive drive) {
    return NotesSyncRepository(db: db, auth: _FakeAuth(), api: drive);
  }

  test('first sync pushes local notes; second sync is listing-only', () async {
    final db = openDb('a.sqlite');
    await db.saveUserAnnotation(newNote('one'));
    await db.saveUserAnnotation(newNote('two'));
    final drive = _FakeDrive();

    final first = await repo(db, drive).syncOnce();
    expect(first.pushed, 2);
    expect(first.applied, 0);
    expect(drive.files, hasLength(2));

    final second = await repo(db, drive).syncOnce();
    expect(second.changedAnything, isFalse);
    // The whole no-op pass cost one listing call — no downloads, no uploads.
    expect(drive.listCalls, 2);
    expect(drive.downloadCalls, 0);
    expect(drive.uploadCalls, 2); // only from the first pass
  });

  test('two devices converge: create on A appears on B, edit flows back',
      () async {
    final deviceA = openDb('deviceA.sqlite');
    final deviceB = openDb('deviceB.sqlite');
    final drive = _FakeDrive();

    await deviceA.saveUserAnnotation(newNote('written on A'));
    await repo(deviceA, drive).syncOnce();

    final b1 = await repo(deviceB, drive).syncOnce();
    expect(b1.applied, 1);
    final onB = (await deviceB.getAllUserAnnotations()).single;
    expect(onB.noteText, 'written on A');

    // Edit on B (clearly newer than the original save).
    await deviceB.upsertAnnotationFromSync(
      onB.copyWith(
        noteText: 'edited on B',
        updatedAt: onB.updatedAt.add(const Duration(minutes: 1)),
      ),
    );
    await repo(deviceB, drive).syncOnce();

    final a2 = await repo(deviceA, drive).syncOnce();
    expect(a2.applied, 1);
    final onA = (await deviceA.getAllUserAnnotations()).single;
    expect(onA.noteText, 'edited on B');
  });

  test('delete on one device propagates as tombstone, not clobber', () async {
    final deviceA = openDb('delA.sqlite');
    final deviceB = openDb('delB.sqlite');
    final drive = _FakeDrive();

    await deviceA.saveUserAnnotation(newNote('keep'));
    await deviceA.saveUserAnnotation(newNote('remove'));
    await repo(deviceA, drive).syncOnce();
    await repo(deviceB, drive).syncOnce();
    expect(await deviceB.getAllUserAnnotations(), hasLength(2));

    // Delete on A via a clearly newer tombstone (test clock control).
    final toDelete = (await deviceA.getAllUserAnnotations())
        .singleWhere((n) => n.noteText == 'remove');
    await deviceA.upsertAnnotationFromSync(
      toDelete.copyWith(
        updatedAt: toDelete.updatedAt.add(const Duration(minutes: 1)),
        deletedAt: toDelete.updatedAt.add(const Duration(minutes: 1)),
      ),
    );
    await repo(deviceA, drive).syncOnce();

    await repo(deviceB, drive).syncOnce();
    final remaining = await deviceB.getAllUserAnnotations();
    expect(remaining, hasLength(1));
    expect(remaining.single.noteText, 'keep');
    // The tombstone lives on remotely for any device that syncs later.
    expect(drive.files, hasLength(2));
  });

  test('concurrent edits to different notes never touch each other',
      () async {
    final deviceA = openDb('parA.sqlite');
    final deviceB = openDb('parB.sqlite');
    final drive = _FakeDrive();

    await deviceA.saveUserAnnotation(newNote('note-1'));
    await deviceA.saveUserAnnotation(newNote('note-2'));
    await repo(deviceA, drive).syncOnce();
    await repo(deviceB, drive).syncOnce();

    // A edits note-1 while B edits note-2, both offline.
    final a1 = (await deviceA.getAllUserAnnotations())
        .singleWhere((n) => n.noteText == 'note-1');
    await deviceA.upsertAnnotationFromSync(
      a1.copyWith(
        noteText: 'note-1 edited on A',
        updatedAt: a1.updatedAt.add(const Duration(minutes: 1)),
      ),
    );
    final b2 = (await deviceB.getAllUserAnnotations())
        .singleWhere((n) => n.noteText == 'note-2');
    await deviceB.upsertAnnotationFromSync(
      b2.copyWith(
        noteText: 'note-2 edited on B',
        updatedAt: b2.updatedAt.add(const Duration(minutes: 1)),
      ),
    );

    await repo(deviceA, drive).syncOnce();
    await repo(deviceB, drive).syncOnce();
    await repo(deviceA, drive).syncOnce();

    final finalA = await deviceA.getAllUserAnnotations();
    final finalB = await deviceB.getAllUserAnnotations();
    expect(
      finalA.map((n) => n.noteText).toSet(),
      {'note-1 edited on A', 'note-2 edited on B'},
    );
    expect(
      finalB.map((n) => n.noteText).toSet(),
      {'note-1 edited on A', 'note-2 edited on B'},
    );
  });

  test('remote files without updatedAt metadata are downloaded and merged',
      () async {
    final db = openDb('legacy.sqlite');
    final drive = _FakeDrive();

    // A file written by a hypothetical older app version: no appProperties.
    final legacy = newNote('legacy remote').copyWith(uuid: 'legacy-uuid');
    drive.seedNote(legacy, stampUpdatedAt: false);

    final summary = await repo(db, drive).syncOnce();
    expect(summary.applied, 1);
    expect(drive.downloadCalls, 1);
    expect(
      (await db.getAllUserAnnotations()).single.noteText,
      'legacy remote',
    );
  });
}
