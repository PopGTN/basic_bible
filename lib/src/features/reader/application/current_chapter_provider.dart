import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:basic_bible/src/features/reader/application/bible_provider.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/utils/reference_utils.dart';

/// Load current chapter with verses on demand.
/// Watches the shell provider to get books fast, then hydrates verses when needed.
final currentChapterProvider = FutureProvider<BibleChapter?>((ref) async {
  final booksAsync = ref.watch(bibleBooksShellProvider);
  final reference = ref.watch(currentReferenceProvider);
  final repository = ref.watch(bibleRepositoryProvider);
  final translation = ref.watch(currentTranslationProvider);

  // Wait for shell to load books/chapters
  final books = await booksAsync.when(
    data: (data) async => data,
    loading: () async => throw Exception('Books still loading'),
    error: (e, st) async => throw e,
  );

  if (books.isEmpty) {
    return null;
  }

  final book =
      resolveBookFromReference(books, reference.bookId) ?? books.first;
  final matchingChapters = book.chapters.where(
    (c) => c.number == reference.chapter,
  );
  var chapter = matchingChapters.isNotEmpty
      ? matchingChapters.first
      : (book.chapters.isNotEmpty ? book.chapters.first : null);

  if (chapter == null) {
    return null;
  }

  // If chapter has no verses (shell loading), hydrate them on demand
  if (chapter.verses.isEmpty) {
    final hydratedChapter =
        await repository.loadChapterVerses(translation, book.id, chapter.number);
    chapter = hydratedChapter ?? chapter;
  }

  return chapter;
});
