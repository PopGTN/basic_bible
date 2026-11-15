// Checks whether UserAnnotationRepository.watchAnnotations() reactively
// emits after a new annotation is saved — the DB-level half of "adding a
// note in the per-verse notes sheet doesn't automatically update the list."
// If this passes, the bug is in the sheet/provider wiring, not Drift's
// stream invalidation.

import 'package:basic_bible/src/features/annotations/data/user_annotation_repository.dart';
import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';
import 'package:basic_bible/src/services/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late UserAnnotationRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = UserAnnotationRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('watchAnnotations emits again after saveAnnotation adds a note', () async {
    final emissions = <List<UserAnnotation>>[];
    final subscription = repository.watchAnnotations().listen(emissions.add);
    addTearDown(subscription.cancel);

    // Let the initial (empty) emission land.
    await Future<void>.delayed(Duration.zero);
    expect(emissions, isNotEmpty);
    final countBeforeSave = emissions.length;

    await repository.saveAnnotation(
      UserAnnotation(
        type: UserAnnotationType.note,
        primaryVerse: const AnnotationVerseLink(
          bookId: 'JHN',
          chapter: 3,
          verse: 16,
          translationId: 'kjv',
          translationName: 'King James Version',
        ),
        noteText: 'For God so loved the world',
        createdAt: DateTime(2026, 4, 3, 12),
        updatedAt: DateTime(2026, 4, 3, 12),
      ),
    );

    // Drift's stream emits asynchronously after the write commits.
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(
      emissions.length,
      greaterThan(countBeforeSave),
      reason: 'watchAnnotations() never emitted after saveAnnotation',
    );
    expect(emissions.last, hasLength(1));
    expect(emissions.last.single.noteText, 'For God so loved the world');
  });

  test(
    'a second note on the same verse also triggers a fresh emission '
    '(mirrors tapping "Add Note" a second time in the per-verse sheet)',
    () async {
      await repository.saveAnnotation(
        UserAnnotation(
          type: UserAnnotationType.note,
          primaryVerse: const AnnotationVerseLink(
            bookId: 'JHN',
            chapter: 3,
            verse: 16,
            translationId: 'kjv',
            translationName: 'King James Version',
          ),
          noteText: 'First note',
          createdAt: DateTime(2026, 4, 3, 12),
          updatedAt: DateTime(2026, 4, 3, 12),
        ),
      );

      final emissions = <List<UserAnnotation>>[];
      final subscription = repository.watchAnnotations().listen(emissions.add);
      addTearDown(subscription.cancel);
      await Future<void>.delayed(Duration.zero);
      expect(emissions.last, hasLength(1));

      await repository.saveAnnotation(
        UserAnnotation(
          type: UserAnnotationType.note,
          primaryVerse: const AnnotationVerseLink(
            bookId: 'JHN',
            chapter: 3,
            verse: 16,
            translationId: 'kjv',
            translationName: 'King James Version',
          ),
          noteText: 'Second note',
          createdAt: DateTime(2026, 4, 3, 13),
          updatedAt: DateTime(2026, 4, 3, 13),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(emissions.last, hasLength(2));
      expect(
        emissions.last.map((a) => a.noteText),
        containsAll(['First note', 'Second note']),
      );
    },
  );
}
