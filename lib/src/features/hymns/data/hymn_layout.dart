import '../models/hymn.dart';
import '../models/hymnal.dart';

/// Where the chorus appears. Printed books show it once after verse 1;
/// when leading singing it helps to see it after every verse.
enum ChorusPlacement { afterFirstVerse, afterEveryVerse }

enum HymnBlockKind { verse, chorus, optionalVerse, alternateChorus }

/// One displayed block of lines. [verseNumber] is set for verses; [label]
/// for optional/alternate parts (null label on an alternate chorus means a
/// plain "optional chorus").
class HymnBlock {
  const HymnBlock({
    required this.kind,
    required this.lines,
    this.verseNumber,
    this.label,
  });

  final HymnBlockKind kind;
  final List<String> lines;
  final int? verseNumber;
  final String? label;

  bool get isOptional =>
      kind == HymnBlockKind.optionalVerse ||
      kind == HymnBlockKind.alternateChorus;
}

/// The single place chorus placement is decided, so the screen, copy, share
/// and print always agree.
List<HymnBlock> layoutHymn(
  Hymn hymn, {
  ChorusPlacement placement = ChorusPlacement.afterFirstVerse,
  bool includeOptional = true,
}) {
  final blocks = <HymnBlock>[];
  final chorus = HymnBlock(kind: HymnBlockKind.chorus, lines: hymn.chorus);
  for (var i = 0; i < hymn.verses.length; i++) {
    blocks.add(
      HymnBlock(
        kind: HymnBlockKind.verse,
        lines: hymn.verses[i],
        verseNumber: i + 1,
      ),
    );
    if (hymn.hasChorus &&
        (i == 0 || placement == ChorusPlacement.afterEveryVerse)) {
      blocks.add(chorus);
    }
  }
  if (hymn.verses.isEmpty && hymn.hasChorus) blocks.add(chorus);
  if (includeOptional) {
    for (final part in hymn.optionalVerses) {
      blocks.add(
        HymnBlock(
          kind: HymnBlockKind.optionalVerse,
          lines: part.lines,
          label: part.label,
        ),
      );
    }
    for (final part in hymn.alternateChoruses) {
      blocks.add(
        HymnBlock(
          kind: HymnBlockKind.alternateChorus,
          lines: part.lines,
          label: part.label,
        ),
      );
    }
  }
  return blocks;
}

/// Labels used in plain-text output. The screen uses localized strings;
/// these English defaults are overridden by the caller when available.
class HymnTextLabels {
  const HymnTextLabels({
    this.chorus = 'Chorus',
    this.optionalChorus = 'Optional chorus',
    this.optionalVerse = 'Optional verse',
  });

  final String chorus;
  final String optionalChorus;
  final String optionalVerse;
}

/// Plain text for copy and share. Always ends with the book's and the
/// hymn's credit lines — copyrighted text must never travel without them.
String formatHymnAsText(
  Hymn hymn,
  HymnalInfo book, {
  ChorusPlacement placement = ChorusPlacement.afterFirstVerse,
  HymnTextLabels labels = const HymnTextLabels(),
}) {
  final out = StringBuffer('${hymn.number}. ${hymn.title}\n');
  final details = [
    if (hymn.author.isNotEmpty) hymn.author,
    if (hymn.meter.isNotEmpty) hymn.meter,
  ];
  if (details.isNotEmpty) out.writeln(details.join(' · '));

  for (final block in layoutHymn(hymn, placement: placement)) {
    out.writeln();
    switch (block.kind) {
      case HymnBlockKind.verse:
        out.writeln('${block.verseNumber}');
      case HymnBlockKind.chorus:
        out.writeln('${labels.chorus}:');
      case HymnBlockKind.optionalVerse:
        out.writeln('${labels.optionalVerse}: ${block.label ?? ''}'.trim());
      case HymnBlockKind.alternateChorus:
        out.writeln(block.label ?? labels.optionalChorus);
    }
    final indent = block.kind == HymnBlockKind.verse ? '' : '    ';
    for (final line in block.lines) {
      out.writeln('$indent$line');
    }
  }
  if (hymn.notes.isNotEmpty) {
    out.writeln();
    for (final note in hymn.notes) {
      out.writeln('* $note');
    }
  }
  out.writeln();
  out.write(hymnCreditLines(hymn, book).join('\n'));
  return out.toString().trimRight();
}

/// "From `book`" plus per-hymn and book copyright/permission lines.
List<String> hymnCreditLines(Hymn hymn, HymnalInfo book) => [
  if (hymn.copyright != null) hymn.copyright!,
  'From ${book.title} (#${hymn.number})',
  ...book.creditLines,
];
