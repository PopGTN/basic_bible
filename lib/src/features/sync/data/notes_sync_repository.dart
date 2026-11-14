import 'dart:math';

import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';
import 'package:basic_bible/src/features/sync/models/note_sync_codec.dart';
import 'package:basic_bible/src/services/app_database.dart';

import 'google_auth_service.dart';
import 'google_drive_notes_api.dart';
import 'note_merge_engine.dart';

class SyncSummary {
  const SyncSummary({
    required this.applied,
    required this.pushed,
    this.downloaded = 0,
  });

  /// Notes written into the local database this pass.
  final int applied;

  /// Notes uploaded to Drive this pass.
  final int pushed;

  /// Note files downloaded from Drive this pass.
  final int downloaded;

  bool get changedAnything => applied > 0 || pushed > 0;
}

/// One full sync pass against the Drive appDataFolder.
///
/// Planning is done on listing metadata alone (each file's appProperties
/// carries the note's updatedAt and tombstone flag) against a narrow local
/// `uuid → updatedAt` index, so an unchanged library costs exactly one HTTP
/// call and one cheap query. Downloads/uploads happen only for notes that
/// actually differ, and run with bounded concurrency so the radio is busy
/// for as short a time as possible.
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

  /// Parallel Drive requests per pass. Enough to shorten first syncs a lot,
  /// low enough to stay polite with Drive's per-user rate limits.
  static const _maxConcurrentRequests = 4;

  /// Timestamps are compared at whole-second precision because that is what
  /// drift stores locally; a millisecond stamp from another source would
  /// otherwise look "newer" forever and be re-downloaded on every sync.
  static int _millis(DateTime time) =>
      time.toUtc().millisecondsSinceEpoch ~/ 1000 * 1000;

  Future<SyncSummary> syncOnce() async {
    final token = await _auth.getAccessToken();

    final remoteFiles = await _api.listNoteFiles(token);
    final remoteByUuid = {for (final f in remoteFiles) f.uuid: f};
    final localIndex = await _db.getSyncIndex();

    final toDownload = <DriveNoteFile>[];
    final pushUuids = <String>{};
    // Legacy files whose appProperties lack a stamp; fixed with a cheap
    // metadata-only PATCH so they never need downloading again.
    final toStamp = <String, _Stamp>{};

    for (final file in remoteFiles) {
      final local = localIndex[file.uuid];
      if (local == null) {
        // A tombstone for a note this device doesn't have (or already
        // purged) needs no action. Downloading it would re-insert a
        // tombstone that retention cleanup then purges again, forever.
        if (file.isDeleted == true) continue;
        toDownload.add(file);
        continue;
      }
      final remoteMillis = switch (file.updatedAtMillis) {
        final ms? => ms ~/ 1000 * 1000,
        null => null,
      };
      final localMillis = _millis(local.updatedAt);
      if (remoteMillis == null || remoteMillis > localMillis) {
        // Unknown remote age (older app version wrote it) or remote is newer:
        // download and let the merge engine decide.
        toDownload.add(file);
      } else if (remoteMillis < localMillis) {
        pushUuids.add(file.uuid);
      } else if (file.isDeleted == null) {
        // In sync, but written before tombstone stamping.
        toStamp[file.uuid] = _Stamp(file.fileId, localMillis, local.isDeleted);
      }
    }
    for (final uuid in localIndex.keys) {
      if (!remoteByUuid.containsKey(uuid)) pushUuids.add(uuid);
    }

    // Resolve the downloads through the shared merge engine so conflict
    // semantics (including tombstone rules) are identical to file import.
    var applied = 0;
    if (toDownload.isNotEmpty) {
      final downloaded = await _mapBounded(
        toDownload,
        (file) async => annotationFromSyncJsonString(
          await _api.downloadNoteContent(token, file.fileId),
        ),
      );

      final mergeable = <UserAnnotation>[];
      for (final note in downloaded) {
        final file = remoteByUuid[note.uuid]!;
        if (file.updatedAtMillis == null || file.isDeleted == null) {
          // Describe the file's own content. If the local copy wins the
          // merge below, the upload overwrites this with fresh values.
          toStamp[note.uuid!] = _Stamp(
            file.fileId,
            _millis(note.updatedAt),
            note.isDeleted,
          );
        }
        // Remote-only tombstone (legacy file): nothing to delete locally.
        if (note.isDeleted && !localIndex.containsKey(note.uuid)) continue;
        mergeable.add(note);
      }

      final localForMerge = await _db.getUserAnnotationsByUuids(
        mergeable.map((n) => n.uuid!).where(localIndex.containsKey),
      );
      final plan = mergeNotes(local: localForMerge, remote: mergeable);
      applied = await _db.applySyncedAnnotations(plan.toApplyLocally);

      // If the local copy actually wins (e.g. the remote file predates
      // updatedAt stamping), push it instead.
      pushUuids.addAll(plan.toPushRemote.map((n) => n.uuid!));
    }
    // An upload rewrites appProperties anyway.
    toStamp.removeWhere((uuid, _) => pushUuids.contains(uuid));

    final toPush = await _db.getUserAnnotationsByUuids(pushUuids);
    await _mapBounded(
      toPush,
      (note) => _api.uploadNote(
        accessToken: token,
        uuid: note.uuid!,
        jsonContent: annotationToSyncJsonString(note),
        updatedAtMillis: _millis(note.updatedAt),
        isDeleted: note.isDeleted,
        existingFileId: remoteByUuid[note.uuid]?.fileId,
      ),
    );

    await _mapBounded(
      toStamp.values.toList(),
      (stamp) => _api.updateNoteProperties(
        accessToken: token,
        fileId: stamp.fileId,
        updatedAtMillis: stamp.updatedAtMillis,
        isDeleted: stamp.isDeleted,
      ),
    );

    return SyncSummary(
      applied: applied,
      pushed: toPush.length,
      downloaded: toDownload.length,
    );
  }

  /// Maps [items] through [fn] with at most [_maxConcurrentRequests] calls in
  /// flight, preserving order.
  Future<List<R>> _mapBounded<T, R>(
    List<T> items,
    Future<R> Function(T item) fn,
  ) async {
    if (items.isEmpty) return const [];
    final results = List<R?>.filled(items.length, null);
    var next = 0;
    Future<void> worker() async {
      while (next < items.length) {
        final index = next++;
        results[index] = await fn(items[index]);
      }
    }

    await Future.wait([
      for (var i = 0; i < min(_maxConcurrentRequests, items.length); i++)
        worker(),
    ]);
    return results.cast<R>();
  }
}

class _Stamp {
  const _Stamp(this.fileId, this.updatedAtMillis, this.isDeleted);

  final String fileId;
  final int updatedAtMillis;
  final bool isDeleted;
}
