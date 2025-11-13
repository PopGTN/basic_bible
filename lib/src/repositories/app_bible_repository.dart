import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:bible_parser_flutter/bible_parser_flutter.dart';
import '../models/bible_models.dart';
import '../services/database_service.dart';

class AppBibleRepository {
  final DatabaseService _dbService = DatabaseService.instance;

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
      githubUrl: 'https://raw.githubusercontent.com/PopGTN/bible-data/refs/heads/main/English/eng-kjv2006_usfx.xml',
      format: BibleFormat.usfx,
    ),
    BibleTranslation(
      id: 'asv',
      name: 'American Standard Version',
      language: 'en',
      description: 'American Standard Version (1901)',
      isLocal: false,
      githubUrl: 'https://raw.githubusercontent.com/PopGTN/bible-data/refs/heads/main/English/asv_osis.xml',
      format: BibleFormat.osis,
    ),
    BibleTranslation(
      id: 'web',
      name: 'World English Bible',
      language: 'en',
      description: 'Modern English public domain Bible',
      isLocal: false,
      githubUrl: 'https://raw.githubusercontent.com/PopGTN/bible-data/refs/heads/main/English/eng-web.usfx.xml',
      format: BibleFormat.usfx,
    ),
  ];

  /// Load Bible from local asset or cache
  Future<List<BibleBook>> loadLocalBible(String translationId) async {
    if (await _dbService.isBibleCached(translationId)) {
      _cachedBooks = await _dbService.getBible(translationId);
      _currentTranslationId = translationId;
      return _cachedBooks;
    }

    try {
      final translation = availableTranslations.firstWhere(
            (t) => t.id == translationId,
        orElse: () => throw Exception('Translation $translationId not found'),
      );

      String content = '';
      
      // Try to load from assets first
      final assetExtensions = ['usfm', 'usfx', 'txt', 'xml'];
      for (final ext in assetExtensions) {
        final assetPath = 'assets/bible/$translationId.$ext';
        try {
          content = await rootBundle.loadString(assetPath);
          break;
        } catch (e) {
          // Continue to next extension
        }
      }

      if (content.isEmpty) {
        throw Exception('Bible translation $translationId not found locally');
      }

      final parser = BibleParser.fromString(content);
      final books = <Book>[];
      await for (final book in parser.books) {
        books.add(book);
      }
      _cachedBooks = books.map((book) => BibleBook(
        id: book.id,
        name: book.title,
        shortName: book.id,
        bookNumber: book.num,
        chapters: book.chapters.map((chapter) => BibleChapter(
          number: chapter.num,
          verses: chapter.verses.map((verse) => BibleVerse(
            number: verse.num,
            text: verse.text,
            notes: verse.notes,
            references: verse.references,
          )).toList(),
        )).toList(),
      )).toList();

      await _dbService.insertBible(translationId, _cachedBooks);
      _currentTranslationId = translationId;
      return _cachedBooks;
    } catch (e) {
      throw Exception('Failed to load local Bible: $e');
    }
  }

  /// Download Bible from GitHub and cache it
  Future<List<BibleBook>> downloadBible(String translationId) async {
    if (await _dbService.isBibleCached(translationId)) {
      _cachedBooks = await _dbService.getBible(translationId);
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

        final parser = BibleParser.fromString(content);
        final books = <Book>[];
        await for (final book in parser.books) {
          books.add(book);
        }
        _cachedBooks = books.map((book) => BibleBook(
          id: book.id,
          name: book.title,
          shortName: book.id,
          bookNumber: book.num,
          chapters: book.chapters.map((chapter) => BibleChapter(
            number: chapter.num,
            verses: chapter.verses.map((verse) => BibleVerse(
              number: verse.num,
              text: verse.text,
              notes: verse.notes,
              references: verse.references,
            )).toList(),
          )).toList(),
        )).toList();

        await _dbService.insertBible(translationId, _cachedBooks);
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
    return await _dbService.isBibleCached(translationId);
  }

  /// Clear cache for a specific translation
  Future<void> clearCache(String translationId) async {
    await _dbService.deleteBible(translationId);
  }

  /// Clear all cache
  Future<void> clearAllCache() async {
    await _dbService.deleteAllBibles();
  }
}