import 'package:basic_bible/src/features/annotations/data/user_annotation_repository.dart';
import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';
import 'package:basic_bible/src/models/bible_models.dart';
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

  AnnotationVerseLink link({
    required String bookId,
    required int chapter,
    required int verse,
    String translationId = 'kjv',
    String translationName = 'King James Version',
    int sortOrder = 0,
  }) {
    return AnnotationVerseLink(
      bookId: bookId,
      chapter: chapter,
      verse: verse,
      translationId: translationId,
      translationName: translationName,
      sortOrder: sortOrder,
    );
  }

  test('saves and loads a standalone highlight', () async {
    final id = await repository.saveAnnotation(
      UserAnnotation(
        type: UserAnnotationType.highlight,
        primaryVerse: link(bookId: 'JHN', chapter: 1, verse: 1),
        highlightColorValue: const ColorTestValue(0xFFFFEB3B).value,
        createdAt: DateTime(2026, 4, 3, 12),
        updatedAt: DateTime(2026, 4, 3, 12),
      ),
    );

    final loaded = await repository.getAnnotationById(id);

    expect(loaded, isNotNull);
    expect(loaded!.type, UserAnnotationType.highlight);
    expect(loaded.primaryVerse.bookId, 'JHN');
    expect(loaded.primaryVerse.chapter, 1);
    expect(loaded.primaryVerse.verse, 1);
    expect(loaded.highlightColorValue, const ColorTestValue(0xFFFFEB3B).value);
    expect(loaded.hasNoteText, isFalse);
  });

  test('preserves linked verses and translation metadata for a note', () async {
    final id = await repository.saveAnnotation(
      UserAnnotation(
        type: UserAnnotationType.note,
        primaryVerse: link(
          bookId: 'ROM',
          chapter: 8,
          verse: 28,
          translationId: 'web',
          translationName: 'World English Bible',
        ),
        noteText: 'Promise worth revisiting.',
        highlightColorValue: const ColorTestValue(0xFF8BC34A).value,
        labels: const ['promise', 'encouragement'],
        linkedVerses: [
          link(
            bookId: 'JAS',
            chapter: 1,
            verse: 2,
            translationId: 'asv',
            translationName: 'American Standard Version',
            sortOrder: 0,
          ),
          link(
            bookId: 'PHP',
            chapter: 4,
            verse: 6,
            translationId: 'kjv',
            translationName: 'King James Version',
            sortOrder: 1,
          ),
        ],
        createdAt: DateTime(2026, 4, 3, 12),
        updatedAt: DateTime(2026, 4, 3, 12),
      ),
    );

    final loaded = await repository.getAnnotationById(id);

    expect(loaded, isNotNull);
    expect(loaded!.noteText, 'Promise worth revisiting.');
    expect(loaded.primaryVerse.translationId, 'web');
    expect(loaded.primaryVerse.translationName, 'World English Bible');
    expect(loaded.linkedVerses, hasLength(2));
    expect(loaded.linkedVerses.first.translationId, 'asv');
    expect(
      loaded.linkedVerses.first.translationName,
      'American Standard Version',
    );
    expect(loaded.linkedVerses.last.bookId, 'PHP');
    expect(loaded.labels, ['promise', 'encouragement']);
  });

  test(
    'editing and deleting one annotation does not disturb another',
    () async {
      final firstId = await repository.saveAnnotation(
        UserAnnotation(
          type: UserAnnotationType.note,
          primaryVerse: link(bookId: 'GEN', chapter: 1, verse: 1),
          noteText: 'Original note',
          createdAt: DateTime(2026, 4, 3, 10),
          updatedAt: DateTime(2026, 4, 3, 10),
        ),
      );
      final secondId = await repository.saveAnnotation(
        UserAnnotation(
          type: UserAnnotationType.highlight,
          primaryVerse: link(bookId: 'GEN', chapter: 1, verse: 2),
          highlightColorValue: const ColorTestValue(0xFF4DD0E1).value,
          createdAt: DateTime(2026, 4, 3, 11),
          updatedAt: DateTime(2026, 4, 3, 11),
        ),
      );

      await repository.saveAnnotation(
        UserAnnotation(
          id: firstId,
          type: UserAnnotationType.note,
          primaryVerse: link(bookId: 'GEN', chapter: 1, verse: 1),
          noteText: 'Updated note',
          highlightColorValue: const ColorTestValue(0xFFCE93D8).value,
          createdAt: DateTime(2026, 4, 3, 10),
          updatedAt: DateTime(2026, 4, 3, 12),
        ),
      );

      var all = await repository.getAnnotations();
      expect(all, hasLength(2));
      expect(
        all.firstWhere((annotation) => annotation.id == firstId).noteText,
        'Updated note',
      );
      expect(
        all
            .firstWhere((annotation) => annotation.id == secondId)
            .highlightColorValue,
        const ColorTestValue(0xFF4DD0E1).value,
      );

      await repository.deleteAnnotation(firstId);

      all = await repository.getAnnotations();
      expect(all, hasLength(1));
      expect(all.single.id, secondId);
      expect(all.single.primaryVerse.verse, 2);
    },
  );

  test(
    'standalone highlights remain separate from note-owned highlights',
    () async {
      final noteId = await repository.saveAnnotation(
        UserAnnotation(
          type: UserAnnotationType.note,
          primaryVerse: link(bookId: 'JHN', chapter: 1, verse: 1),
          noteText: 'Keep this note-owned color',
          highlightColorValue: const ColorTestValue(0xFF81C784).value,
          createdAt: DateTime(2026, 4, 3, 10),
          updatedAt: DateTime(2026, 4, 3, 10),
        ),
      );
      final highlightId = await repository.saveAnnotation(
        UserAnnotation(
          type: UserAnnotationType.highlight,
          primaryVerse: link(bookId: 'JHN', chapter: 1, verse: 1),
          highlightColorValue: const ColorTestValue(0xFFFFF176).value,
          createdAt: DateTime(2026, 4, 3, 11),
          updatedAt: DateTime(2026, 4, 3, 11),
        ),
      );

      final all = await repository.getAnnotations();
      expect(all, hasLength(2));

      final savedNote = await repository.getAnnotationById(noteId);
      final savedHighlight = await repository.getAnnotationById(highlightId);

      expect(savedNote, isNotNull);
      expect(savedNote!.hasNoteText, isTrue);
      expect(savedNote.hasHighlight, isTrue);
      expect(savedNote.isHighlightOnly, isFalse);

      expect(savedHighlight, isNotNull);
      expect(savedHighlight!.hasHighlight, isTrue);
      expect(savedHighlight.hasNoteText, isFalse);
      expect(savedHighlight.isHighlightOnly, isTrue);
    },
  );

  test(
    'removeReferencesFromStandaloneHighlight splits a grouped highlight',
    () {
      final annotation = UserAnnotation(
        id: 9,
        type: UserAnnotationType.highlight,
        primaryVerse: link(bookId: 'JHN', chapter: 1, verse: 1),
        linkedVerses: [
          link(bookId: 'JHN', chapter: 1, verse: 2, sortOrder: 0),
          link(bookId: 'JHN', chapter: 1, verse: 3, sortOrder: 1),
          link(bookId: 'JHN', chapter: 1, verse: 4, sortOrder: 2),
        ],
        highlightColorValue: const ColorTestValue(0xFFFFF176).value,
        createdAt: DateTime(2026, 4, 3, 11),
        updatedAt: DateTime(2026, 4, 3, 11),
      );

      final result = removeReferencesFromStandaloneHighlight(annotation, const [
        BibleReference(bookId: 'JHN', chapter: 1, verse: 2),
        BibleReference(bookId: 'JHN', chapter: 1, verse: 3),
      ], translationId: 'kjv');

      expect(result, isNotNull);
      expect(result!.primaryVerse.verse, 1);
      expect(result.linkedVerses, hasLength(1));
      expect(result.linkedVerses.single.verse, 4);
      expect(result.linkedVerses.single.sortOrder, 0);
    },
  );

  test(
    'removeReferencesFromStandaloneHighlight deletes whole highlight when fully selected',
    () {
      final annotation = UserAnnotation(
        type: UserAnnotationType.highlight,
        primaryVerse: link(bookId: 'JHN', chapter: 1, verse: 1),
        linkedVerses: [link(bookId: 'JHN', chapter: 1, verse: 2, sortOrder: 0)],
        highlightColorValue: const ColorTestValue(0xFFFFF176).value,
        createdAt: DateTime(2026, 4, 3, 11),
        updatedAt: DateTime(2026, 4, 3, 11),
      );

      final result = removeReferencesFromStandaloneHighlight(annotation, const [
        BibleReference(bookId: 'JHN', chapter: 1, verse: 1),
        BibleReference(bookId: 'JHN', chapter: 1, verse: 2),
      ], translationId: 'kjv');

      expect(result, isNull);
    },
  );
}

class ColorTestValue {
  const ColorTestValue(this.value);

  final int value;
}
