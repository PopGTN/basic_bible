import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:basic_bible/src/features/reader/application/bible_provider.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/utils/reference_utils.dart';

final currentChapterProvider = Provider<AsyncValue<BibleChapter?>>((ref) {
  final booksAsync = ref.watch(bibleBooksProvider);
  final reference = ref.watch(currentReferenceProvider);

  return booksAsync.when(
    data: (books) {
      if (books.isEmpty) {
        return const AsyncValue.data(null);
      }

      final book =
          resolveBookFromReference(books, reference.bookId) ?? books.first;
      final matchingChapters = book.chapters.where(
        (c) => c.number == reference.chapter,
      );
      final chapter = matchingChapters.isNotEmpty
          ? matchingChapters.first
          : (book.chapters.isNotEmpty ? book.chapters.first : null);

      return AsyncValue.data(chapter);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});
