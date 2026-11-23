import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/services/shared_preferences_provider.dart';
import 'package:basic_bible/src/utils/reference_utils.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

final currentTranslationProvider =
    StateNotifierProvider<TranslationNotifier, String>((ref) {
      return TranslationNotifier(ref.read(sharedPreferencesProvider));
    });

final currentReferenceProvider =
    StateNotifierProvider<ReferenceNotifier, BibleReference>((ref) {
      return ReferenceNotifier(ref.read(sharedPreferencesProvider));
    });

final visibleReaderReferenceProvider = StateProvider<BibleReference?>(
  (ref) => null,
);

class TranslationNotifier extends StateNotifier<String> {
  TranslationNotifier(this._prefs)
    // KJV remains the built-in default translation so the app has a guaranteed
    // local Bible available on first launch even before any remote catalog or
    // downloads are configured.
    : super(_prefs.getString('bible_translation') ?? 'kjv');

  final SharedPreferences _prefs;

  Future<void> setTranslation(
    String translationId, {
    bool persist = true,
  }) async {
    state = translationId;
    if (persist) {
      await _prefs.setString('bible_translation', translationId);
    }
  }
}

/// Returns the reference the reader will actually show for [reference] in
/// [books], or null when [reference] is already displayable as-is.
///
/// The reader falls back to the first book (and the first chapter) when a
/// translation lacks the requested book/chapter — e.g. switching to an
/// NT-only translation while in Genesis. Without writing that fallback back
/// into [currentReferenceProvider], the reference bar kept naming the old
/// book while the page showed another (issue #46).
BibleReference? readerFallbackReference(
  List<BibleBook> books,
  BibleReference reference,
) {
  if (books.isEmpty) return null;

  final resolvedBook = resolveBookFromReference(books, reference.bookId);
  final book =
      resolvedBook ??
      books.firstWhere(
        (candidate) => candidate.chapters.isNotEmpty,
        orElse: () => books.first,
      );
  final hasChapter = book.chapters.any((c) => c.number == reference.chapter);
  if (resolvedBook != null && hasChapter) return null;
  if (book.chapters.isEmpty) return null;

  return BibleReference(
    bookId: book.id,
    chapter: hasChapter ? reference.chapter : book.chapters.first.number,
  );
}

/// ViewModel for the reader's current translation and location.
class ReferenceNotifier extends StateNotifier<BibleReference> {
  ReferenceNotifier(this._prefs)
    : super(
        BibleReference(
          bookId: _prefs.getString('bible_book') ?? 'GEN',
          chapter: _prefs.getInt('bible_chapter') ?? 1,
          verse: _prefs.getInt('bible_verse'),
        ),
      );

  final SharedPreferences _prefs;

  /// A verse the user just navigated to and has not been shown yet.
  ///
  /// The reader emphasises (dims around, scrolls to) a target verse only in
  /// response to that navigation. It used to infer this from `state.verse`,
  /// which is persisted and survives leaving the Bible tab, so the old verse
  /// was re-emphasised on every return and after every restart (issue #22).
  /// References restored from preferences therefore never carry a request.
  BibleReference? _pendingVerseFocus;

  /// Returns true exactly once for [reference] after it was set with
  /// `focusVerse: true`; false otherwise (e.g. returning to the tab).
  bool takeVerseFocusRequest(BibleReference reference) {
    if (_pendingVerseFocus == null || _pendingVerseFocus != reference) {
      return false;
    }
    _pendingVerseFocus = null;
    return true;
  }

  /// Moves the reader to [reference]. When it names a verse, the reader will
  /// emphasise that verse once; pass `focusVerse: false` for bookkeeping
  /// updates that only re-anchor the position (layout/translation switches).
  Future<void> setReference(
    BibleReference reference, {
    bool focusVerse = true,
  }) async {
    _pendingVerseFocus = focusVerse && reference.verse != null
        ? reference
        : null;
    // Update in-memory state first so Riverpod listeners (and the reader's
    // didUpdateWidget) see the new reference immediately — in the same
    // event-loop turn as this call. SharedPreferences writes are persistence
    // only; the UI must not wait for disk I/O before navigating.
    state = reference;
    // Persist all three fields in parallel rather than sequentially.
    await Future.wait<bool>([
      _prefs.setString('bible_book', reference.bookId),
      _prefs.setInt('bible_chapter', reference.chapter),
      reference.verse != null
          ? _prefs.setInt('bible_verse', reference.verse!)
          : _prefs.remove('bible_verse'),
    ]);
  }

  void goToNextChapter(List<BibleBook> books) {
    if (books.isEmpty) return;
    final currentBook =
        resolveBookFromReference(books, state.bookId) ?? books.first;
    final currentChapterIndex = currentBook.chapters.indexWhere(
      (c) => c.number == state.chapter,
    );

    if (currentChapterIndex < currentBook.chapters.length - 1) {
      final nextChapter = currentBook.chapters[currentChapterIndex + 1];
      setReference(
        BibleReference(bookId: currentBook.id, chapter: nextChapter.number),
      );
    } else {
      final currentBookIndex = books.indexWhere((b) => b.id == currentBook.id);
      if (currentBookIndex < books.length - 1) {
        final nextBook = books[currentBookIndex + 1];
        if (nextBook.chapters.isNotEmpty) {
          setReference(
            BibleReference(
              bookId: nextBook.id,
              chapter: nextBook.chapters.first.number,
            ),
          );
        }
      }
    }
  }

  void goToPreviousChapter(List<BibleBook> books) {
    if (books.isEmpty) return;
    final currentBook =
        resolveBookFromReference(books, state.bookId) ?? books.first;
    final currentChapterIndex = currentBook.chapters.indexWhere(
      (c) => c.number == state.chapter,
    );

    if (currentChapterIndex > 0) {
      final prevChapter = currentBook.chapters[currentChapterIndex - 1];
      setReference(
        BibleReference(bookId: currentBook.id, chapter: prevChapter.number),
      );
    } else {
      final currentBookIndex = books.indexWhere((b) => b.id == currentBook.id);
      if (currentBookIndex > 0) {
        final prevBook = books[currentBookIndex - 1];
        if (prevBook.chapters.isNotEmpty) {
          setReference(
            BibleReference(
              bookId: prevBook.id,
              chapter: prevBook.chapters.last.number,
            ),
          );
        }
      }
    }
  }
}
