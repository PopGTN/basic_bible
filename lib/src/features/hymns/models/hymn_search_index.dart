import 'hymn.dart';

/// Lowercases, folds Latin diacritics (for the Spanish books), drops
/// apostrophes ("o'er" → "oer", "'Tis" → "tis") and turns every other
/// non-letter/digit into a single space. Non-Latin scripts (e.g. Tamil) keep
/// their letters, so they stay searchable.
String normalizeHymnText(String input) {
  if (input.isEmpty) return '';
  final buffer = StringBuffer();
  var pendingSpace = false;
  for (final rune in input.toLowerCase().runes) {
    final char = String.fromCharCode(rune);
    if (_apostrophes.contains(char)) continue;
    final folded = _fold[char] ?? char;
    if (_wordChar.hasMatch(folded)) {
      if (pendingSpace && buffer.isNotEmpty) buffer.write(' ');
      pendingSpace = false;
      buffer.write(folded);
    } else {
      pendingSpace = true;
    }
  }
  return buffer.toString();
}

const _apostrophes = {"'", '’', '‘', 'ʼ', '`'};
final _wordChar = RegExp(r'[\p{L}\p{N}\p{M}]', unicode: true);
const _fold = <String, String>{
  'á': 'a',
  'à': 'a',
  'â': 'a',
  'ä': 'a',
  'ã': 'a',
  'å': 'a',
  'ā': 'a',
  'é': 'e',
  'è': 'e',
  'ê': 'e',
  'ë': 'e',
  'ē': 'e',
  'í': 'i',
  'ì': 'i',
  'î': 'i',
  'ï': 'i',
  'ó': 'o',
  'ò': 'o',
  'ô': 'o',
  'ö': 'o',
  'õ': 'o',
  'ø': 'o',
  'ú': 'u',
  'ù': 'u',
  'û': 'u',
  'ü': 'u',
  'ñ': 'n',
  'ç': 'c',
  'ý': 'y',
  'ÿ': 'y',
  'æ': 'ae',
  'œ': 'oe',
  'ß': 'ss',
};

/// Precomputed, normalized search fields for one hymn. Each field is wrapped
/// in single spaces (" word word ") so word-prefix and whole-word checks are
/// plain `contains(' term')` / `contains(' term ')` calls — no regex or
/// tokenising on the keystroke path.
class HymnSearchEntry {
  HymnSearchEntry(Hymn hymn)
    : number = hymn.number,
      numberText = '${hymn.number}',
      title = _wrap(normalizeHymnText(hymn.title)),
      firstLine = _wrap(normalizeHymnText(hymn.firstLine)),
      author = _wrap(normalizeHymnText(hymn.author)),
      meta = _wrap(normalizeHymnText('${hymn.meter} ${hymn.tuneName}')),
      lyrics = _wrap(
        normalizeHymnText(
          [
            for (final verse in hymn.verses) ...verse,
            ...hymn.chorus,
            for (final part in hymn.optionalVerses) ...part.lines,
            for (final part in hymn.alternateChoruses) ...part.lines,
          ].join(' '),
        ),
      ),
      sortKey = normalizeHymnText(hymn.title);

  final int number;
  final String numberText;
  final String title;
  final String firstLine;
  final String author;
  final String meta;
  final String lyrics;

  /// Title without punctuation, for A–Z sorting ("'Tis" sorts under T).
  final String sortKey;

  static String _wrap(String text) => text.isEmpty ? ' ' : ' $text ';
}

/// The search index for one book, in the same order as `Hymnal.hymns`.
class HymnSearchIndex {
  HymnSearchIndex(List<Hymn> hymns)
    : entries = [for (final hymn in hymns) HymnSearchEntry(hymn)];

  final List<HymnSearchEntry> entries;
}
