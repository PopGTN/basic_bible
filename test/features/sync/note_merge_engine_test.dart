import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';
import 'package:basic_bible/src/features/sync/data/note_merge_engine.dart';
import 'package:basic_bible/src/features/sync/models/note_sync_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final baseTime = DateTime.utc(2026, 7, 1, 12);

  UserAnnotation note({
    required String uuid,
    String text = 'text',
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return UserAnnotation(
      uuid: uuid,
      type: UserAnnotationType.note,
      primaryVerse: const AnnotationVerseLink(
        bookId: 'JHN',
        chapter: 3,
        verse: 16,
        translationId: 'kjv',
        translationName: 'King James Version',
      ),
      noteText: text,
      createdAt: baseTime,
      updatedAt: updatedAt ?? baseTime,
      deletedAt: deletedAt,
    );
  }

  test('local-only note is pushed remote', () {
    final plan = mergeNotes(local: [note(uuid: 'a')], remote: []);
    expect(plan.toPushRemote.map((n) => n.uuid), ['a']);
    expect(plan.toApplyLocally, isEmpty);
  });

  test('remote-only note is applied locally', () {
    final plan = mergeNotes(local: [], remote: [note(uuid: 'a')]);
    expect(plan.toApplyLocally.map((n) => n.uuid), ['a']);
    expect(plan.toPushRemote, isEmpty);
  });

  test('newer local edit wins', () {
    final plan = mergeNotes(
      local: [
        note(
          uuid: 'a',
          text: 'newer',
          updatedAt: baseTime.add(const Duration(minutes: 1)),
        ),
      ],
      remote: [note(uuid: 'a', text: 'older')],
    );
    expect(plan.toPushRemote.single.noteText, 'newer');
    expect(plan.toApplyLocally, isEmpty);
  });

  test('newer remote edit wins', () {
    final plan = mergeNotes(
      local: [note(uuid: 'a', text: 'older')],
      remote: [
        note(
          uuid: 'a',
          text: 'newer',
          updatedAt: baseTime.add(const Duration(minutes: 1)),
        ),
      ],
    );
    expect(plan.toApplyLocally.single.noteText, 'newer');
    expect(plan.toPushRemote, isEmpty);
  });

  test('newer tombstone beats older edit in both directions', () {
    final tombstone = note(
      uuid: 'a',
      text: 'gone',
      updatedAt: baseTime.add(const Duration(minutes: 2)),
      deletedAt: baseTime.add(const Duration(minutes: 2)),
    );

    final remoteDeleted = mergeNotes(
      local: [note(uuid: 'a', text: 'still here')],
      remote: [tombstone],
    );
    expect(remoteDeleted.toApplyLocally.single.isDeleted, isTrue);

    final localDeleted = mergeNotes(
      local: [tombstone],
      remote: [note(uuid: 'a', text: 'still here')],
    );
    expect(localDeleted.toPushRemote.single.isDeleted, isTrue);
  });

  test('older tombstone loses to a newer edit (note was re-created)', () {
    final plan = mergeNotes(
      local: [
        note(
          uuid: 'a',
          text: 'edited after delete elsewhere',
          updatedAt: baseTime.add(const Duration(minutes: 5)),
        ),
      ],
      remote: [
        note(uuid: 'a', deletedAt: baseTime, updatedAt: baseTime),
      ],
    );
    expect(plan.toPushRemote.single.isDeleted, isFalse);
    expect(plan.toApplyLocally, isEmpty);
  });

  test('identical notes are a no-op', () {
    final plan = mergeNotes(
      local: [note(uuid: 'a')],
      remote: [note(uuid: 'a')],
    );
    expect(plan.isNoop, isTrue);
  });

  test('equal-timestamp content conflict resolves deterministically', () {
    final localNote = note(uuid: 'a', text: 'apple');
    final remoteNote = note(uuid: 'a', text: 'banana');

    final planA = mergeNotes(local: [localNote], remote: [remoteNote]);
    final planB = mergeNotes(local: [remoteNote], remote: [localNote]);

    // Whichever side holds the winning content, both devices converge on the
    // same note text.
    final winnerA = planA.toApplyLocally.isNotEmpty
        ? planA.toApplyLocally.single.noteText
        : planA.toPushRemote.single.noteText;
    final winnerB = planB.toApplyLocally.isNotEmpty
        ? planB.toApplyLocally.single.noteText
        : planB.toPushRemote.single.noteText;
    expect(winnerA, winnerB);
  });

  test('equal-timestamp tie against a tombstone converges on deleted', () {
    final alive = note(uuid: 'a', text: 'alive');
    final dead = note(uuid: 'a', text: 'alive', deletedAt: baseTime);

    final remoteDead = mergeNotes(local: [alive], remote: [dead]);
    expect(remoteDead.toApplyLocally.single.isDeleted, isTrue);

    final localDead = mergeNotes(local: [dead], remote: [alive]);
    expect(localDead.toPushRemote.single.isDeleted, isTrue);
  });

  test('merging one note never touches another', () {
    final plan = mergeNotes(
      local: [
        note(uuid: 'edited', text: 'v2',
            updatedAt: baseTime.add(const Duration(minutes: 1))),
        note(uuid: 'untouched-local'),
      ],
      remote: [
        note(uuid: 'edited', text: 'v1'),
        note(uuid: 'untouched-remote'),
      ],
    );

    // 'edited' produces exactly one push; the unrelated notes only produce
    // their own copy actions and are never rewritten by the edit.
    expect(plan.toPushRemote.map((n) => n.uuid),
        containsAll(['edited', 'untouched-local']));
    expect(plan.toApplyLocally.map((n) => n.uuid), ['untouched-remote']);
    expect(
      plan.toApplyLocally.every((n) => n.uuid != 'edited'),
      isTrue,
    );
  });

  test('notes without uuid are rejected', () {
    final orphan = UserAnnotation(
      type: UserAnnotationType.note,
      primaryVerse: const AnnotationVerseLink(
        bookId: 'GEN',
        chapter: 1,
        verse: 1,
        translationId: 'kjv',
        translationName: 'King James Version',
      ),
      createdAt: baseTime,
      updatedAt: baseTime,
    );
    expect(
      () => mergeNotes(local: [orphan], remote: []),
      throwsArgumentError,
    );
  });

  test('codec round-trips a note through JSON without loss', () {
    final original = UserAnnotation(
      uuid: 'round-trip',
      type: UserAnnotationType.highlight,
      primaryVerse: const AnnotationVerseLink(
        bookId: 'PSA',
        chapter: 23,
        verse: 1,
        translationId: 'kjv',
        translationName: 'King James Version',
      ),
      noteText: 'The LORD is my shepherd',
      highlightColorValue: 0xFFFFF176,
      labels: const ['comfort', 'favorites'],
      linkedVerses: const [
        AnnotationVerseLink(
          bookId: 'PSA',
          chapter: 23,
          verse: 2,
          translationId: 'kjv',
          translationName: 'King James Version',
          sortOrder: 0,
        ),
      ],
      createdAt: baseTime,
      updatedAt: baseTime.add(const Duration(minutes: 1)),
      deletedAt: null,
    );

    final decoded = annotationFromSyncJsonString(
      annotationToSyncJsonString(original),
    );

    expect(decoded.uuid, original.uuid);
    expect(decoded.type, original.type);
    expect(decoded.noteText, original.noteText);
    expect(decoded.highlightColorValue, original.highlightColorValue);
    expect(decoded.labels, original.labels);
    expect(decoded.primaryVerse.bookId, original.primaryVerse.bookId);
    expect(decoded.linkedVerses, hasLength(1));
    expect(decoded.linkedVerses.single.verse, 2);
    expect(decoded.createdAt.toUtc(), original.createdAt.toUtc());
    expect(decoded.updatedAt.toUtc(), original.updatedAt.toUtc());
    expect(decoded.deletedAt, isNull);
  });
}
