import 'package:basic_bible/src/features/library/data/app_bible_repository.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/utils/reference_utils.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bible_library_view_models.dart';
import 'reader_preferences_view_models.dart';
import 'reader_session_view_models.dart';

/// Most verses a single Bible search returns (#69). Enough for any focused
/// query; a broad one ("the") asks the user to narrow it instead of building
/// a 30,000-row list.
const int kBibleSearchLimit = 500;

enum BibleSearchScope {
  all('Whole Bible'),
  oldTestament('Old Testament'),
  newTestament('New Testament'),
  currentBook('This book'),
  currentChapter('This chapter');

  const BibleSearchScope(this.label);
  final String label;
}

class BibleSearchRequest extends Equatable {
  const BibleSearchRequest({required this.query, required this.scope});

  final String query;
  final BibleSearchScope scope;

  @override
  List<Object?> get props => [query, scope];
}

/// The book/chapter "This book" / "This chapter" refer to: what is on
/// screen. In continuous scroll that is the visible chapter, which can be
/// ahead of the last navigated-to reference.
final searchContextReferenceProvider = Provider<BibleReference>((ref) {
  final current = ref.watch(currentReferenceProvider);
  if (!ref.watch(continuousScrollingProvider)) return current;
  return ref.watch(visibleReaderReferenceProvider) ?? current;
});

/// Book IDs a [scope] covers in [books], or null for no restriction.
Set<String>? bookIdsForSearchScope(
  BibleSearchScope scope,
  List<BibleBook> books, {
  required String currentBookId,
}) {
  return switch (scope) {
    BibleSearchScope.all => null,
    BibleSearchScope.currentBook ||
    BibleSearchScope.currentChapter => {currentBookId},
    BibleSearchScope.oldTestament => {
      for (final book in books)
        if (getBookType(book.id) == BibleBookType.oldTestament) book.id,
    },
    BibleSearchScope.newTestament => {
      for (final book in books)
        if (getBookType(book.id) == BibleBookType.newTestament) book.id,
    },
  };
}

/// Verses of the current translation matching a [BibleSearchRequest].
final bibleSearchResultsProvider = FutureProvider.autoDispose
    .family<List<BibleSearchHit>, BibleSearchRequest>((ref, request) async {
      if (bibleSearchTerms(request.query).isEmpty) return const [];
      final translationId = ref.watch(currentTranslationProvider);
      final repository = ref.watch(bibleRepositoryProvider);
      final books =
          ref.watch(readableBibleBooksProvider).asData?.value ??
          const <BibleBook>[];
      final current = ref.read(searchContextReferenceProvider);
      final bookIds = bookIdsForSearchScope(
        request.scope,
        books,
        currentBookId: current.bookId,
      );
      return repository.searchVerses(
        translationId,
        request.query,
        bookIds: bookIds,
        chapter: request.scope == BibleSearchScope.currentChapter
            ? current.chapter
            : null,
        limit: kBibleSearchLimit,
      );
    });
