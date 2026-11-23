// Issue #46: switching to a translation without the current book left the
// reference bar naming the old book while the reader showed the fallback
// (usually the first book).

import 'package:basic_bible/src/features/library/data/app_bible_repository.dart';
import 'package:basic_bible/src/features/reader/application/view_models/bible_library_view_models.dart';
import 'package:basic_bible/src/features/reader/application/view_models/reader_session_view_models.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/services/shared_preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

BibleBook _book(String id, List<int> chapters) => BibleBook(
  id: id,
  name: id,
  shortName: id,
  bookNumber: 0,
  chapters: [for (final c in chapters) BibleChapter(number: c)],
);

/// Serves translations straight from "memory" so the shell notifier never
/// touches disk: that is the cache-hit path a real switch also takes.
class _InMemoryRepository implements AppBibleRepository {
  _InMemoryRepository(this.byTranslation);

  final Map<String, List<BibleBook>> byTranslation;

  @override
  List<BibleBook>? peekLoadedTranslation(String translationId) =>
      byTranslation[translationId];

  @override
  void activateLoadedTranslation(String translationId) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('readerFallbackReference', () {
    final books = [
      _book('MAT', [1, 2]),
      _book('MRK', [1]),
    ];

    test('null when the reference is displayable', () {
      expect(
        readerFallbackReference(
          books,
          const BibleReference(bookId: 'MAT', chapter: 2),
        ),
        isNull,
      );
    });

    test('missing book falls back to the first book, chapter 1', () {
      expect(
        readerFallbackReference(
          books,
          const BibleReference(bookId: 'GEN', chapter: 3, verse: 4),
        ),
        const BibleReference(bookId: 'MAT', chapter: 1),
      );
    });

    test('missing chapter falls back to the first chapter of that book', () {
      expect(
        readerFallbackReference(
          books,
          const BibleReference(bookId: 'MRK', chapter: 9),
        ),
        const BibleReference(bookId: 'MRK', chapter: 1),
      );
    });

    test('skips leading books without chapters (e.g. front matter)', () {
      expect(
        readerFallbackReference(
          [_book('FRT', []), ...books],
          const BibleReference(bookId: 'GEN', chapter: 1),
        ),
        const BibleReference(bookId: 'MAT', chapter: 1),
      );
    });
  });

  test('switching to a translation without the book updates the reference',
      () async {
    SharedPreferences.setMockInitialValues({
      'bible_translation': 'full',
      'bible_book': 'GEN',
      'bible_chapter': 3,
    });
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        bibleRepositoryProvider.overrideWithValue(
          _InMemoryRepository({
            'full': [
              _book('GEN', [1, 2, 3]),
              _book('MAT', [1]),
            ],
            'nt': [
              _book('MAT', [1, 2]),
            ],
          }),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.listen(bibleBooksShellProvider, (_, _) {});
    await Future<void>.delayed(Duration.zero);

    // Genesis 3 exists in the starting translation: nothing changes.
    expect(
      container.read(currentReferenceProvider),
      const BibleReference(bookId: 'GEN', chapter: 3),
    );

    await container
        .read(currentTranslationProvider.notifier)
        .setTranslation('nt');
    await Future<void>.delayed(Duration.zero);

    expect(
      container.read(currentReferenceProvider),
      const BibleReference(bookId: 'MAT', chapter: 1),
    );
    expect(prefs.getString('bible_book'), 'MAT');
  });
}
