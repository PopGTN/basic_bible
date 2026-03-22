import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:bible_parser_flutter/bible_parser_flutter.dart';
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
      githubUrl: 'https://raw.githubusercontent.com/PopGTN/bible-data/refs/heads/main/English/eng-kjv2006_usfx.xml',
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
      githubUrl: 'https://raw.githubusercontent.com/PopGTN/bible-data/refs/heads/main/English/asv_osis.xml',
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
      githubUrl: 'https://raw.githubusercontent.com/PopGTN/bible-data/refs/heads/main/English/eng-web.usfx.xml',
      format: BibleFormat.usfx,
      sourceType: BibleSourceType.asset,
    ),
  ];

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

      _cachedBooks = parsed.map((book) => BibleBook(
        id: book['id'] as String,
        name: book['title'] as String,
        shortName: book['id'] as String,
        bookNumber: book['num'] as int,
        chapters: (book['chapters'] as List<dynamic>).map((ch) => BibleChapter(
          number: ch['number'] as int,
          verses: (ch['verses'] as List<dynamic>).map((v) => BibleVerse(
            number: v['number'] as int,
            text: v['text'] as String,
            notes: (v['notes'] as List<dynamic>?)?.cast<String>(),
            references: (v['references'] as List<dynamic>?)?.cast<String>(),
          )).toList(),
          )).toList(),
      )).toList();

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

          _cachedBooks = parsed.map((book) => BibleBook(
            id: book['id'] as String,
            name: book['title'] as String,
            shortName: book['id'] as String,
            bookNumber: book['num'] as int,
            chapters: (book['chapters'] as List<dynamic>).map((ch) => BibleChapter(
              number: ch['number'] as int,
              verses: (ch['verses'] as List<dynamic>).map((v) => BibleVerse(
                number: v['number'] as int,
                text: v['text'] as String,
                notes: (v['notes'] as List<dynamic>?)?.cast<String>(),
                references: (v['references'] as List<dynamic>?)?.cast<String>(),
              )).toList(),
            )).toList(),
          )).toList();

        await _db.insertBible(translationId, _cachedBooks);
        await _db.upsertTranslationMetadata(
          translation: translation,
          sourceLocation: translation.githubUrl,
          sourceTypeOverride: BibleSourceType.download,
        );
        _currentTranslationId = translationId;
        return _cachedBooks;
      } else {
        throw Exception('Failed to download Bible: HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to download Bible: $e');
    }
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
      orElse: () => throw Exception('Chapter $chapterNumber not found in $bookId'),
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

    for (final assetPath in candidatePaths) {
      try {
        return await rootBundle.loadString(assetPath);
      } catch (_) {
        // Continue to the next candidate path.
      }
    }

    throw Exception('Bible translation ${translation.id} not found locally');
  }
}

/// Top-level parser function run inside an isolate via `compute`.
/// It returns a JSON-serializable representation of the books.
Future<List<Map<String, dynamic>>> _parseBibleToSerializable(String content) async {
  final parser = BibleParser.fromString(content);
  final List<Map<String, dynamic>> books = [];
  await for (final book in parser.books) {
    final List<Map<String, dynamic>> chapters = [];
    for (final chapter in book.chapters) {
      final verses = chapter.verses.map((v) => {
        'number': v.num,
        'text': v.text,
        'notes': v.notes,
        'references': v.references,
      }).toList();

      chapters.add({'number': chapter.num, 'verses': verses});
    }

    books.add({'id': book.id, 'title': book.title, 'num': book.num, 'chapters': chapters});
  }
  return books;
}
