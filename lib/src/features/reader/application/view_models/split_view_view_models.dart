import 'package:basic_bible/src/features/library/data/app_bible_repository.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/services/shared_preferences_provider.dart';
import 'package:basic_bible/src/utils/reference_utils.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bible_library_view_models.dart';
import 'reader_session_view_models.dart';

// Split view (#84): a second, independent reading pane beside the main
// reader. The pane has its own translation, book/chapter and scroll position
// so two passages (or two translations) can be read side by side.

const _enabledKey = 'split_view_enabled';
const _translationKey = 'split_view_translation';
const _bookKey = 'split_view_book';
const _chapterKey = 'split_view_chapter';

final splitViewEnabledProvider =
    StateNotifierProvider<SplitViewEnabledNotifier, bool>((ref) {
      return SplitViewEnabledNotifier(ref);
    });

class SplitViewEnabledNotifier extends StateNotifier<bool> {
  SplitViewEnabledNotifier(this._ref)
    : super(_ref.read(sharedPreferencesProvider).getBool(_enabledKey) ?? false);

  final Ref _ref;

  Future<void> toggle() async {
    final enabling = !state;
    // First time the pane opens, start it where the main reader is.
    if (enabling) _ref.read(secondaryPaneProvider.notifier).seedIfUnset();
    state = enabling;
    await _ref.read(sharedPreferencesProvider).setBool(_enabledKey, state);
  }
}

class SecondaryPaneState extends Equatable {
  const SecondaryPaneState({
    required this.translationId,
    required this.reference,
  });

  final String translationId;

  /// Book + chapter only; the pane doesn't track a verse.
  final BibleReference reference;

  @override
  List<Object?> get props => [translationId, reference];
}

final secondaryPaneProvider =
    StateNotifierProvider<SecondaryPaneNotifier, SecondaryPaneState>((ref) {
      return SecondaryPaneNotifier(ref, ref.read(sharedPreferencesProvider));
    });

class SecondaryPaneNotifier extends StateNotifier<SecondaryPaneState> {
  SecondaryPaneNotifier(this._ref, this._prefs)
    : super(
        SecondaryPaneState(
          translationId:
              _prefs.getString(_translationKey) ??
              _ref.read(currentTranslationProvider),
          reference: BibleReference(
            bookId:
                _prefs.getString(_bookKey) ??
                _ref.read(currentReferenceProvider).bookId,
            chapter:
                _prefs.getInt(_chapterKey) ??
                _ref.read(currentReferenceProvider).chapter,
          ),
        ),
      );

  final Ref _ref;
  final SharedPreferences _prefs;

  void seedIfUnset() {
    if (_prefs.containsKey(_bookKey)) return;
    final main = _ref.read(currentReferenceProvider);
    setReference(BibleReference(bookId: main.bookId, chapter: main.chapter));
    setTranslation(_ref.read(currentTranslationProvider));
  }

  Future<void> setReference(BibleReference reference) async {
    state = SecondaryPaneState(
      translationId: state.translationId,
      reference: BibleReference(
        bookId: reference.bookId,
        chapter: reference.chapter,
      ),
    );
    await Future.wait([
      _prefs.setString(_bookKey, reference.bookId),
      _prefs.setInt(_chapterKey, reference.chapter),
    ]);
  }

  Future<void> setTranslation(String translationId) async {
    state = SecondaryPaneState(
      translationId: translationId,
      reference: state.reference,
    );
    await _prefs.setString(_translationKey, translationId);
  }

  /// Next/previous chapter across book boundaries within [books].
  void step(List<BibleBook> books, int direction) {
    final chapters = [
      for (final book in books)
        for (final chapter in book.chapters)
          BibleReference(bookId: book.id, chapter: chapter.number),
    ];
    final book = resolveBookFromReference(books, state.reference.bookId);
    final index = chapters.indexWhere(
      (r) =>
          r.bookId == (book?.id ?? state.reference.bookId) &&
          r.chapter == state.reference.chapter,
    );
    final target = index + direction;
    if (index < 0 || target < 0 || target >= chapters.length) return;
    setReference(chapters[target]);
  }
}

/// Navigable books of the pane's translation (same rules as the main
/// reader: chapterless front matter becomes a readable page, #87).
final secondaryPaneBooksProvider = FutureProvider.autoDispose<List<BibleBook>>((
  ref,
) async {
  final translationId = ref.watch(
    secondaryPaneProvider.select((s) => s.translationId),
  );
  final repository = ref.watch(bibleRepositoryProvider);
  return readableBooks(
    await repository.loadShellWithoutActivating(translationId),
  );
});

/// What the pane shows: the resolved book and its hydrated chapter.
class SecondaryPaneContent {
  const SecondaryPaneContent({required this.book, required this.chapter});

  final BibleBook book;
  final BibleChapter chapter;
}

final secondaryPaneContentProvider =
    FutureProvider.autoDispose<SecondaryPaneContent?>((ref) async {
      final pane = ref.watch(secondaryPaneProvider);
      final books = await ref.watch(secondaryPaneBooksProvider.future);
      if (books.isEmpty) return null;

      // Same fallback as the main reader when a translation lacks the book.
      final book =
          resolveBookFromReference(books, pane.reference.bookId) ??
          books.first;
      final chapter =
          book.chapters
              .where((c) => c.number == pane.reference.chapter)
              .firstOrNull ??
          book.chapters.firstOrNull;
      if (chapter == null) return null;

      final hydrated = chapter.verses.isNotEmpty
          ? chapter
          : await ref
                    .watch(bibleRepositoryProvider)
                    .loadChapterVerses(
                      pane.translationId,
                      book.id,
                      chapter.number,
                    ) ??
                chapter;
      return SecondaryPaneContent(book: book, chapter: hydrated);
    });
