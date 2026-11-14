import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';

// Matches the translation exporter: building/reading SQLite files requires
// dart:io + native sqlite, which the browser build doesn't have. The tiles
// are disabled on web; these are compile-time placeholders only.

Future<bool> writeNotesBackupFile({
  required List<UserAnnotation> notes,
  required String fileName,
}) {
  throw UnsupportedError('Notes export is not supported in the browser.');
}

Future<List<UserAnnotation>?> readNotesBackupFile() {
  throw UnsupportedError('Notes import is not supported in the browser.');
}
