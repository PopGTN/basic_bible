import 'package:basic_bible/src/features/reader/application/continuous_reader_controller.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:flutter_test/flutter_test.dart';

BibleVerse verse(int number) => BibleVerse(number: number, text: 'Verse $number');

BibleChapter shellChapter(int number) => BibleChapter(number: number);

BibleChapter hydratedChapter(int number) =>
    BibleChapter(number: number, verses: [verse(1), verse(2)]);

BibleBook book(String id, int chapterCount, {int bookNumber = 1}) => BibleBook(
  id: id,
  name: 'Book $id',
  shortName: id,
  bookNumber: bookNumber,
  chapters: [for (var i = 1; i <= chapterCount; i++) shellChapter(i)],
);

void main() {
  late List<String> loadedKeys;

  /// Controller with a synchronous defer (tests don't have frames) and a
  /// loader that records calls and returns a hydrated two-verse chapter.
  ContinuousReaderController controller({
    int maxHydrated = 48,
    Future<BibleChapter?> Function(String bookId, int chapterNumber)? loader,
  }) {
    return ContinuousReaderController(
      loadChapter: loader ??
          (bookId, chapterNumber) async {
            loadedKeys.add('$bookId:$chapterNumber');
            return hydratedChapter(chapterNumber);
          },
      maxHydratedChapters: maxHydrated,
      deferNotify: (callback) => callback(),
    );
  }

  setUp(() {
    loadedKeys = [];
  });

  group('sections', () {
    test('rebuildSections flattens books into chapter order', () {
      final c = controller();
      c.rebuildSections([book('GEN', 3), book('EXO', 2, bookNumber: 2)]);

      expect(c.sections, hasLength(5));
      expect(c.sections.first.book.id, 'GEN');
      expect(c.sections.first.chapter.number, 1);
      expect(c.sections[3].book.id, 'EXO');
      expect(c.sections[3].chapter.number, 1);
      expect(c.sections.last.chapter.number, 2);
    });

    test('sectionIndexFor finds chapters and rejects unknown references', () {
      final c = controller();
      c.rebuildSections([book('GEN', 3), book('EXO', 2)]);

      expect(
        c.sectionIndexFor(const BibleReference(bookId: 'GEN', chapter: 2)),
        1,
      );
      expect(
        c.sectionIndexFor(const BibleReference(bookId: 'EXO', chapter: 1)),
        3,
      );
      expect(
        c.sectionIndexFor(const BibleReference(bookId: 'REV', chapter: 1)),
        isNull,
      );
      expect(
        c.sectionIndexFor(const BibleReference(bookId: 'GEN', chapter: 99)),
        isNull,
      );
    });
  });

  group('hydration', () {
    test('chapterFuture memoizes: one load per chapter', () async {
      final c = controller();
      c.rebuildSections([book('GEN', 3)]);
      final section = c.sections.first;

      final first = c.chapterFuture(section);
      final second = c.chapterFuture(section);
      expect(identical(first, second), isTrue);

      await first;
      c.chapterFuture(section);
      expect(loadedKeys, ['GEN:1']);
    });

    test('completed load stores the chapter and notifies listeners', () async {
      final c = controller();
      c.rebuildSections([book('GEN', 3)]);
      var notified = 0;
      c.addListener(() => notified++);

      expect(c.hydratedChapter('GEN', 1), isNull);
      await c.chapterFuture(c.sections.first);

      final stored = c.hydratedChapter('GEN', 1);
      expect(stored, isNotNull);
      expect(stored!.verses, hasLength(2));
      expect(notified, 1);
    });

    test('onChapterHydrated fires with the chapter identity', () async {
      final c = controller();
      c.rebuildSections([book('GEN', 3)]);
      final hydrations = <String>[];
      c.onChapterHydrated = (bookId, chapterNumber) =>
          hydrations.add('$bookId:$chapterNumber');

      await c.chapterFuture(c.sections[1]);
      expect(hydrations, ['GEN:2']);
    });

    test('null loader result falls back to the shell chapter unstored',
        () async {
      final c = controller(loader: (_, _) async => null);
      c.rebuildSections([book('GEN', 1)]);
      var notified = 0;
      c.addListener(() => notified++);

      final resolved = await c.chapterFuture(c.sections.first);

      // Shell chapter has no verses, so nothing is cached and no one is
      // notified — the FutureBuilder just renders the fallback.
      expect(resolved, same(c.sections.first.chapter));
      expect(c.hydratedChapter('GEN', 1), isNull);
      expect(notified, 0);
    });
  });

  group('LRU eviction', () {
    test('evicts the oldest chapter and its future beyond the cap', () async {
      final c = controller(maxHydrated: 2);
      c.rebuildSections([book('GEN', 4)]);

      for (final section in c.sections.take(3)) {
        await c.chapterFuture(section);
      }

      expect(c.hydratedChapterCount, 2);
      expect(c.hydratedChapter('GEN', 1), isNull); // oldest, evicted
      expect(c.hydratedChapter('GEN', 2), isNotNull);
      expect(c.hydratedChapter('GEN', 3), isNotNull);

      // The evicted chapter's future is gone too: requesting it re-loads.
      loadedKeys.clear();
      await c.chapterFuture(c.sections.first);
      expect(loadedKeys, ['GEN:1']);
    });

    test('reading a chapter refreshes its recency and protects it', () async {
      final c = controller(maxHydrated: 2);
      c.rebuildSections([book('GEN', 4)]);

      await c.chapterFuture(c.sections[0]);
      await c.chapterFuture(c.sections[1]);
      // Touch chapter 1 so chapter 2 becomes the least recently used.
      expect(c.hydratedChapter('GEN', 1), isNotNull);
      await c.chapterFuture(c.sections[2]);

      expect(c.hydratedChapter('GEN', 1), isNotNull); // protected by touch
      expect(c.hydratedChapter('GEN', 2), isNull); // evicted instead
      expect(c.hydratedChapter('GEN', 3), isNotNull);
    });
  });

  group('prefetch', () {
    test('prefetchWindow loads ±radius chapters around the reference',
        () async {
      final c = controller();
      c.rebuildSections([book('GEN', 10)]);

      c.prefetchWindow(
        const BibleReference(bookId: 'GEN', chapter: 5),
        radius: 2,
      );
      await Future<void>.delayed(Duration.zero);

      expect(loadedKeys, ['GEN:3', 'GEN:4', 'GEN:5', 'GEN:6', 'GEN:7']);
    });

    test('prefetchWindow clamps at the edges of the Bible', () async {
      final c = controller();
      c.rebuildSections([book('GEN', 4)]);

      c.prefetchWindow(
        const BibleReference(bookId: 'GEN', chapter: 1),
        radius: 2,
      );
      await Future<void>.delayed(Duration.zero);

      expect(loadedKeys, ['GEN:1', 'GEN:2', 'GEN:3']);
    });

    test('prefetchWindow ignores references outside the section list', () {
      final c = controller();
      c.rebuildSections([book('GEN', 4)]);

      c.prefetchWindow(const BibleReference(bookId: 'REV', chapter: 1));
      expect(loadedKeys, isEmpty);
    });
  });

  test('reset drops hydrated chapters and futures', () async {
    final c = controller();
    c.rebuildSections([book('GEN', 2)]);
    await c.chapterFuture(c.sections.first);
    expect(c.hydratedChapter('GEN', 1), isNotNull);

    c.reset();

    expect(c.hydratedChapter('GEN', 1), isNull);
    loadedKeys.clear();
    await c.chapterFuture(c.sections.first);
    expect(loadedKeys, ['GEN:1']); // future was cleared, so it re-loads
  });

  test('no notifications are delivered after dispose', () async {
    // Deferred callbacks capture the controller; if it's disposed before the
    // "frame" fires, they must be dropped instead of notifying.
    void Function()? pendingFrame;
    final c = ContinuousReaderController(
      loadChapter: (_, _) async => hydratedChapter(1),
      deferNotify: (callback) => pendingFrame = callback,
    );
    c.rebuildSections([book('GEN', 1)]);
    var notified = 0;
    c.addListener(() => notified++);

    await c.chapterFuture(c.sections.first);
    c.dispose();
    pendingFrame?.call();

    expect(notified, 0);
  });
}
