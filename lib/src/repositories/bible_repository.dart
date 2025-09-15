// lib/src/repositories/bible_repository.dart
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/bibleModels/bibleBook.dart';
import '../models/bibleModels/bibleChapter.dart';
import '../models/bibleModels/bibleTranslation.dart';
import '../models/bibleModels/bibleVersus.dart';
import '../models/bible_models.dart';
import '../services/usfx_parser.dart';
import '../services/usfm_parser.dart';

class BibleRepository {
  static const String _cacheDir = 'bible_cache';

  List<BibleBook> _cachedBooks = [];
  String? _currentTranslationId;

  /// Available Bible translations
  static final List<BibleTranslation> availableTranslations = [
    // USFX translations
    BibleTranslation(
      id: 'kjv',
      name: 'King James Version',
      language: 'en',
      description: 'The classic English Bible translation',
      isLocal: false,
      githubUrl: 'https://raw.githubusercontent.com/PopGTN/bible-data/refs/heads/main/KJV/eng-kjv2006_usfx/eng-kjv2006_usfx.xml',
      format: BibleFormat.usfx,
    ),
    BibleTranslation(
      id: 'asv',
      name: 'American Standard Version',
      language: 'en',
      description: 'American Standard Version (1901)',
      isLocal: false,
      githubUrl: 'https://raw.githubusercontent.com/gratis-bible/bible/main/usfx/asv.usfx',
      format: BibleFormat.usfx,
    ),
    BibleTranslation(
      id: 'web',
      name: 'World English Bible',
      language: 'en',
      description: 'Modern English public domain Bible',
      isLocal: false,
      githubUrl: 'https://raw.githubusercontent.com/gratis-bible/bible/main/usfx/web.usfx',
      format: BibleFormat.usfx,
    ),

    // USFM translations
    BibleTranslation(
      id: 'kjv_usfm',
      name: 'King James Version (USFM)',
      language: 'en',
      description: 'KJV in USFM format with enhanced formatting',
      isLocal: false,
      githubUrl: 'https://raw.githubusercontent.com/gratis-bible/bible/main/usfm/kjv.usfm',
      format: BibleFormat.usfm,
    ),
    BibleTranslation(
      id: 'web_usfm',
      name: 'World English Bible (USFM)',
      language: 'en',
      description: 'WEB in USFM format with study notes',
      isLocal: false,
      githubUrl: 'https://raw.githubusercontent.com/gratis-bible/bible/main/usfm/web.usfm',
      format: BibleFormat.usfm,
    ),
    BibleTranslation(
      id: 'bbe',
      name: 'Bible in Basic English',
      language: 'en',
      description: 'Simple English Bible translation',
      isLocal: false,
      githubUrl: 'https://raw.githubusercontent.com/gratis-bible/bible/main/usfm/bbe.usfm',
      format: BibleFormat.usfm,
    ),
  ];

  /// Load Bible from local asset or cache
  Future<List<BibleBook>> loadLocalBible(String translationId) async {
    try {
      final translation = availableTranslations.firstWhere(
            (t) => t.id == translationId,
        orElse: () => throw Exception('Translation $translationId not found'),
      );

      String content = '';
      String? detectedFormat;

      // Try to load from assets first
      final assetExtensions = ['usfm', 'usfx', 'txt'];
      for (final ext in assetExtensions) {
        final assetPath = 'assets/bible/$translationId.$ext';
        try {
          content = await rootBundle.loadString(assetPath);
          detectedFormat = ext;
          break;
        } catch (e) {
          // Continue to next extension
        }
      }

      // If not found in assets, try cache
      if (content.isEmpty) {
        final cacheFile = await _getCacheFile(translationId);
        if (await cacheFile.exists()) {
          content = await cacheFile.readAsString();
          detectedFormat = _detectFormat(content);
        }
      }

      if (content.isEmpty) {
        throw Exception('Bible translation $translationId not found locally');
      }

      // Parse based on format
      final format = _determineFormat(translation.format, detectedFormat, content);
      _cachedBooks = await _parseContent(content, format);
      _currentTranslationId = translationId;
      return _cachedBooks;
    } catch (e) {
      throw Exception('Failed to load local Bible: $e');
    }
  }

  /// Download Bible from GitHub and cache it
  Future<List<BibleBook>> downloadBible(String translationId) async {
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

        // Cache the downloaded content
        await _cacheContent(translationId, content);

        // Parse and return
        final format = _determineFormat(translation.format, null, content);
        _cachedBooks = await _parseContent(content, format);
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
    final cacheFile = await _getCacheFile(translationId);
    return await cacheFile.exists();
  }

  /// Clear cache for a specific translation
  Future<void> clearCache(String translationId) async {
    final cacheFile = await _getCacheFile(translationId);
    if (await cacheFile.exists()) {
      await cacheFile.delete();
    }
  }

  /// Clear all cache
  Future<void> clearAllCache() async {
    final cacheDir = await _getCacheDirectory();
    if (await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
    }
  }

  // Private helper methods
  Future<List<BibleBook>> _parseContent(String content, BibleFormat format) async {
    switch (format) {
      case BibleFormat.usfm:
        return USFMParser.parseUSFM(content);
      case BibleFormat.usfx:
        return USFXParser.parseUSFX(content);
      case BibleFormat.osis:
        return USFXParser.parseUSFX(content);
      case BibleFormat.auto:
      // Auto-detect and parse
        if (USFMParser.isUSFM(content)) {
          return USFMParser.parseUSFM(content);
        } else {
          return USFXParser.parseUSFX(content);
        }
    }
  }

  BibleFormat _determineFormat(BibleFormat specifiedFormat, String? detectedExtension, String content) {
    // If format is explicitly specified and not auto, use it
    if (specifiedFormat != BibleFormat.auto) {
      return specifiedFormat;
    }

    // Try to determine from file extension
    if (detectedExtension != null) {
      switch (detectedExtension.toLowerCase()) {
        case 'usfm':
        case 'sfm':
          return BibleFormat.usfm;
        case 'usfx':
        case 'xml':
          return BibleFormat.usfx;
      }
    }

    // Auto-detect from content
    if (USFMParser.isUSFM(content)) {
      return BibleFormat.usfm;
    } else {
      return BibleFormat.usfx; // Default fallback
    }
  }

  String? _detectFormat(String content) {
    if (USFMParser.isUSFM(content)) {
      return 'usfm';
    } else if (content.trim().startsWith('<')) {
      return 'usfx';
    }
    return null;
  }

  Future<File> _getCacheFile(String translationId) async {
    final cacheDir = await _getCacheDirectory();
    // Try both extensions for cached files
    final usfmFile = File('${cacheDir.path}/$translationId.usfm');
    final usfxFile = File('${cacheDir.path}/$translationId.usfx');

    if (await usfmFile.exists()) return usfmFile;
    if (await usfxFile.exists()) return usfxFile;

    // Default to usfm extension for new files
    return usfmFile;
  }

  Future<Directory> _getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/$_cacheDir');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  Future<void> _cacheContent(String translationId, String content) async {
    final cacheFile = await _getCacheFile(translationId);
    await cacheFile.writeAsString(content);
  }
}