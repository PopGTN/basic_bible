import '../models/hymn.dart';
import '../models/hymn_search_index.dart';
import '../models/hymnal.dart';

enum HymnSortOrder { number, alphabetical }

/// A parsed search box value.
///
/// - All digits ("23") → hymn-number lookup.
/// - `"quoted phrases"` must appear word-for-word in the title or lyrics.
/// - Every other word must match somewhere (title, first line, author,
///   lyrics, meter/tune), as a word prefix: "lam" finds "Lamb".
class HymnSearchQuery {
  HymnSearchQuery._(this.raw, this.number, this.phrases, this.terms);

  factory HymnSearchQuery.parse(String raw) {
    final trimmed = raw.trim();
    if (RegExp(r'^#?\d+$').hasMatch(trimmed)) {
      return HymnSearchQuery._(
        raw,
        trimmed.replaceFirst('#', ''),
        const [],
        const [],
      );
    }
    final phrases = <String>[];
    final rest = trimmed.replaceAllMapped(RegExp(r'["“”]([^"“”]+)["“”]'), (m) {
      final phrase = normalizeHymnText(m.group(1)!);
      if (phrase.isNotEmpty) phrases.add(phrase);
      return ' ';
    });
    final terms = normalizeHymnText(
      rest,
    ).split(' ').where((term) => term.isNotEmpty).toList();
    return HymnSearchQuery._(raw, null, phrases, terms);
  }

  final String raw;

  /// Digits only, when the query is a hymn number.
  final String? number;
  final List<String> phrases;
  final List<String> terms;

  bool get isEmpty => number == null && phrases.isEmpty && terms.isEmpty;

  /// The whole query as one phrase, used to boost hymns that contain the
  /// words together and in order ("lamb of god").
  String get joinedTerms => terms.join(' ');
}

const _titleWeight = 3.5;
const _firstLineWeight = 2.5;
const _authorWeight = 1.4;
const _lyricsWeight = 1.0;
const _metaWeight = 0.6;

/// Filters and orders [hymnal] for the list view.
///
/// Empty query: every hymn (optionally only [favorites]) in [sort] order.
/// Otherwise: best matches first, ties broken by hymn number. A linear scan
/// over pre-normalized strings — well under 5 ms for the largest books, so
/// it runs synchronously on every keystroke.
List<Hymn> searchHymnal(
  Hymnal hymnal,
  String rawQuery, {
  HymnSortOrder sort = HymnSortOrder.number,
  Set<int>? favorites,
}) {
  final query = HymnSearchQuery.parse(rawQuery);
  final entries = hymnal.index.entries;
  final hymns = hymnal.hymns;
  bool allowed(int i) =>
      favorites == null || favorites.contains(entries[i].number);

  if (query.isEmpty) {
    final result = <int>[
      for (var i = 0; i < hymns.length; i++)
        if (allowed(i)) i,
    ];
    if (sort == HymnSortOrder.alphabetical) {
      result.sort((a, b) {
        final byTitle = entries[a].sortKey.compareTo(entries[b].sortKey);
        return byTitle != 0 ? byTitle : entries[a].number - entries[b].number;
      });
    }
    return [for (final i in result) hymns[i]];
  }

  final scored = <({int index, double score})>[];
  for (var i = 0; i < entries.length; i++) {
    if (!allowed(i)) continue;
    final score = scoreHymnEntry(entries[i], query);
    if (score > 0) scored.add((index: i, score: score));
  }
  scored.sort((a, b) {
    final byScore = b.score.compareTo(a.score);
    return byScore != 0
        ? byScore
        : entries[a.index].number - entries[b.index].number;
  });
  return [for (final hit in scored) hymns[hit.index]];
}

/// 0 means "not a match". Exposed for tests.
double scoreHymnEntry(HymnSearchEntry entry, HymnSearchQuery query) {
  final number = query.number;
  if (number != null) {
    if (entry.numberText == number) return 1000;
    if (entry.numberText.startsWith(number)) {
      // 1 → 10..19 before 100..199.
      return 100.0 - entry.numberText.length;
    }
    return 0;
  }

  var score = 0.0;
  for (final phrase in query.phrases) {
    final inTitle =
        entry.title.contains(' $phrase') ||
        entry.firstLine.contains(' $phrase');
    final inLyrics = entry.lyrics.contains(' $phrase');
    if (!inTitle && !inLyrics) return 0;
    score += inTitle ? 12 : 6;
  }

  for (final term in query.terms) {
    final termScore = _termScore(entry, term);
    if (termScore == 0) return 0;
    score += termScore;
  }

  if (query.terms.length > 1) {
    final phrase = query.joinedTerms;
    if (entry.title.contains(' $phrase') ||
        entry.firstLine.contains(' $phrase')) {
      score += 12;
    } else if (entry.lyrics.contains(' $phrase')) {
      score += 6;
    }
  }
  if (query.terms.isNotEmpty &&
      (entry.title.startsWith(' ${query.joinedTerms}') ||
          entry.firstLine.startsWith(' ${query.joinedTerms}'))) {
    score += 8;
  }
  return score;
}

double _termScore(HymnSearchEntry entry, String term) {
  double field(String text, double weight) {
    if (!text.contains(' $term')) return 0;
    // Whole word beats prefix: "lamb" ranks "Lamb" above "Lambs".
    return text.contains(' $term ') ? weight * 1.25 : weight;
  }

  var best = 0.0;
  for (final value in [
    field(entry.title, _titleWeight),
    field(entry.firstLine, _firstLineWeight),
    field(entry.author, _authorWeight),
    field(entry.lyrics, _lyricsWeight),
    field(entry.meta, _metaWeight),
  ]) {
    if (value > best) best = value;
  }
  if (best > 0) return best;

  // Mid-word fallback for longer fragments ("vary" → "Calvary").
  if (term.length >= 3) {
    if (entry.title.contains(term)) return 2.0;
    if (entry.lyrics.contains(term) || entry.author.contains(term)) return 0.8;
  }
  return 0;
}
