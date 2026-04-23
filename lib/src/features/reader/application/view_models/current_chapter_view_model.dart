import 'package:basic_bible/src/features/library/data/app_bible_repository.dart';
import 'package:basic_bible/src/features/reader/application/view_models/bible_library_view_models.dart';
import 'package:basic_bible/src/features/reader/application/view_models/reader_session_view_models.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/utils/reference_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Resolves the fully hydrated chapter the reader should currently display.
/// It starts from the faster shell load and only hydrates verses when needed.
final currentChapterProvider = FutureProvider<BibleChapter?>((ref) async {
  final booksAsync = ref.watch(bibleBooksShellProvider);
  final reference = ref.watch(currentReferenceProvider);
  final repository = ref.watch(bibleRepositoryProvider);
  final translation = ref.watch(currentTranslationProvider);

  // Propagate shell errors immediately. While the shell is still loading,
  // return null — the outer build() shows _LoadingView via booksAsync.loading()
  // before it ever evaluates this provider's value, so the null is never
  // rendered as "Chapter not found". This avoids the transient AsyncError state
  // that a throw would create while the shell is initializing.
  if (booksAsync.hasError) throw booksAsync.error!;
  final books = booksAsync.asData?.value;
  if (books == null || books.isEmpty) {
    return null;
  }

  final book = resolveBookFromReference(books, reference.bookId) ?? books.first;
  final matchingChapters = book.chapters.where(
    (c) => c.number == reference.chapter,
  );
  var chapter = matchingChapters.isNotEmpty
      ? matchingChapters.first
      : (book.chapters.isNotEmpty ? book.chapters.first : null);

  if (chapter == null) {
    return null;
  }

  if (chapter.verses.isEmpty) {
    final hydratedChapter = await repository.loadChapterVerses(
      translation,
      book.id,
      chapter.number,
    );
    chapter = hydratedChapter ?? chapter;
  }

  return chapter;
});
