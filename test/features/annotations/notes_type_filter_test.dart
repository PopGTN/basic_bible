// Guards the Notes screen's "Type" filter semantics: 'highlightOnly' matches
// a highlight with no note text, 'noteWithHighlight' matches a note that also
// carries a highlight color. This replicates the exact matchesType predicate
// from _NotesScreenState.build (private, can't be imported from another
// library file) against the real UserAnnotation model.

import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';
import 'package:flutter_test/flutter_test.dart';

bool _matchesType(UserAnnotation annotation, Set<String> selectedTypes) {
  return selectedTypes.isEmpty ||
      (selectedTypes.contains('highlightOnly') &&
          annotation.hasHighlight &&
          !annotation.hasNoteText) ||
      (selectedTypes.contains('noteWithHighlight') &&
          annotation.hasNoteText &&
          annotation.hasHighlight);
}

AnnotationVerseLink _verse() => AnnotationVerseLink(
  bookId: 'JHN',
  chapter: 3,
  verse: 16,
  translationId: 'kjv',
  translationName: 'KJV',
);

UserAnnotation _annotation({String? noteText, int? highlightColorValue}) {
  final now = DateTime(2026);
  return UserAnnotation(
    type: noteText != null
        ? UserAnnotationType.note
        : UserAnnotationType.highlight,
    primaryVerse: _verse(),
    noteText: noteText,
    highlightColorValue: highlightColorValue,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  final highlightOnly = _annotation(highlightColorValue: 0xffff0000);
  final plainNote = _annotation(noteText: 'just text');
  final noteWithHighlight = _annotation(
    noteText: 'text and color',
    highlightColorValue: 0xff00ff00,
  );

  test('no types selected shows everything', () {
    expect(_matchesType(highlightOnly, {}), isTrue);
    expect(_matchesType(plainNote, {}), isTrue);
    expect(_matchesType(noteWithHighlight, {}), isTrue);
  });

  test('"highlightOnly" matches a highlight with no note text', () {
    expect(_matchesType(highlightOnly, {'highlightOnly'}), isTrue);
    expect(_matchesType(plainNote, {'highlightOnly'}), isFalse);
    expect(
      _matchesType(noteWithHighlight, {'highlightOnly'}),
      isFalse,
      reason: 'has note text, so it is not a highlight-only entry',
    );
  });

  test('"noteWithHighlight" matches a note that also has a highlight color', () {
    expect(_matchesType(noteWithHighlight, {'noteWithHighlight'}), isTrue);
    expect(
      _matchesType(plainNote, {'noteWithHighlight'}),
      isFalse,
      reason: 'no highlight color, so it does not qualify',
    );
    expect(_matchesType(highlightOnly, {'noteWithHighlight'}), isFalse);
  });

  test('a plain text-only note (no highlight) never matches either type', () {
    expect(_matchesType(plainNote, {'highlightOnly'}), isFalse);
    expect(_matchesType(plainNote, {'noteWithHighlight'}), isFalse);
    expect(
      _matchesType(plainNote, {'highlightOnly', 'noteWithHighlight'}),
      isFalse,
    );
  });

  test('selecting both types is a union', () {
    const both = {'highlightOnly', 'noteWithHighlight'};
    expect(_matchesType(highlightOnly, both), isTrue);
    expect(_matchesType(noteWithHighlight, both), isTrue);
    expect(_matchesType(plainNote, both), isFalse);
  });
}
