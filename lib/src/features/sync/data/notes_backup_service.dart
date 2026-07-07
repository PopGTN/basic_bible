import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';
import 'package:basic_bible/src/services/app_database.dart';

import 'note_merge_engine.dart';
import 'notes_backup_file.dart';

class NotesImportResult {
  const NotesImportResult({required this.total, required this.applied});

  /// Notes found in the backup file.
  final int total;

  /// Notes actually written locally (new or newer than the local copy);
  /// everything else was already up to date or older than a local edit.
  final int applied;
}

/// Export/import of notes as a standalone SQLite file. Import runs through
/// the same per-uuid merge engine as Drive sync (treating the file as the
/// "remote" side), so restoring a backup can never clobber notes that were
/// edited after the backup was made.
class NotesBackupService {
  NotesBackupService(this._db);

  final AppDatabase _db;

  /// Returns false when the user cancelled the save dialog. Exports active
  /// notes only — tombstones are sync bookkeeping, not user data.
  Future<bool> exportNotes() async {
    final notes = await _db.getAllUserAnnotations();
    final date = DateTime.now().toIso8601String().split('T').first;
    return writeNotesBackupFile(
      notes: notes,
      fileName: 'basic_bible_notes_$date.sqlite',
    );
  }

  /// Returns null when the user cancelled the file picker.
  Future<NotesImportResult?> importNotes() async {
    final imported = await readNotesBackupFile();
    if (imported == null) return null;

    final local = await _db.getAllUserAnnotationsIncludingDeleted();
    final plan = mergeNotes(local: local, remote: imported);
    // toPushRemote is meaningless for a file import and is ignored.
    for (final UserAnnotation note in plan.toApplyLocally) {
      await _db.upsertAnnotationFromSync(note);
    }
    return NotesImportResult(
      total: imported.length,
      applied: plan.toApplyLocally.length,
    );
  }
}
