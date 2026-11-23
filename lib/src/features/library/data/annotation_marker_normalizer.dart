import 'package:basic_bible/src/models/bible_models.dart';

const _footnoteMarkersKey = 'footnoteMarkers';
const _referenceMarkersKey = 'referenceMarkers';

/// Relabels footnote / cross-reference markers so they run a, b, c … across a
/// whole chapter instead of restarting at "a" in every verse (issue #74).
///
/// Every parser format resets its generated-marker counter at each verse
/// start, so a chapter with notes on several verses showed "a" over and over.
/// The parser lives in a separate package and its output is persisted, so
/// the app normalizes at its data boundaries instead (database reads and
/// fresh parses). All views — inline markers, the verse-details sheet — read
/// the same rewritten markers, so they always agree.
///
/// Markers are assigned in reading order: a verse's inline markers in span
/// order first, then any footnotes/references that had no inline position.
/// The result depends only on that order, so applying it twice is a no-op.
List<BibleVerse> normalizeChapterAnnotationMarkers(List<BibleVerse> verses) {
  if (!verses.any(_hasAnnotations)) return verses;

  var nextIndex = 0;
  String nextMarker() => chapterAnnotationMarker(nextIndex++);

  return [
    for (final verse in verses)
      _hasAnnotations(verse) ? _relabelVerse(verse, nextMarker) : verse,
  ];
}

/// a … z, aa, ab … (bijective base-26), matching the parser's own scheme.
String chapterAnnotationMarker(int index) {
  final buffer = StringBuffer();
  var value = index;
  do {
    buffer.writeCharCode('a'.codeUnitAt(0) + value % 26);
    value = value ~/ 26 - 1;
  } while (value >= 0);
  return buffer.toString().split('').reversed.join();
}

bool _hasAnnotations(BibleVerse verse) =>
    verse.footnotes.isNotEmpty ||
    verse.crossReferences.isNotEmpty ||
    verse.spans.any(
      (span) =>
          span.metadata.containsKey(_footnoteMarkersKey) ||
          span.metadata.containsKey(_referenceMarkersKey),
    );

BibleVerse _relabelVerse(BibleVerse verse, String Function() nextMarker) {
  // Local (per-verse) marker -> chapter-wide marker. Shared by inline spans
  // and the footnote/reference lists so both sides map identically.
  final mapping = <String, String>{};
  String relabel(String local) => mapping.putIfAbsent(local, nextMarker);

  String? relabelList(String? raw) {
    if (raw == null) return null;
    return raw
        .split('|')
        .map((m) => m.trim())
        .where((m) => m.isNotEmpty)
        .map(relabel)
        .join('|');
  }

  final spans = [
    for (final span in verse.spans)
      if (span.metadata.containsKey(_footnoteMarkersKey) ||
          span.metadata.containsKey(_referenceMarkersKey))
        BibleVerseSpan(
          text: span.text,
          kind: span.kind,
          metadata: {
            ...span.metadata,
            if (span.metadata.containsKey(_footnoteMarkersKey))
              _footnoteMarkersKey: relabelList(
                span.metadata[_footnoteMarkersKey],
              )!,
            if (span.metadata.containsKey(_referenceMarkersKey))
              _referenceMarkersKey: relabelList(
                span.metadata[_referenceMarkersKey],
              )!,
          },
        )
      else
        span,
  ];

  // A marker that never appeared inline still gets the next chapter letter.
  String relabelOwn(String? marker) {
    final local = marker?.trim();
    return local == null || local.isEmpty ? nextMarker() : relabel(local);
  }

  final footnotes = [
    for (final footnote in verse.footnotes)
      BibleFootnote(
        text: footnote.text,
        marker: relabelOwn(footnote.marker),
        label: footnote.label,
        bodyText: footnote.bodyText,
        quotedText: footnote.quotedText,
        references: footnote.references,
        spanIndex: footnote.spanIndex,
        charOffset: footnote.charOffset,
      ),
  ];
  final crossReferences = [
    for (final reference in verse.crossReferences)
      BibleCrossReference(
        label: reference.label,
        target: reference.target,
        marker: relabelOwn(reference.marker),
        originRef: reference.originRef,
        spanIndex: reference.spanIndex,
        charOffset: reference.charOffset,
      ),
  ];

  return verse.copyWith(
    spans: spans,
    footnotes: footnotes,
    crossReferences: crossReferences,
  );
}
