// Note Details shows verses as sections or single verses (range chips);
// only the new/edit note screens list every verse individually.

import 'package:basic_bible/src/features/annotations/models/annotation_verse_ranges.dart';
import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';
import 'package:basic_bible/src/features/annotations/presentation/annotation_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

AnnotationVerseLink _v(int verse) => AnnotationVerseLink(
  bookId: 'LUK',
  chapter: 15,
  verse: verse,
  translationId: 'kjv',
  translationName: 'KJV',
);

void main() {
  testWidgets('heading is the primary section, the rest are range chips', (
    tester,
  ) async {
    AnnotationVerseRange? previewed;
    await tester.pumpWidget(
      MaterialApp(
        home: AnnotationDetailScreen(
          annotation: UserAnnotation(
            type: UserAnnotationType.note,
            noteText: 'The lost sheep',
            primaryVerse: _v(5),
            // Stored in tap order, with 15:8 and 15:12 skipped.
            linkedVerses: [_v(14), _v(10), _v(7), _v(9), _v(6), _v(11)],
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
          books: const [],
          onPreviewVerses: (verses) async => previewed = verses,
          onOpenReference: () async {},
          onEdit: () async {},
          onDelete: () async {},
        ),
      ),
    );

    expect(find.text('Luke 15:5-7'), findsOneWidget); // heading
    expect(find.text('Luke 15:9-11'), findsOneWidget);
    expect(find.text('Luke 15:14'), findsOneWidget);
    // No per-verse chips.
    expect(find.text('Luke 15:9'), findsNothing);
    expect(find.text('Luke 15:10'), findsNothing);

    await tester.tap(find.text('Luke 15:9-11'));
    expect(previewed?.label('Luke'), 'Luke 15:9-11');
  });
}
