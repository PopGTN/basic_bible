import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';
import 'package:basic_bible/src/features/sync/models/note_sync_codec.dart';

/// The actions needed to converge a local and a remote set of notes.
///
/// Both Drive sync and file import run through this: "remote" is the Drive
/// App Data folder or the imported file. The plan is computed per uuid, fully
/// independently — deciding note A's fate never reads or writes note B, which
/// is the core no-clobber guarantee of the whole feature.
class NoteMergePlan {
  const NoteMergePlan({
    required this.toApplyLocally,
    required this.toPushRemote,
  });

  /// Notes to write into the local database (via upsertAnnotationFromSync).
  final List<UserAnnotation> toApplyLocally;

  /// Notes to write to the remote side (Drive upload / ignored by import).
  final List<UserAnnotation> toPushRemote;

  bool get isNoop => toApplyLocally.isEmpty && toPushRemote.isEmpty;
}

/// Computes a [NoteMergePlan] from the two sides' full note sets (tombstones
/// included). Pure function — no I/O, no clocks, deterministic:
///
/// - uuid only on one side → copy to the other side.
/// - uuid on both sides → newer `updatedAt` wins (a tombstone is just a note
///   whose deletion was the latest edit, so deletes propagate with no special
///   casing).
/// - identical `updatedAt`: equal content is a no-op; differing content picks
///   a winner by comparing canonical JSON, so every device converges on the
///   same result instead of ping-ponging or diverging forever. A tombstone
///   wins such a tie outright — converging on "deleted" is the only outcome
///   that doesn't resurrect a note the user removed.
///
/// Every note must carry a uuid; sets originate from the v8+ schema or the
/// sync codec, both of which guarantee it.
NoteMergePlan mergeNotes({
  required List<UserAnnotation> local,
  required List<UserAnnotation> remote,
}) {
  final localByUuid = {for (final note in local) _requireUuid(note): note};
  final remoteByUuid = {for (final note in remote) _requireUuid(note): note};

  final toApplyLocally = <UserAnnotation>[];
  final toPushRemote = <UserAnnotation>[];

  for (final entry in remoteByUuid.entries) {
    final localNote = localByUuid[entry.key];
    if (localNote == null) {
      toApplyLocally.add(entry.value);
    }
  }

  for (final entry in localByUuid.entries) {
    final localNote = entry.value;
    final remoteNote = remoteByUuid[entry.key];
    if (remoteNote == null) {
      toPushRemote.add(localNote);
      continue;
    }

    if (localNote.updatedAt.isAfter(remoteNote.updatedAt)) {
      toPushRemote.add(localNote);
    } else if (remoteNote.updatedAt.isAfter(localNote.updatedAt)) {
      toApplyLocally.add(remoteNote);
    } else {
      final localJson = annotationToSyncJsonString(localNote);
      final remoteJson = annotationToSyncJsonString(remoteNote);
      if (localJson == remoteJson) continue; // already in sync
      final winnerIsLocal = switch ((localNote.isDeleted, remoteNote.isDeleted)) {
        (true, false) => true,
        (false, true) => false,
        _ => localJson.compareTo(remoteJson) > 0,
      };
      if (winnerIsLocal) {
        toPushRemote.add(localNote);
      } else {
        toApplyLocally.add(remoteNote);
      }
    }
  }

  return NoteMergePlan(
    toApplyLocally: toApplyLocally,
    toPushRemote: toPushRemote,
  );
}

String _requireUuid(UserAnnotation note) {
  final uuid = note.uuid;
  if (uuid == null) {
    throw ArgumentError('mergeNotes requires every note to carry a uuid');
  }
  return uuid;
}
