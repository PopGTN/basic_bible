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

import 'package:bible_parser_flutter/bible_parser_flutter.dart';
import 'package:basic_bible/src/models/bible_models.dart';

const int kCurrentParserVersion = 4;

// =============================================================================
// Entry point — called via compute()
// =============================================================================

Future<List<Map<String, dynamic>>> parseBibleToSerializable(
  String content,
) async {
  final parser = BibleParser.fromString(content);
  final List<Map<String, dynamic>> books = [];
  await for (final book in parser.books) {
    final List<Map<String, dynamic>> chapters = [];
    for (final chapter in book.chapters) {
      final verses = chapter.verses
          .map(
            (v) => {
              'number': v.num,
              'text': v.text,
              'notes': v.notes,
              'references': v.references,
              'spans': v.spans.map(_serializeVerseSpan).toList(),
              'footnotes': v.footnotes.map(_serializeFootnote).toList(),
              'crossReferences': v.crossReferences
                  .map(_serializeCrossReference)
                  .toList(),
            },
          )
          .toList();
      chapters.add({
        'number': chapter.num,
        'verses': verses,
        'blocks': chapter.blocks.map(_serializeDocumentBlock).toList(),
      });
    }
    books.add({
      'id': book.id,
      'title': book.title,
      'num': book.num,
      'tocLabels': book.tocLabels.map(_serializeTocLabel).toList(),
      'introductionBlocks': book.introductionBlocks
          .map(_serializeDocumentBlock)
          .toList(),
      'chapters': chapters,
    });
  }
  return books;
}

// =============================================================================
// Deserialization — maps raw maps back to model objects
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

// =============================================================================
// Serializers — maps model objects to raw maps
// =============================================================================

Map<String, dynamic> _serializeVerseSpan(VerseSpan span) => {
  'text': span.text,
  'kind': span.kind.index,
  'metadata': span.metadata,
};

Map<String, dynamic> _serializeCrossReference(CrossReference r) => {
  'label': r.label,
  'target': r.target,
  'marker': r.marker,
  'originRef': r.originRef,
  'spanIndex': r.spanIndex,
  'charOffset': r.charOffset,
};

Map<String, dynamic> _serializeFootnote(Footnote f) => {
  'text': f.text,
  'marker': f.marker,
  'label': f.label,
  'bodyText': f.bodyText,
  'quotedText': f.quotedText,
  'references': f.references.map(_serializeCrossReference).toList(),
  'spanIndex': f.spanIndex,
  'charOffset': f.charOffset,
};

Map<String, dynamic> _serializeDocumentBlock(DocumentBlock b) => {
  'kind': b.kind.index,
  'text': b.text,
  'level': b.level,
  'metadata': b.metadata,
};

Map<String, dynamic> _serializeTocLabel(TocLabel l) => {
  'text': l.text,
  'level': l.level,
};
