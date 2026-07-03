// Top-level functions required by Flutter's compute() isolate API.
// Must be top-level (not instance methods) to be passed to compute().
//
// Bump [kCurrentParserVersion] whenever the serialization format changes in a
// way that requires existing cached Bibles to be re-parsed.
//   0 = initial version
//   1 = inline anchor markers added
//   2 = book IDs normalized to uppercase
//   3 = per-translation SQLite split (forces rebuild into new file layout)
//   4 = section headings carry `beforeVerse` metadata for inline rendering
//   5 = heading levels normalized across OSIS and Zefania sources
//
// Since the model deduplication, the parser's rich-content classes ARE the
// app's classes (see models/bible_models/verse_span.dart), so the XML path
// builds app models directly with no JSON round-trip. The serializable-map
// path below ([mapSerializableBook]) remains for the native USFM parser,
// which hands its results across the FFI boundary as JSON.

import 'package:bible_parser_flutter/bible_parser_flutter.dart';
import 'package:basic_bible/src/models/bible_models.dart';

const int kCurrentParserVersion = 5;

// =============================================================================
// Entry point — called via compute()
// =============================================================================

/// Parses XML Bible [content] straight into app models inside the worker
/// isolate. Spans, footnotes, cross-references, blocks, and TOC labels are
/// shared types now, so the parser's objects are used as-is.
Future<List<BibleBook>> parseBibleContentToBooks(String content) async {
  final parser = BibleParser.fromString(content);
  final books = <BibleBook>[];
  await for (final book in parser.books) {
    books.add(
      BibleBook(
        id: book.id.toUpperCase(),
        name: book.title,
        shortName: book.id.toUpperCase(),
        bookNumber: book.num,
        tocLabels: book.tocLabels,
        introductionBlocks: book.introductionBlocks,
        chapters: [
          for (final chapter in book.chapters)
            BibleChapter(
              number: chapter.num,
              blocks: chapter.blocks,
              verses: [
                for (final verse in chapter.verses)
                  BibleVerse(
                    number: verse.num,
                    text: verse.text,
                    notes: verse.notes,
                    references: verse.references,
                    spans: verse.spans,
                    footnotes: verse.footnotes,
                    crossReferences: verse.crossReferences,
                  ),
              ],
            ),
        ],
      ),
    );
  }
  return books;
}

// =============================================================================
// Deserialization — maps raw JSON maps (from the native USFM parser) to models
// =============================================================================

BibleBook mapSerializableBook(Map<String, dynamic> book) {
  return BibleBook(
    id: (book['id'] as String).toUpperCase(),
    name: book['title'] as String,
    shortName: (book['id'] as String).toUpperCase(),
    bookNumber: book['num'] as int,
    tocLabels: (book['tocLabels'] as List<dynamic>? ?? const [])
        .map((item) => BibleTocLabel.fromJson(item as Map<String, dynamic>))
        .toList(),
    introductionBlocks:
        (book['introductionBlocks'] as List<dynamic>? ?? const [])
            .map(
              (item) =>
                  BibleDocumentBlock.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
    chapters: (book['chapters'] as List<dynamic>)
        .map((c) => _mapSerializableChapter(c as Map<String, dynamic>))
        .toList(),
  );
}

BibleChapter _mapSerializableChapter(Map<String, dynamic> chapter) {
  return BibleChapter(
    number: chapter['number'] as int,
    blocks: (chapter['blocks'] as List<dynamic>? ?? const [])
        .map(
          (item) => BibleDocumentBlock.fromJson(item as Map<String, dynamic>),
        )
        .toList(),
    verses: (chapter['verses'] as List<dynamic>)
        .map((v) => _mapSerializableVerse(v as Map<String, dynamic>))
        .toList(),
  );
}

BibleVerse _mapSerializableVerse(Map<String, dynamic> verse) {
  return BibleVerse(
    number: verse['number'] as int,
    text: verse['text'] as String,
    notes: (verse['notes'] as List<dynamic>?)?.cast<String>(),
    references: (verse['references'] as List<dynamic>?)?.cast<String>(),
    spans: (verse['spans'] as List<dynamic>? ?? const [])
        .map((item) => BibleVerseSpan.fromJson(item as Map<String, dynamic>))
        .toList(),
    footnotes: (verse['footnotes'] as List<dynamic>? ?? const [])
        .map((item) => BibleFootnote.fromJson(item as Map<String, dynamic>))
        .toList(),
    crossReferences: (verse['crossReferences'] as List<dynamic>? ?? const [])
        .map(
          (item) => BibleCrossReference.fromJson(item as Map<String, dynamic>),
        )
        .toList(),
  );
}
