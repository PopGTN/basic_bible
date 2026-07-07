import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';
import 'package:basic_bible/src/features/sync/models/note_sync_codec.dart';
import 'package:basic_bible/src/services/app_database.dart';

import 'google_auth_service.dart';
import 'google_drive_notes_api.dart';
import 'note_merge_engine.dart';

class SyncSummary {
  const SyncSummary({required this.applied, required this.pushed});

  /// Notes written into the local database this pass.
  final int applied;

  /// Notes uploaded to Drive this pass.
  final int pushed;

  bool get changedAnything => applied > 0 || pushed > 0;
}

/// One full sync pass against the Drive appDataFolder.
///
/// Planning is done on listing metadata alone (each file's appProperties
/// carries the note's updatedAt), so an unchanged library costs exactly one
/// HTTP call — downloads/uploads happen only for notes that actually differ.
/// The decisions mirror the merge engine's last-write-wins rules, and any
/// note that must be compared content-wise goes through [mergeNotes] itself.
class NotesSyncRepository {
  NotesSyncRepository({
    required AppDatabase db,
    required GoogleAuthService auth,
    required DriveNotesApi api,
  }) : _db = db,
       _auth = auth,
       _api = api;

  final AppDatabase _db;
  final GoogleAuthService _auth;
  final DriveNotesApi _api;

  int _millisOf(UserAnnotation note) =>
      note.updatedAt.toUtc().millisecondsSinceEpoch;

  Future<SyncSummary> syncOnce() async {
    final token = await _auth.getAccessToken();

    final remoteFiles = await _api.listNoteFiles(token);
    final remoteByUuid = {for (final f in remoteFiles) f.uuid: f};
    final localNotes = await _db.getAllUserAnnotationsIncludingDeleted();
    final localByUuid = {for (final n in localNotes) n.uuid!: n};

    final toDownload = <DriveNoteFile>[];
    final toPush = <UserAnnotation>[];

    for (final file in remoteFiles) {
      final local = localByUuid[file.uuid];
      if (local == null) {
        toDownload.add(file);
        continue;
      }
      final remoteMillis = file.updatedAtMillis;
      if (remoteMillis == null || remoteMillis > _millisOf(local)) {
        // Unknown remote age (older app version wrote it) or remote is newer:
        // download and let the merge engine decide.
        toDownload.add(file);
      } else if (remoteMillis < _millisOf(local)) {
        toPush.add(local);
      }
      // Equal timestamps → the remote file is this note's own last upload;
      // nothing to do.
    }
    for (final local in localNotes) {
      if (!remoteByUuid.containsKey(local.uuid)) {
        toPush.add(local);
      }
    }

    // Resolve the downloads through the shared merge engine so conflict
    // semantics (including tombstone rules) are identical to file import.
    var applied = 0;
    if (toDownload.isNotEmpty) {
      final downloaded = <UserAnnotation>[];
      for (final file in toDownload) {
        downloaded.add(
          annotationFromSyncJsonString(
            await _api.downloadNoteContent(token, file.fileId),
          ),
        );
      }
      final plan = mergeNotes(
        local: [
          for (final note in downloaded)
            if (localByUuid[note.uuid] != null) localByUuid[note.uuid]!,
        ],
        remote: downloaded,
      );
      for (final note in plan.toApplyLocally) {
        await _db.upsertAnnotationFromSync(note);
        applied++;
      }
      // If the local copy actually wins (e.g. the remote file predates
      // updatedAt stamping), push it instead.
      toPush.addAll(plan.toPushRemote);
    }

    for (final note in toPush) {
      await _api.uploadNote(
        accessToken: token,
        uuid: note.uuid!,
        jsonContent: annotationToSyncJsonString(note),
        updatedAtMillis: _millisOf(note),
        existingFileId: remoteByUuid[note.uuid]?.fileId,
      );
    }

    return SyncSummary(applied: applied, pushed: toPush.length);
  }
}
