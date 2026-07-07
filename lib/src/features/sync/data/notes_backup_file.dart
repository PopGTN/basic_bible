import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';

import 'notes_backup_file_stub.dart'
    if (dart.library.io) 'notes_backup_file_native.dart'
    if (dart.library.js_interop) 'notes_backup_file_web.dart'
    as impl;

/// Builds a standalone notes-backup SQLite file and hands it to the user
/// (share sheet on mobile, save dialog on desktop). Returns false when the
/// user cancelled the save dialog.
Future<bool> writeNotesBackupFile({
  required List<UserAnnotation> notes,
  required String fileName,
}) {
  return impl.writeNotesBackupFile(notes: notes, fileName: fileName);
}

/// Lets the user pick a notes-backup SQLite file and parses it. Returns null
/// when the picker was cancelled; throws with a user-readable message when
/// the file is not a valid notes backup.
Future<List<UserAnnotation>?> readNotesBackupFile() {
  return impl.readNotesBackupFile();
}
