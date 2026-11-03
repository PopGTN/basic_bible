import 'dart:io';

import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';
import 'package:basic_bible/src/features/sync/models/note_sync_codec.dart';
import 'package:sqlite3/sqlite3.dart';

/// dart:io half of the notes backup format, kept free of file-picker/share
/// dependencies so it can be unit-tested directly.
///
/// A backup is a standalone SQLite file with two tables:
///   meta(key, value)      — schema version, generator, export timestamp
///   notes(uuid, payload)  — one row per note, payload = sync JSON

void buildNotesBackupDatabase(String path, List<UserAnnotation> notes) {
  final file = File(path);
  if (file.existsSync()) file.deleteSync();

  final db = sqlite3.open(path);
  try {
    db.execute('''
      CREATE TABLE meta (
        key TEXT NOT NULL PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
    db.execute('''
      CREATE TABLE notes (
        uuid TEXT NOT NULL PRIMARY KEY,
        payload TEXT NOT NULL
      )
    ''');
    final meta = db.prepare('INSERT INTO meta (key, value) VALUES (?, ?)');
    try {
      meta
        ..execute(['schema', '$noteSyncSchemaVersion'])
        ..execute(['generator', 'basic_bible'])
        ..execute(['exported_at', DateTime.now().toUtc().toIso8601String()]);
    } finally {
      meta.dispose();
    }

    final insert = db.prepare(
      'INSERT INTO notes (uuid, payload) VALUES (?, ?)',
    );
    try {
      for (final note in notes) {
        insert.execute([note.uuid, annotationToSyncJsonString(note)]);
      }
    } finally {
      insert.dispose();
    }
  } finally {
    db.dispose();
  }
}

List<UserAnnotation> parseNotesBackupDatabase(String path) {
  final Database db;
  try {
    db = sqlite3.open(path, mode: OpenMode.readOnly);
  } catch (_) {
    throw Exception('This file is not a SQLite database.');
  }
  try {
    final tables = db
        .select("SELECT name FROM sqlite_master WHERE type = 'table'")
        .map((row) => row['name'] as String)
        .toSet();
    if (!tables.contains('notes') || !tables.contains('meta')) {
      throw Exception(
        'This SQLite file is not a Bible notes backup exported by this app.',
      );
    }

    final schemaRow = db.select("SELECT value FROM meta WHERE key = 'schema'");
    final schema = schemaRow.isEmpty
        ? null
        : int.tryParse(schemaRow.first['value'] as String);
    if (schema == null || schema > noteSyncSchemaVersion) {
      throw Exception(
        'This backup was created by a newer version of the app. '
        'Update the app and try again.',
      );
    }

    return db
        .select('SELECT payload FROM notes')
        .map((row) => annotationFromSyncJsonString(row['payload'] as String))
        .toList();
  } finally {
    db.dispose();
  }
}
