// Guards the Notes screen filters (#39), using the same functions the screen
// calls (note_filters.dart) rather than a copy of its predicate.
//
// Type semantics: "Note" = any annotation with note text (with or without a
// highlight); "Highlight only" = a highlight with no note text. Previously
// "Note" only matched notes that also had a highlight, so a plain note was
// hidden by every Type selection.

import 'package:basic_bible/src/features/annotations/models/note_filters.dart';
import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';
import 'package:flutter_test/flutter_test.dart';

AnnotationVerseLink _verse() => const AnnotationVerseLink(
  bookId: 'JHN',
  chapter: 3,
  verse: 16,
  translationId: 'kjv',
  translationName: 'KJV',
);

UserAnnotation _annotation({
  String? noteText,
  int? highlightColorValue,
  DateTime? created,
  DateTime? updated,
}) {
  final created0 = created ?? DateTime(2026);
  return UserAnnotation(
    type: noteText != null
        ? UserAnnotationType.note
        : UserAnnotationType.highlight,
    primaryVerse: _verse(),
    noteText: noteText,
    highlightColorValue: highlightColorValue,
    createdAt: created0,
    updatedAt: updated ?? created0,
  );
}

void main() {
  group('type', () {
    final highlightOnly = _annotation(highlightColorValue: 0xffff0000);
    final plainNote = _annotation(noteText: 'just text');
    final noteWithHighlight = _annotation(
      noteText: 'text and color',
      highlightColorValue: 0xff00ff00,
    );

    test('no types selected shows everything', () {
      for (final a in [highlightOnly, plainNote, noteWithHighlight]) {
        expect(matchesNoteTypes(a, {}), isTrue);
      }
    });

    test('"Note" matches every annotation with note text', () {
      const note = {NoteTypeFilter.note};
      expect(matchesNoteTypes(plainNote, note), isTrue);
      expect(matchesNoteTypes(noteWithHighlight, note), isTrue);
      expect(matchesNoteTypes(highlightOnly, note), isFalse);
    });

    test('"Highlight only" matches a highlight with no note text', () {
      const highlight = {NoteTypeFilter.highlight};
      expect(matchesNoteTypes(highlightOnly, highlight), isTrue);
      expect(matchesNoteTypes(plainNote, highlight), isFalse);
      expect(matchesNoteTypes(noteWithHighlight, highlight), isFalse);
    });

    test('selecting both types is a union', () {
      final both = NoteTypeFilter.values.toSet();
      for (final a in [highlightOnly, plainNote, noteWithHighlight]) {
        expect(matchesNoteTypes(a, both), isTrue);
      }
    });
  });

  group('date', () {
    final now = DateTime(2026, 11, 14, 15);
    final oldButEdited = _annotation(
      noteText: 'a',
      created: DateTime(2025, 1, 1),
      updated: DateTime(2026, 11, 14, 9),
    );
    final lastWeek = _annotation(noteText: 'b', created: DateTime(2026, 11, 10));

    test('any time keeps everything', () {
      expect(
        matchesNoteDateRange(
          oldButEdited,
          field: NoteDateField.created,
          range: NoteDateRange.any,
          now: now,
        ),
        isTrue,
      );
    });

    test('ranges use the chosen field', () {
      bool today(UserAnnotation a, NoteDateField f) => matchesNoteDateRange(
        a,
        field: f,
        range: NoteDateRange.today,
        now: now,
      );
      expect(today(oldButEdited, NoteDateField.modified), isTrue);
      expect(today(oldButEdited, NoteDateField.created), isFalse);
      expect(
        matchesNoteDateRange(
          lastWeek,
          field: NoteDateField.created,
          range: NoteDateRange.pastWeek,
          now: now,
        ),
        isTrue,
      );
    });

    test('sorting is newest first by the chosen field', () {
      final list = [lastWeek, oldButEdited];
      expect(sortNotesByDate(list, NoteDateField.modified), [
        oldButEdited,
        lastWeek,
      ]);
      expect(sortNotesByDate(list, NoteDateField.created), [
        lastWeek,
        oldButEdited,
      ]);
    });
  });
}
