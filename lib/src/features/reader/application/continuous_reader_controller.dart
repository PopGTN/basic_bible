import 'package:basic_bible/src/models/bible_models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// One slot in the flat chapter stream rendered by continuous mode.
/// [chapter] is the shell chapter (metadata, usually no verses); the hydrated
/// chapter with verses comes from [ContinuousReaderController.chapterFuture].
class ContinuousChapterSection {
  const ContinuousChapterSection({required this.book, required this.chapter});

  final BibleBook book;
  final BibleChapter chapter;
}

/// Loads the verses for one chapter. Returns null when the chapter could not
/// be hydrated (the shell chapter is used as a fallback).
typedef ChapterLoader =
    Future<BibleChapter?> Function(String bookId, int chapterNumber);

/// Owns all continuous-reader state that is not tied to the widget tree:
/// the flat section list, the memoized per-chapter hydration futures, the
/// LRU cache of hydrated chapters, and the prefetch policy.
///
/// Extracted from `_BibleTextViewState` so this logic is unit-testable
/// without pumping widgets.
///
/// It deliberately does not notify the reader when a chapter loads: each
/// chapter's FutureBuilder already rebuilds just that chapter, and rebuilding
/// the whole reader on every load re-rendered every visible chapter up to a
/// dozen times per jump.
class ContinuousReaderController {
  ContinuousReaderController({
    required ChapterLoader loadChapter,
    this.maxHydratedChapters = 48,
    void Function(VoidCallback)? deferNotify,
  }) : _loadChapter = loadChapter,
       _deferNotify = deferNotify ?? _postFrameDefer;

  static void _postFrameDefer(VoidCallback callback) {
    SchedulerBinding.instance.addPostFrameCallback((_) => callback());
  }

  final ChapterLoader _loadChapter;

  /// How [onChapterHydrated] is scheduled. Defaults to the next frame because
  /// chapter futures can complete while ScrollablePositionedList is
  /// mid-layout; tests inject their own.
  final void Function(VoidCallback) _deferNotify;

  /// Upper bound on chapters kept hydrated in memory. Big enough that the
  /// prefetch window plus everything near the viewport stays cached, small
  /// enough that reading straight through the Bible doesn't accumulate all
  /// 1,189 chapters.
  final int maxHydratedChapters;

  /// Called (deferred to the next frame) whenever a chapter's verses arrive.
  /// The reader uses this to retry verse-level focus for deep links that
  /// landed before the target chapter was hydrated.
  void Function(String bookId, int chapterNumber)? onChapterHydrated;

  List<ContinuousChapterSection> _sections = const [];
  final Map<String, Future<BibleChapter?>> _chapterFutures = {};
  // Insertion-ordered map used as an LRU: oldest entries first.
  final Map<String, BibleChapter> _hydratedChapters = {};
  bool _disposed = false;

  List<ContinuousChapterSection> get sections => _sections;

  @visibleForTesting
  int get hydratedChapterCount => _hydratedChapters.length;

  String _chapterKey(String bookId, int chapterNumber) =>
      '$bookId:$chapterNumber';

  /// Flattens [books] into the chapter stream so the viewport can reason
  /// about "which chapter is visible now?" without walking the nested book
  /// structure every time.
  void rebuildSections(List<BibleBook> books) {
    _sections = <ContinuousChapterSection>[
      for (final book in books)
        for (final chapter in book.chapters)
          ContinuousChapterSection(book: book, chapter: chapter),
    ];
  }

  /// Drops all hydrated chapters and in-flight futures. Call when the
  /// translation (or the underlying book list) changes.
  void reset() {
    _chapterFutures.clear();
    _hydratedChapters.clear();
  }

  int? sectionIndexFor(BibleReference reference) {
    final index = _sections.indexWhere(
      (section) =>
          section.book.id == reference.bookId &&
          section.chapter.number == reference.chapter,
    );
    return index >= 0 ? index : null;
  }

  /// Hydrated chapter for [bookId]:[chapterNumber], or null if not loaded.
  /// Reading counts as a use, so chapters still being rendered aren't evicted.
  BibleChapter? hydratedChapter(String bookId, int chapterNumber) {
    final key = _chapterKey(bookId, chapterNumber);
    final chapter = _hydratedChapters.remove(key);
    if (chapter == null) return null;
    _hydratedChapters[key] = chapter;
    return chapter;
  }

  /// Memoized hydration future for [section]. The first call starts the load;
  /// subsequent calls (rebuilds, prefetch overlap) return the same future.
  Future<BibleChapter?> chapterFuture(ContinuousChapterSection section) {
    final key = _chapterKey(section.book.id, section.chapter.number);
    return _chapterFutures.putIfAbsent(key, () async {
      final hydrated = await _loadChapter(
        section.book.id,
        section.chapter.number,
      );
      final resolved = hydrated ?? section.chapter;
      if (resolved.verses.isNotEmpty) {
        _storeHydratedChapter(key, resolved);
        final callback = onChapterHydrated;
        if (callback != null) {
          _deferNotify(() {
            if (!_disposed) {
              callback(section.book.id, section.chapter.number);
            }
          });
        }
      }
      return resolved;
    });
  }

  /// Starts hydration for the chapters within [radius] sections of
  /// [reference] so they are ready before the user scrolls to them.
  void prefetchWindow(BibleReference reference, {int radius = 2}) {
    final centerIndex = sectionIndexFor(reference);
    if (centerIndex == null) return;
    prefetchRange(centerIndex - radius, centerIndex + radius);
  }

  /// Starts hydration for sections [first]..[last]; the part of the range
  /// outside the list is ignored (so the range may be empty).
  void prefetchRange(int first, int last) {
    final end = last < _sections.length ? last : _sections.length - 1;
    for (var index = first < 0 ? 0 : first; index <= end; index++) {
      chapterFuture(_sections[index]);
    }
  }

  void _storeHydratedChapter(String key, BibleChapter chapter) {
    // Remove-then-insert keeps the map ordered least→most recently used.
    _hydratedChapters.remove(key);
    _hydratedChapters[key] = chapter;
    while (_hydratedChapters.length > maxHydratedChapters) {
      final oldestKey = _hydratedChapters.keys.first;
      _hydratedChapters.remove(oldestKey);
      // The memoized future holds the same chapter data, so it must be
      // evicted too or the memory is never actually released.
      _chapterFutures.remove(oldestKey);
    }
  }

  void dispose() {
    _disposed = true;
  }
}
