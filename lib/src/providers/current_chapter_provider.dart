import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/providers/bible_provider.dart';

final currentChapterProvider = Provider<AsyncValue<BibleChapter?>>((ref) {
  final booksAsync = ref.watch(bibleBooksProvider);
  final reference = ref.watch(currentReferenceProvider);

  return booksAsync.when(
    data: (books) {
      try {
        final book = books.firstWhere((b) => b.id == reference.bookId);
        final chapter = book.chapters.firstWhere((c) => c.number == reference.chapter);
        return AsyncValue.data(chapter);
      } catch (e) {
        return AsyncValue.error(e, StackTrace.current);
      }
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});
