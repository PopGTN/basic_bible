// Issue #84: split view — a second, independent reading pane.

import 'package:basic_bible/src/features/reader/application/view_models/bible_library_view_models.dart';
import 'package:basic_bible/src/features/reader/application/view_models/split_view_view_models.dart';
import 'package:basic_bible/src/features/reader/presentation/split_view/split_reader_layout.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/services/shared_preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

BibleBook _book(String id, int chapters) => BibleBook(
  id: id,
  name: id == 'GEN' ? 'Genesis' : 'Exodus',
  shortName: id,
  bookNumber: id == 'GEN' ? 1 : 2,
  chapters: [for (var c = 1; c <= chapters; c++) BibleChapter(number: c)],
);

final _books = [_book('GEN', 2), _book('EXO', 1)];

Future<ProviderContainer> _container(Map<String, Object> prefs) async {
  SharedPreferences.setMockInitialValues({
    'bible_translation': 'kjv',
    'bible_book': 'GEN',
    'bible_chapter': 1,
    ...prefs,
  });
  final sp = await SharedPreferences.getInstance();
  return ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(sp)],
  );
}

void main() {
  group('pane state', () {
    test('first opening starts where the main reader is, and persists', () async {
      final c = await _container({'bible_book': 'EXO'});
      addTearDown(c.dispose);
      await c.read(splitViewEnabledProvider.notifier).toggle();
      expect(c.read(splitViewEnabledProvider), isTrue);
      expect(c.read(secondaryPaneProvider).reference.bookId, 'EXO');

      final prefs = c.read(sharedPreferencesProvider);
      expect(prefs.getBool('split_view_enabled'), isTrue);
      expect(prefs.getString('split_view_book'), 'EXO');
    });

    test('next/previous cross book boundaries and stop at the ends', () async {
      final c = await _container({'split_view_book': 'GEN', 'split_view_chapter': 2});
      addTearDown(c.dispose);
      final pane = c.read(secondaryPaneProvider.notifier);

      pane.step(_books, 1);
      expect(c.read(secondaryPaneProvider).reference, const BibleReference(bookId: 'EXO', chapter: 1));
      pane.step(_books, 1); // last chapter: no-op
      expect(c.read(secondaryPaneProvider).reference.bookId, 'EXO');
      pane.step(_books, -1);
      expect(c.read(secondaryPaneProvider).reference, const BibleReference(bookId: 'GEN', chapter: 2));
    });

    test('the pane has its own translation', () async {
      final c = await _container({});
      addTearDown(c.dispose);
      await c.read(secondaryPaneProvider.notifier).setTranslation('web');
      expect(c.read(secondaryPaneProvider).translationId, 'web');
    });
  });

  group('layout', () {
    Future<void> pump(WidgetTester tester, Size size) async {
      SharedPreferences.setMockInitialValues({'split_view_enabled': true});
      final sp = await SharedPreferences.getInstance();
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sp),
            availableTranslationsProvider.overrideWith((ref) async => const []),
            secondaryPaneBooksProvider.overrideWith((ref) async => _books),
            secondaryPaneContentProvider.overrideWith(
              (ref) async => SecondaryPaneContent(
                book: _books.first,
                chapter: const BibleChapter(
                  number: 1,
                  verses: [BibleVerse(number: 1, text: 'In the beginning')],
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: SplitReaderLayout(primary: Text('MAIN'))),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('side by side on a wide screen', (tester) async {
      await pump(tester, const Size(1200, 800));
      expect(find.text('MAIN'), findsOneWidget);
      expect(find.textContaining('In the beginning'), findsOneWidget);
      expect(find.byType(VerticalDivider), findsOneWidget);
    });

    testWidgets('stacked on a phone', (tester) async {
      await pump(tester, const Size(400, 860));
      expect(find.text('MAIN'), findsOneWidget);
      expect(find.textContaining('In the beginning'), findsOneWidget);
      expect(find.byType(VerticalDivider), findsNothing);
    });
  });
}
