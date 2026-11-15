// "+N more" used to be a dead label: verses past the limit could not be seen
// (or removed in the editor). It is now a Show all / Show less toggle.

import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';
import 'package:basic_bible/src/features/annotations/presentation/linked_verses_section.dart';
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
  testWidgets('Show all reveals every verse, Show less collapses', (
    tester,
  ) async {
    final removed = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: LinkedVersesSection(
              books: const [],
              // Tap order, as stored.
              links: [for (final v in [5, 1, 4, 2, 3]) _v(v)],
              maxVisible: 2,
              onPreviewLinkedVerse: (_) async {},
              onDeleteLink: (link) => removed.add(link.verse),
            ),
          ),
        ),
      ),
    );

    // Collapsed: first two in reading order, plus the toggle.
    expect(find.text('Luke 15:1'), findsOneWidget);
    expect(find.text('Luke 15:2'), findsOneWidget);
    expect(find.text('Luke 15:5'), findsNothing);
    expect(find.text('Show all (+3)'), findsOneWidget);

    await tester.tap(find.text('Show all (+3)'));
    await tester.pump();
    for (var v = 1; v <= 5; v++) {
      expect(find.text('Luke 15:$v'), findsOneWidget);
    }

    // A verse that was hidden can now be removed.
    final chip5 = find.ancestor(
      of: find.text('Luke 15:5'),
      matching: find.byType(InputChip),
    );
    await tester.tap(
      find.descendant(of: chip5, matching: find.byIcon(Icons.close)),
    );
    expect(removed, [5]);

    await tester.tap(find.text('Show less'));
    await tester.pump();
    expect(find.text('Luke 15:5'), findsNothing);
    expect(find.text('Show all (+3)'), findsOneWidget);
  });

  testWidgets('no toggle when everything fits', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LinkedVersesSection(
            books: const [],
            links: [_v(1), _v(2)],
            maxVisible: 5,
            onPreviewLinkedVerse: (_) async {},
          ),
        ),
      ),
    );
    expect(find.textContaining('Show'), findsNothing);
  });
}
