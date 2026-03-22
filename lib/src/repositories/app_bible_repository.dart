import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:bible_parser_flutter/bible_parser_flutter.dart';
import 'package:path/path.dart' as p;
import '../models/bible_models.dart';
import '../services/app_database.dart';

class AppBibleRepository {
  final AppDatabase _db;

  List<BibleBook> _cachedBooks = [];
  String? _currentTranslationId;

  AppBibleRepository(this._db);

  /// Available Bible translations
  static final List<BibleTranslation> availableTranslations = [
    // USFX translations
    BibleTranslation(
      id: 'kjv',
      name: 'King James Version',
      language: 'en',
      description: 'The classic English Bible translation',
      isLocal: true,
      filePath: 'assets/bible/eng-kjv2006_usfx.xml',
      githubUrl:
          'https://raw.githubusercontent.com/PopGTN/bible-data/refs/heads/main/English/eng-kjv2006_usfx.xml',
      format: BibleFormat.usfx,
      sourceType: BibleSourceType.asset,
    ),
    BibleTranslation(
      id: 'asv',
      name: 'American Standard Version',
      language: 'en',
      description: 'American Standard Version (1901)',
      isLocal: true,
      filePath: 'assets/bible/asv_osis.xml',
      githubUrl:
          'https://raw.githubusercontent.com/PopGTN/bible-data/refs/heads/main/English/asv_osis.xml',
      format: BibleFormat.osis,
      sourceType: BibleSourceType.asset,
    ),
    BibleTranslation(
      id: 'web',
      name: 'World English Bible',
      language: 'en',
      description: 'Modern English public domain Bible',
      isLocal: true,
      filePath: 'assets/bible/eng-web.usfx.xml',
      githubUrl:
          'https://raw.githubusercontent.com/PopGTN/bible-data/refs/heads/main/English/eng-web.usfx.xml',
      format: BibleFormat.usfx,
      sourceType: BibleSourceType.asset,
    ),
  ];

  Future<List<BibleTranslation>> getAvailableTranslations() async {
    final storedTranslations = await _db.getStoredTranslations();
    final builtInIds = availableTranslations.map((t) => t.id).toSet();

    return [
      ...availableTranslations,
      ...storedTranslations.where(
        (translation) => !builtInIds.contains(translation.id),
      ),
    ];
  }

  /// Load Bible from local asset or cache
  Future<List<BibleBook>> loadLocalBible(String translationId) async {
    if (await _db.isBibleCached(translationId)) {
      _cachedBooks = await _db.getBible(translationId);
      _currentTranslationId = translationId;
      return _cachedBooks;
    }

    try {
      final translation = _getTranslation(translationId);
      final content = await _loadAssetContent(translation);

      // Parsing can be CPU-intensive for large files. Run it in a
      // background isolate so we don't block the UI thread.
      final parsed = await compute(_parseBibleToSerializable, content);

      _cachedBooks = parsed.map(_mapSerializableBook).toList();

      await _db.insertBible(translationId, _cachedBooks);
      await _db.upsertTranslationMetadata(
        translation: translation,
        sourceLocation: translation.filePath,
      );
      _currentTranslationId = translationId;
      return _cachedBooks;
    } catch (e) {
      throw Exception('Failed to load local Bible: $e');
    }
  }

  /// Download Bible from GitHub and cache it
  Future<List<BibleBook>> downloadBible(String translationId) async {
    if (await _db.isBibleCached(translationId)) {
      _cachedBooks = await _db.getBible(translationId);
      _currentTranslationId = translationId;
      return _cachedBooks;
    }

    final translation = availableTranslations.firstWhere(
      (t) => t.id == translationId,
      orElse: () => throw Exception('Translation $translationId not found'),
    );

    if (translation.githubUrl == null) {
      throw Exception('No download URL for translation $translationId');
    }

    try {
      final response = await http.get(Uri.parse(translation.githubUrl!));

      if (response.statusCode == 200) {
        final content = utf8.decode(response.bodyBytes);

        // Parse in an isolate
        final parsed = await compute(_parseBibleToSerializable, content);

        _cachedBooks = parsed.map(_mapSerializableBook).toList();

        await _db.insertBible(translationId, _cachedBooks);
        await _db.upsertTranslationMetadata(
          translation: translation,
          sourceLocation: translation.githubUrl,
          sourceTypeOverride: BibleSourceType.download,
        );
        _currentTranslationId = translationId;
        return _cachedBooks;
      } else {
        throw Exception(
          'Failed to download Bible: HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to download Bible: $e');
    }
  }

  Future<BibleTranslation> importBibleFromFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Selected Bible file does not exist.');
    }

    final content = await file.readAsString();
    final parsed = await compute(_parseBibleToSerializable, content);
    final importedBooks = parsed.map(_mapSerializableBook).toList();
    if (importedBooks.isEmpty) {
      throw Exception('The selected file did not contain any Bible books.');
    }

    final detectedFormat = _detectFormatFromContent(content);
    final translation = await _buildImportedTranslation(
      filePath: filePath,
      format: detectedFormat,
      importedBooks: importedBooks,
    );

    _cachedBooks = importedBooks;
    await _db.insertBible(translation.id, importedBooks);
    await _db.upsertTranslationMetadata(
      translation: translation,
      sourceLocation: filePath,
      sourceTypeOverride: BibleSourceType.import,
    );
    _currentTranslationId = translation.id;
    return translation;
  }

  /// Get a specific book
  BibleBook? getBook(String bookId) {
    return _cachedBooks.firstWhere(
      (book) => book.id == bookId,
      orElse: () => throw Exception('Book $bookId not found'),
    );
  }

  /// Get a specific chapter
  BibleChapter? getChapter(String bookId, int chapterNumber) {
    final book = getBook(bookId);
    return book?.chapters.firstWhere(
      (chapter) => chapter.number == chapterNumber,
      orElse: () =>
          throw Exception('Chapter $chapterNumber not found in $bookId'),
    );
  }

  /// Get verses for a chapter
  List<BibleVerse> getVerses(String bookId, int chapterNumber) {
    final chapter = getChapter(bookId, chapterNumber);
    return chapter?.verses ?? [];
  }

  /// Search for text across all books
  List<BibleVerse> searchText(String query, {String? bookId}) {
    final results = <BibleVerse>[];
    final searchQuery = query.toLowerCase();

    final booksToSearch = bookId != null
        ? [getBook(bookId)].where((b) => b != null).cast<BibleBook>()
        : _cachedBooks;

    for (final book in booksToSearch) {
      for (final chapter in book.chapters) {
        for (final verse in chapter.verses) {
          if (verse.text.toLowerCase().contains(searchQuery)) {
            results.add(verse);
          }
        }
      }
    }

    return results;
  }

  /// Get all available books
  List<BibleBook> getAllBooks() => List.unmodifiable(_cachedBooks);

  /// Get current translation ID
  String? getCurrentTranslationId() => _currentTranslationId;

  /// Check if a translation is cached
  Future<bool> isCached(String translationId) async {
    return await _db.isBibleCached(translationId);
  }

  /// Clear cache for a specific translation
  Future<void> clearCache(String translationId) async {
    await _db.deleteBible(translationId);
  }

  /// Clear all cache
  Future<void> clearAllCache() async {
    await _db.deleteAllBibles();
  }

  BibleTranslation _getTranslation(String translationId) {
    return availableTranslations.firstWhere(
      (t) => t.id == translationId,
      orElse: () => throw Exception('Translation $translationId not found'),
    );
  }

  Future<String> _loadAssetContent(BibleTranslation translation) async {
    final candidatePaths = <String>[
      if (translation.filePath != null) translation.filePath!,
      'assets/bible/${translation.id}.usfm',
      'assets/bible/${translation.id}.usfx',
      'assets/bible/${translation.id}.txt',
      'assets/bible/${translation.id}.xml',
    ];

    // Prefer the explicit configured asset path first. The fallback guesses
    // are here to keep older translation-id-based behavior working where possible.
    for (final assetPath in candidatePaths) {
      try {
        return await rootBundle.loadString(assetPath);
      } catch (_) {
        // Continue to the next candidate path.
      }
    }

    throw Exception('Bible translation ${translation.id} not found locally');
  }

  Future<BibleTranslation> _buildImportedTranslation({
    required String filePath,
    required BibleFormat format,
    required List<BibleBook> importedBooks,
  }) async {
    final storedIds =
        (await _db.getStoredTranslations()).map((t) => t.id).toSet()
          ..addAll(availableTranslations.map((t) => t.id));
    final baseName = p.basenameWithoutExtension(filePath);
    final sanitizedId = _sanitizeTranslationId(baseName);
    var candidateId = sanitizedId;
    var suffix = 2;
    while (storedIds.contains(candidateId)) {
      candidateId = '${sanitizedId}_$suffix';
      suffix++;
    }

    final suggestedName = _buildImportedTranslationName(
      filePath: filePath,
      importedBooks: importedBooks,
    );

    return BibleTranslation(
      id: candidateId,
      name: suggestedName,
      language: 'unknown',
      description: 'Imported from ${p.basename(filePath)}',
      isLocal: true,
      filePath: filePath,
      format: format,
      sourceType: BibleSourceType.import,
    );
  }

  BibleFormat _detectFormatFromContent(String content) {
    final lowerContent = content.toLowerCase();
    if (lowerContent.contains('<usfx')) return BibleFormat.usfx;
    if (lowerContent.contains('<osis') || lowerContent.contains('<osistext')) {
      return BibleFormat.osis;
    }
    if (lowerContent.contains('<xmlbible')) {
      // The app model does not yet expose a dedicated Zefania enum value, so
      // keep these imports as `auto` while the parser still detects them
      // correctly from the XML content at runtime.
      return BibleFormat.auto;
    }
    return BibleFormat.auto;
  }

  String _sanitizeTranslationId(String value) {
    final normalized = value.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]+'),
      '_',
    );
    return normalized.replaceAll(RegExp(r'^_+|_+$'), '').isEmpty
        ? 'imported_bible'
        : normalized.replaceAll(RegExp(r'^_+|_+$'), '');
  }

  String _buildImportedTranslationName({
    required String filePath,
    required List<BibleBook> importedBooks,
  }) {
    final baseName = p
        .basenameWithoutExtension(filePath)
        .replaceAll('_', ' ')
        .trim();
    if (baseName.isNotEmpty) {
      return baseName;
    }
    if (importedBooks.isNotEmpty) {
      return '${importedBooks.first.name} Import';
    }
    return 'Imported Bible';
  }
}

/// Top-level parser function run inside an isolate via `compute`.
/// It returns a JSON-serializable representation of the books.
Future<List<Map<String, dynamic>>> _parseBibleToSerializable(
  String content,
) async {
  final parser = BibleParser.fromString(content);
  final List<Map<String, dynamic>> books = [];
  await for (final book in parser.books) {
    // Keep the isolate payload JSON-friendly so parsing stays off the UI
    // thread without leaking parser package types across isolate boundaries.
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

BibleBook _mapSerializableBook(Map<String, dynamic> book) {
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
        .map(
          (chapter) => _mapSerializableChapter(chapter as Map<String, dynamic>),
        )
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
        .map((verse) => _mapSerializableVerse(verse as Map<String, dynamic>))
        .toList(),
  );
}

BibleVerse _mapSerializableVerse(Map<String, dynamic> verse) {
  return BibleVerse(
    number: verse['number'] as int,
    text: verse['text'] as String,
    notes: (verse['notes'] as List<dynamic>?)?.cast<String>(),
    references: (verse['references'] as List<dynamic>?)?.cast<String>(),
    // The app model mirrors the parser's structured fields so we can persist
    // richer import data now even before every screen knows how to render it.
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

Map<String, dynamic> _serializeVerseSpan(VerseSpan span) {
  return {
    'text': span.text,
    'kind': span.kind.index,
    'metadata': span.metadata,
  };
}

Map<String, dynamic> _serializeCrossReference(CrossReference reference) {
  return {'label': reference.label, 'target': reference.target};
}

Map<String, dynamic> _serializeFootnote(Footnote footnote) {
  return {
    'text': footnote.text,
    'marker': footnote.marker,
    'label': footnote.label,
    'references': footnote.references.map(_serializeCrossReference).toList(),
  };
}

Map<String, dynamic> _serializeDocumentBlock(DocumentBlock block) {
  return {
    'kind': block.kind.index,
    'text': block.text,
    'level': block.level,
    'metadata': block.metadata,
  };
}

Map<String, dynamic> _serializeTocLabel(TocLabel label) {
  return {'text': label.text, 'level': label.level};
}
