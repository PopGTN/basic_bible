import 'package:equatable/equatable.dart';

import 'bible_reference.dart';
import 'bible_structure.dart';

/// One verse matching a Bible text search (#69).
class BibleSearchHit extends Equatable {
  const BibleSearchHit({
    required this.bookId,
    required this.chapter,
    required this.verse,
    required this.text,
  });

  final String bookId;
  final int chapter;
  final int verse;
  final String text;

  BibleReference get reference =>
      BibleReference(bookId: bookId, chapter: chapter, verse: verse);

  @override
  List<Object?> get props => [bookId, chapter, verse, text];
}

/// Splits a search box entry into lower-cased terms; a verse must contain all
/// of them (in any order). Surrounding punctuation is ignored so "love," and
/// "love" behave the same.
List<String> bibleSearchTerms(String query) => [
  for (final raw in query.toLowerCase().split(RegExp(r'\s+')))
    if (raw.replaceAll(RegExp(r'^[^\w]+|[^\w]+$'), '') case final term
        when term.isNotEmpty)
      term,
];

bool verseMatchesTerms(String text, List<String> terms) {
  if (terms.isEmpty) return false;
  final lower = text.toLowerCase();
  return terms.every(lower.contains);
}

/// In-memory search over fully loaded [books] (used for session-only
/// translations, which have no database). Same semantics and order as the
/// database search: canonical book order, then chapter, then verse.
List<BibleSearchHit> searchBooksInMemory(
  List<BibleBook> books,
  List<String> terms, {
  Set<String>? bookIds,
  int limit = 500,
}) {
  final hits = <BibleSearchHit>[];
  if (terms.isEmpty) return hits;
  for (final book in books) {
    if (bookIds != null && !bookIds.contains(book.id)) continue;
    for (final chapter in book.chapters) {
      for (final verse in chapter.verses) {
        if (!verseMatchesTerms(verse.text, terms)) continue;
        hits.add(
          BibleSearchHit(
            bookId: book.id,
            chapter: chapter.number,
            verse: verse.number,
            text: verse.text,
          ),
        );
        if (hits.length >= limit) return hits;
      }
    }
  }
  return hits;
}
