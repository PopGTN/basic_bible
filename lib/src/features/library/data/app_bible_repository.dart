import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:bible_parser_flutter/bible_parser_flutter.dart';
import 'package:basic_bible/src/features/library/data/remote_translation_catalog_service.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/services/app_database.dart';
import 'package:basic_bible/src/services/translation_database.dart';
import 'package:basic_bible/src/services/translation_database_manager.dart';
import 'package:path/path.dart' as p;

import 'library_source_io.dart';

class BibleImportDraft {
  const BibleImportDraft({
    required this.filePath,
    required this.fileName,
    required this.format,
    required this.importedBooks,
    required this.suggestedId,
    required this.suggestedName,
    required this.suggestedLanguage,
    required this.suggestedDescription,
  });

  final String filePath;
  final String fileName;
  final BibleFormat format;
  final List<BibleBook> importedBooks;
  final String suggestedId;
  final String suggestedName;
  final String suggestedLanguage;
  final String suggestedDescription;
}

class BibleImportRequest {
  const BibleImportRequest({
    required this.filePath,
    required this.format,
    required this.importedBooks,
    required this.id,
    required this.name,
    required this.language,
    required this.description,
  });

  final String filePath;
  final BibleFormat format;
  final List<BibleBook> importedBooks;
  final String id;
  final String name;
  final String language;
  final String description;
}

class AppBibleRepository {
  final AppDatabase _db;
  final TranslationDatabaseManager _dbManager;
  final RemoteTranslationCatalogService _catalogService;

  List<BibleBook> _cachedBooks = [];
  String? _currentTranslationId;
  final Map<String, List<BibleBook>> _memoryCacheByTranslation =
      <String, List<BibleBook>>{};
  final Set<String> _sessionTranslationIds = <String>{};

  // In-flight deduplication: if two callers request the same translation
  // concurrently (e.g., BibleBooksShellNotifier + BibleBooksNotifier on first
  // load) they share one Future instead of running two concurrent parses that
  // would both write to the same SQLite file.
  final Map<String, Future<List<BibleBook>>> _inFlight = {};

  /// Bump this integer every time the parser output format changes in a way
  /// that requires existing cached Bibles to be re-parsed.
  ///   0 = initial version
  ///   1 = inline anchor markers added
  ///   2 = book IDs normalized to uppercase
  ///   3 = per-translation SQLite split (forces rebuild into new file layout)
  ///   4 = section headings carry `beforeVerse` metadata for inline rendering
  static const int _currentParserVersion = 4;

  AppBibleRepository(this._db, this._dbManager, this._catalogService);

  // ---------------------------------------------------------------------------
  // Built-in translations
  // ---------------------------------------------------------------------------

  static final List<BibleTranslation> builtInTranslations = [
    BibleTranslation(
      id: 'kjv',
      name: 'King James Version',
      language: 'en',
      languageName: 'English',
      description: 'The classic English Bible translation',
      isLocal: true,
      filePath: 'assets/bible/eng-kjv2006_usfx.xml',
      githubUrl:
          'https://raw.githubusercontent.com/PopGTN/bible-data/main/English/kjv/eng-kjv2006_usfx.xml',
      format: BibleFormat.usfx,
      sourceType: BibleSourceType.asset,
      bundledByDefault: true,
      displayOrder: 10,
      artifacts: [
        BibleTranslationArtifact(
          format: BibleFormat.usfx,
          downloadUrl:
              'https://raw.githubusercontent.com/PopGTN/bible-data/main/English/kjv/eng-kjv2006_usfx.xml',
          fileName: 'eng-kjv2006_usfx.xml',
          isPreferred: true,
        ),
      ],
    ),
    BibleTranslation(
      id: 'asv',
      name: 'American Standard Version',
      language: 'en',
      languageName: 'English',
      description: 'American Standard Version (1901)',
      isLocal: true,
      filePath: 'assets/bible/asv_osis.xml',
      githubUrl:
          'https://raw.githubusercontent.com/PopGTN/bible-data/main/English/asv/asv_osis.xml',
      format: BibleFormat.osis,
      sourceType: BibleSourceType.asset,
      displayOrder: 20,
      artifacts: [
        BibleTranslationArtifact(
          format: BibleFormat.osis,
          downloadUrl:
              'https://raw.githubusercontent.com/PopGTN/bible-data/main/English/asv/asv_osis.xml',
          fileName: 'asv_osis.xml',
          isPreferred: true,
        ),
      ],
    ),
    BibleTranslation(
      id: 'web',
      name: 'World English Bible',
      language: 'en',
      languageName: 'English',
      description: 'Modern English public domain Bible',
      isLocal: true,
      filePath: 'assets/bible/eng-web.usfx.xml',
      githubUrl:
          'https://raw.githubusercontent.com/PopGTN/bible-data/main/English/web/eng-web.usfx.xml',
      format: BibleFormat.usfx,
      sourceType: BibleSourceType.asset,
      displayOrder: 30,
      artifacts: [
        BibleTranslationArtifact(
          format: BibleFormat.usfx,
          downloadUrl:
              'https://raw.githubusercontent.com/PopGTN/bible-data/main/English/web/eng-web.usfx.xml',
          fileName: 'eng-web.usfx.xml',
          isPreferred: true,
        ),
      ],
    ),
  ];

  // ---------------------------------------------------------------------------
  // Path helpers
  // ---------------------------------------------------------------------------

  Future<String> _sqlitePathFor(String id) =>
      TranslationDatabaseManager.pathForTranslation(id);

  // ---------------------------------------------------------------------------
  // Cache validity check
  // ---------------------------------------------------------------------------

  Future<bool> _isCacheValid(String translationId) async {
    final meta = await _db.getInstalledTranslation(translationId);
    if (meta == null || meta.parserVersion < _currentParserVersion) {
      return false;
    }
    if (!usesFileBackedStorage) return true;

    final path = await _sqlitePathFor(translationId);
    return pathExists(path);
  }

  Future<void> _invalidateCache(String translationId) async {
    _dbManager.close(translationId);
    if (!usesFileBackedStorage) {
      final path = await _sqlitePathFor(translationId);
      final translationDb = await _dbManager.open(translationId, path);
      await translationDb.clearBible();
      _dbManager.close(translationId);
      return;
    }

    final path = await _sqlitePathFor(translationId);
    await deleteFileIfExists(path);
  }

  // ---------------------------------------------------------------------------
  // Public API — available translations
  // ---------------------------------------------------------------------------

  Future<List<BibleTranslation>> getAvailableTranslations() async {
    final stored = await _db.getInstalledTranslations();
    final remote = await _fetchRemoteTranslationsSafely();
    final builtInIds = builtInTranslations.map((t) => t.id).toSet();
    final remoteById = {for (final t in remote) t.id: t};
    final storedById = {for (final t in stored) t.id: t};
    final mergedBuiltIns = [
      for (final t in builtInTranslations)
        _applySessionState(
          _mergeStoredTranslation(
            base: _mergeCatalogTranslation(
              builtIn: t,
              remote: remoteById[t.id],
            ),
            stored: storedById[t.id],
          ),
        ),
    ];
    final remainingIds = {...remoteById.keys, ...storedById.keys}
      ..removeAll(builtInIds);

    return [
      ...mergedBuiltIns,
      for (final id in remainingIds)
        _applySessionState(
          _mergeStoredTranslation(
            base: remoteById[id] ?? storedById[id]!,
            stored: storedById[id],
          ),
        ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Load — shell (books + chapter metadata, no verses)
  // ---------------------------------------------------------------------------

  Future<List<BibleBook>> loadLocalBibleShell(String translationId) async {
    final memoryCached = getLoadedTranslation(translationId);
    if (memoryCached != null) return memoryCached;

    if (await _isCacheValid(translationId)) {
      final path = await _sqlitePathFor(translationId);
      final translationDb = await _dbManager.open(translationId, path);
      final shell = await translationDb.getBooksShell();
      if (shell.isNotEmpty) return shell;
    }

    return loadLocalBible(translationId);
  }

  // ---------------------------------------------------------------------------
  // Load — full (parses XML if needed)
  // ---------------------------------------------------------------------------

  Future<List<BibleBook>> loadLocalBible(String translationId) {
    final memoryCached = getLoadedTranslation(translationId);
    if (memoryCached != null) return Future.value(memoryCached);

    return _inFlight.putIfAbsent(
      translationId,
      () => _doLoadLocalBible(
        translationId,
      ).whenComplete(() => _inFlight.remove(translationId)),
    );
  }

  Future<List<BibleBook>> _doLoadLocalBible(String translationId) async {
    final memoryCached = getLoadedTranslation(translationId);
    if (memoryCached != null) return memoryCached;

    if (await _isCacheValid(translationId)) {
      final path = await _sqlitePathFor(translationId);
      final translationDb = await _dbManager.open(translationId, path);
      final books = await translationDb.getBible();
      if (books.isNotEmpty) {
        return _rememberLoadedTranslation(translationId, books);
      }
    }

    try {
      final translation = await _getTranslation(translationId);
      await _invalidateCache(translationId);

      if (_isImportedSqliteTranslation(translation)) {
        await _restoreImportedSqliteCache(
          translationId: translationId,
          translation: translation,
        );
        await _db.updateInstalledTranslationParserVersion(
          translationId,
          _currentParserVersion,
        );
        final path = await _sqlitePathFor(translationId);
        final translationDb = await _dbManager.open(translationId, path);
        final books = await translationDb.getBible();
        if (books.isEmpty) {
          throw Exception(
            'Imported SQLite translation ${translation.id} did not contain any Bible books.',
          );
        }
        return _rememberLoadedTranslation(translationId, books);
      }

      final content = await _loadLocalContent(translation);
      final parsed = await compute(_parseBibleToSerializable, content);
      final books = parsed.map(_mapSerializableBook).toList();

      final path = await _sqlitePathFor(translationId);
      final translationDb = await _dbManager.open(translationId, path);
      await translationDb.insertBible(books);

      await _db.upsertInstalledTranslation(
        translation: translation,
        sourceLocation: _sourceLocationForTranslation(translation),
        sourceTypeOverride: translation.sourceType,
      );
      await _db.updateInstalledTranslationParserVersion(
        translationId,
        _currentParserVersion,
      );

      return _rememberLoadedTranslation(translationId, books);
    } catch (e) {
      throw Exception('Failed to load local Bible: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Load — single chapter (on-demand verse hydration)
  // ---------------------------------------------------------------------------

  Future<BibleChapter?> loadChapterVerses(
    String translationId,
    String bookId,
    int chapterNumber,
  ) async {
    final path = await _sqlitePathFor(translationId);
    if (usesFileBackedStorage && !await pathExists(path)) return null;
    final translationDb = await _dbManager.open(translationId, path);
    return translationDb.getChapter(bookId, chapterNumber);
  }

  // ---------------------------------------------------------------------------
  // Download
  // ---------------------------------------------------------------------------

  Future<List<BibleBook>> downloadBible(String translationId) async {
    final memoryCached = getLoadedTranslation(translationId);
    if (memoryCached != null) return memoryCached;

    if (await _isCacheValid(translationId)) {
      final path = await _sqlitePathFor(translationId);
      final translationDb = await _dbManager.open(translationId, path);
      final books = await translationDb.getBible();
      if (books.isNotEmpty) {
        return _rememberLoadedTranslation(translationId, books);
      }
    }

    await _invalidateCache(translationId);

    final translation = await _getTranslation(
      translationId,
      includeRemoteCatalog: true,
    );
    final artifact = firstPreferredRemoteArtifact(
      translation,
      supportedFormats: _downloadSupportedFormats,
    );
    if (artifact == null) {
      throw Exception(
        'No supported download artifact is available for ${translation.name}.',
      );
    }

    try {
      final response = await http.get(Uri.parse(artifact.downloadUrl));
      if (response.statusCode != 200) {
        throw Exception(
          'Failed to download Bible: HTTP ${response.statusCode}',
        );
      }

      final books = await _installDownloadedArtifact(
        translationId: translationId,
        artifact: artifact,
        responseBody: response.bodyBytes,
      );

      final downloadedTranslation = BibleTranslation(
        id: translation.id,
        name: translation.name,
        language: translation.language,
        languageName: translation.languageName,
        description: translation.description,
        isLocal: true,
        githubUrl: artifact.downloadUrl,
        format: artifact.format,
        sourceType: BibleSourceType.download,
        bundledByDefault: translation.bundledByDefault,
        displayOrder: translation.displayOrder,
        artifacts: translation.artifacts,
      );

      await _db.upsertInstalledTranslation(
        translation: downloadedTranslation,
        sourceLocation: artifact.downloadUrl,
        sourceTypeOverride: BibleSourceType.download,
      );
      await _db.updateInstalledTranslationParserVersion(
        translationId,
        _currentParserVersion,
      );
      _sessionTranslationIds.remove(translationId);

      return _rememberLoadedTranslation(translationId, books);
    } catch (e) {
      throw Exception('Failed to download Bible: $e');
    }
  }

  Future<List<BibleBook>> openTranslationForSession(
    String translationId,
  ) async {
    final memoryCached = getLoadedTranslation(translationId);
    if (memoryCached != null &&
        _sessionTranslationIds.contains(translationId)) {
      return memoryCached;
    }

    final translation = await _getTranslation(
      translationId,
      includeRemoteCatalog: true,
    );
    final artifact = firstPreferredRemoteArtifact(
      translation,
      supportedFormats: _sessionReadableFormats,
    );
    if (artifact == null) {
      throw Exception(
        'Session read is not available for ${translation.name} yet. Download it first instead.',
      );
    }

    final response = await http.get(Uri.parse(artifact.downloadUrl));
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to open ${translation.name}: HTTP ${response.statusCode}',
      );
    }

    final books = await _parseBibleBytes(response.bodyBytes);
    if (books.isEmpty) {
      throw Exception(
        'The remote translation ${translation.name} did not contain any Bible books.',
      );
    }

    _sessionTranslationIds.add(translationId);
    return _rememberLoadedTranslation(translationId, books);
  }

  // ---------------------------------------------------------------------------
  // Import
  // ---------------------------------------------------------------------------

  Future<BibleTranslation> importBibleFromFile(String filePath) async {
    final draft = await prepareBibleImport(filePath);
    return importPreparedBible(
      BibleImportRequest(
        filePath: draft.filePath,
        format: draft.format,
        importedBooks: draft.importedBooks,
        id: draft.suggestedId,
        name: draft.suggestedName,
        language: draft.suggestedLanguage.isEmpty
            ? 'unknown'
            : draft.suggestedLanguage,
        description: draft.suggestedDescription,
      ),
    );
  }

  Future<BibleImportDraft> prepareBibleImport(String filePath) async {
    if (!supportsDirectFileImport) {
      throw Exception(
        'Importing local Bible files is not available on web yet.',
      );
    }
    if (!await pathExists(filePath)) {
      throw Exception('Selected Bible file does not exist.');
    }

    late final BibleFormat detectedFormat;
    late final List<BibleBook> importedBooks;
    if (_isLikelyZipFile(filePath)) {
      throw Exception(
        'ZIP Bible import is recognized but not connected yet. The planned pipeline will support single-file archives and split-book USFM/XML packages after the external import backend is added.',
      );
    } else if (_isLikelyUsfmFile(filePath)) {
      throw Exception(
        'USFM import is planned but the USFM parser backend is not connected yet.',
      );
    } else if (_isLikelySqliteFile(filePath)) {
      detectedFormat = BibleFormat.sqlite;
      importedBooks = await _readBibleFromSqlite(filePath);
    } else {
      final content = await readTextFile(filePath);
      final parsed = await compute(_parseBibleToSerializable, content);
      importedBooks = parsed.map(_mapSerializableBook).toList();
      detectedFormat = _detectFormatFromContent(content);
    }

    if (importedBooks.isEmpty) {
      throw Exception('The selected file did not contain any Bible books.');
    }

    final translation = await _buildImportedTranslation(
      filePath: filePath,
      format: detectedFormat,
      importedBooks: importedBooks,
    );

    return BibleImportDraft(
      filePath: filePath,
      fileName: p.basename(filePath),
      format: detectedFormat,
      importedBooks: importedBooks,
      suggestedId: translation.id,
      suggestedName: translation.name,
      suggestedLanguage: _suggestLanguageCode(filePath),
      suggestedDescription: translation.description,
    );
  }

  Future<BibleTranslation> importPreparedBible(
    BibleImportRequest request,
  ) async {
    if (request.importedBooks.isEmpty) {
      throw Exception('The selected file did not contain any Bible books.');
    }

    final normalizedId = _sanitizeTranslationId(request.id);
    if (normalizedId.isEmpty) {
      throw Exception('Please enter a valid abbreviation.');
    }
    await _ensureTranslationIdAvailable(normalizedId);
    final managedImportPath = await _persistImportedSource(
      originalPath: request.filePath,
      translationId: normalizedId,
    );

    final translation = BibleTranslation(
      id: normalizedId,
      name: request.name.trim(),
      language: request.language.trim(),
      // Leave languageName empty so effectiveLanguageName falls back to the
      // language code. A human-readable name isn't known at import time.
      description: request.description.trim(),
      isLocal: true,
      filePath: managedImportPath,
      format: request.format,
      sourceType: BibleSourceType.import,
    );

    if (request.format == BibleFormat.sqlite) {
      await _installImportedSqlite(
        translationId: normalizedId,
        managedImportPath: managedImportPath,
      );
    } else {
      final path = await _sqlitePathFor(normalizedId);
      final translationDb = await _dbManager.open(normalizedId, path);
      await translationDb.insertBible(request.importedBooks);
    }

    await _db.upsertInstalledTranslation(
      translation: translation,
      sourceLocation: managedImportPath,
      sourceTypeOverride: BibleSourceType.import,
    );
    await _db.updateInstalledTranslationParserVersion(
      normalizedId,
      _currentParserVersion,
    );

    _rememberLoadedTranslation(normalizedId, request.importedBooks);
    return translation;
  }

  // ---------------------------------------------------------------------------
  // Delete / remove
  // ---------------------------------------------------------------------------

  Future<void> deleteImportedTranslation(String translationId) async {
    final stored = await _db.getInstalledTranslations();
    final translation = stored.firstWhere(
      (t) => t.id == translationId,
      orElse: () =>
          throw Exception('Translation $translationId was not found.'),
    );

    if (translation.sourceType != BibleSourceType.import) {
      throw Exception('Only imported translations can be deleted.');
    }

    await _invalidateCache(translationId);
    await _deleteManagedImportSnapshot(translation);
    await _db.deleteInstalledTranslation(translationId);
    _memoryCacheByTranslation.remove(translationId);
    _sessionTranslationIds.remove(translationId);
    if (_currentTranslationId == translationId) {
      _currentTranslationId = null;
      _cachedBooks = [];
    }
  }

  Future<void> removeDownloadedTranslation(String translationId) async {
    final stored = await _db.getInstalledTranslations();
    final translation = stored.firstWhere(
      (t) => t.id == translationId,
      orElse: () =>
          throw Exception('Translation $translationId was not found.'),
    );

    if (translation.sourceType != BibleSourceType.download) {
      throw Exception('Only downloaded translations can be removed.');
    }

    // Delete the content file but keep the registry row (marks as not local).
    await _invalidateCache(translationId);
    await _db.upsertInstalledTranslation(
      translation: BibleTranslation(
        id: translation.id,
        name: translation.name,
        language: translation.language,
        languageName: translation.languageName,
        description: translation.description,
        isLocal: false,
        githubUrl: translation.githubUrl,
        format: translation.format,
        sourceType: BibleSourceType.download,
        bundledByDefault: translation.bundledByDefault,
        displayOrder: translation.displayOrder,
        artifacts: translation.artifacts,
      ),
      sourceLocation: translation.githubUrl,
      sourceTypeOverride: BibleSourceType.download,
    );
    _memoryCacheByTranslation.remove(translationId);
    _sessionTranslationIds.remove(translationId);
    if (_currentTranslationId == translationId) {
      _currentTranslationId = null;
      _cachedBooks = [];
    }
  }

  // ---------------------------------------------------------------------------
  // In-memory accessors
  // ---------------------------------------------------------------------------

  BibleBook? getBook(String bookId) {
    return _cachedBooks.firstWhere(
      (book) => book.id == bookId,
      orElse: () => throw Exception('Book $bookId not found'),
    );
  }

  BibleChapter? getChapter(String bookId, int chapterNumber) {
    final book = getBook(bookId);
    return book?.chapters.firstWhere(
      (chapter) => chapter.number == chapterNumber,
      orElse: () =>
          throw Exception('Chapter $chapterNumber not found in $bookId'),
    );
  }

  List<BibleVerse> getVerses(String bookId, int chapterNumber) {
    return getChapter(bookId, chapterNumber)?.verses ?? [];
  }

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

  List<BibleBook> getAllBooks() => List.unmodifiable(_cachedBooks);

  List<BibleBook>? getLoadedTranslation(String translationId) {
    final books = _memoryCacheByTranslation[translationId];
    if (books == null || books.isEmpty) return null;
    _currentTranslationId = translationId;
    _cachedBooks = books;
    return books;
  }

  String? getCurrentTranslationId() => _currentTranslationId;

  Future<bool> isCached(String translationId) async {
    return _isCacheValid(translationId);
  }

  Future<void> clearCache(String translationId) async {
    final translation = await _db.getInstalledTranslations().then(
      (rows) => rows.where((row) => row.id == translationId).firstOrNull,
    );

    await _invalidateCache(translationId);
    await _db.deleteInstalledTranslation(translationId);
    if (translation?.sourceType == BibleSourceType.import) {
      await _deleteManagedImportSnapshot(translation!);
    }
    _memoryCacheByTranslation.remove(translationId);
    _sessionTranslationIds.remove(translationId);
    if (_currentTranslationId == translationId) {
      _currentTranslationId = null;
      _cachedBooks = const [];
    }
  }

  Future<void> clearAllCache() async {
    try {
      await clearDirectoryFiles(
        await TranslationDatabaseManager.biblesDir(),
        extension: '.sqlite',
      );
    } catch (_) {}

    try {
      await clearDirectoryFiles(
        await TranslationDatabaseManager.importedSourcesDir(),
      );
    } catch (_) {}

    await _dbManager.closeAll();
    await _db.deleteAllInstalledTranslations();
    _memoryCacheByTranslation.clear();
    _sessionTranslationIds.clear();
    _currentTranslationId = null;
    _cachedBooks = const [];
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  List<BibleBook> _rememberLoadedTranslation(
    String translationId,
    List<BibleBook> books,
  ) {
    _memoryCacheByTranslation[translationId] = books;
    _cachedBooks = books;
    _currentTranslationId = translationId;
    return books;
  }

  // Getter (not static final) so usesFileBackedStorage is evaluated at call
  // time rather than once at class load, making the platform branch explicit.
  Set<BibleFormat> get _downloadSupportedFormats => <BibleFormat>{
    BibleFormat.usfx,
    BibleFormat.osis,
    BibleFormat.zefania,
    if (usesFileBackedStorage) BibleFormat.sqlite,
  };

  static const Set<BibleFormat> _sessionReadableFormats = <BibleFormat>{
    BibleFormat.usfx,
    BibleFormat.osis,
    BibleFormat.zefania,
  };

  Future<List<BibleBook>> _installDownloadedArtifact({
    required String translationId,
    required BibleTranslationArtifact artifact,
    required List<int> responseBody,
  }) async {
    switch (artifact.format) {
      case BibleFormat.sqlite:
        final path = await _sqlitePathFor(translationId);
        await writeBinaryFile(path, responseBody);
        final translationDb = await _dbManager.open(translationId, path);
        final books = await translationDb.getBible();
        if (books.isEmpty) {
          throw Exception(
            'Downloaded SQLite translation $translationId did not contain any Bible books.',
          );
        }
        return books;
      case BibleFormat.usfx:
      case BibleFormat.osis:
      case BibleFormat.zefania:
        final books = await _parseBibleBytes(responseBody);
        final path = await _sqlitePathFor(translationId);
        final translationDb = await _dbManager.open(translationId, path);
        await translationDb.insertBible(books);
        return books;
      case BibleFormat.usfm:
      case BibleFormat.usfmDirectory:
      case BibleFormat.zip:
      case BibleFormat.auto:
        throw Exception(
          'The ${artifact.format.name} download path is not connected yet.',
        );
    }
  }

  Future<List<BibleBook>> _parseBibleBytes(List<int> bytes) async {
    final content = utf8.decode(bytes);
    final parsed = await compute(_parseBibleToSerializable, content);
    return parsed.map(_mapSerializableBook).toList();
  }

  Future<String> _persistImportedSource({
    required String originalPath,
    required String translationId,
  }) async {
    if (!supportsDirectFileImport) {
      throw Exception(
        'Importing local Bible files is not available on web yet.',
      );
    }
    if (!await pathExists(originalPath)) {
      throw Exception('Selected Bible file does not exist.');
    }

    final destinationPath =
        await TranslationDatabaseManager.pathForImportedSource(
          translationId,
          extension: p.extension(originalPath),
        );
    await copyFile(originalPath, destinationPath);
    return destinationPath;
  }

  Future<void> _deleteManagedImportSnapshot(
    BibleTranslation translation,
  ) async {
    final filePath = translation.filePath;
    if (filePath == null || filePath.isEmpty) return;

    try {
      await deleteFileIfExists(filePath);
    } catch (_) {}
  }

  String? _sourceLocationForTranslation(BibleTranslation translation) {
    return switch (translation.sourceType) {
      BibleSourceType.asset || BibleSourceType.import => translation.filePath,
      BibleSourceType.session => translation.githubUrl,
      BibleSourceType.download => translation.githubUrl,
    };
  }

  Future<BibleTranslation> _getTranslation(
    String translationId, {
    bool includeRemoteCatalog = false,
  }) async {
    final stored = await _db.getInstalledTranslations();
    final builtIn = builtInTranslations
        .where((t) => t.id == translationId)
        .firstOrNull;
    final storedMatch = stored.where((t) => t.id == translationId).firstOrNull;
    final remote = includeRemoteCatalog
        ? (await _fetchRemoteTranslationsSafely())
              .where((t) => t.id == translationId)
              .firstOrNull
        : null;

    if (builtIn != null) {
      return _applySessionState(
        _mergeStoredTranslation(
          base: _mergeCatalogTranslation(builtIn: builtIn, remote: remote),
          stored: storedMatch,
        ),
      );
    }
    if (storedMatch != null) {
      return _applySessionState(
        _mergeStoredTranslation(
          base: remote ?? storedMatch,
          stored: storedMatch,
        ),
      );
    }

    if (remote != null) return _applySessionState(remote);
    throw Exception('Translation $translationId not found');
  }

  Future<List<BibleTranslation>> _fetchRemoteTranslationsSafely() async {
    try {
      return await _catalogService.fetchTranslations();
    } catch (e) {
      assert(() {
        debugPrint('[AppBibleRepository] Remote catalog fetch failed: $e');
        return true;
      }());
      return const <BibleTranslation>[];
    }
  }

  BibleTranslation _mergeCatalogTranslation({
    required BibleTranslation builtIn,
    BibleTranslation? remote,
  }) {
    if (remote == null) return builtIn;
    return builtIn.copyWith(
      name: remote.name,
      language: remote.language,
      languageName: remote.languageName,
      description: remote.description,
      githubUrl: remote.githubUrl ?? builtIn.githubUrl,
      format: remote.format == BibleFormat.auto
          ? builtIn.format
          : remote.format,
      bundledByDefault: remote.bundledByDefault || builtIn.bundledByDefault,
      displayOrder: remote.displayOrder,
      artifacts: remote.artifacts.isEmpty
          ? builtIn.artifacts
          : remote.artifacts,
    );
  }

  BibleTranslation _mergeStoredTranslation({
    required BibleTranslation base,
    required BibleTranslation? stored,
  }) {
    if (stored == null) return base;
    // Build directly instead of copyWith so that filePath can be explicitly
    // cleared to null for download/session types (copyWith can't pass null).
    final resolvedFilePath = switch (stored.sourceType) {
      BibleSourceType.asset => base.filePath,
      BibleSourceType.import => stored.filePath,
      BibleSourceType.download || BibleSourceType.session => null,
    };
    return BibleTranslation(
      id: base.id,
      name: stored.name,
      language: stored.language,
      languageName: stored.languageName.isNotEmpty
          ? stored.languageName
          : base.languageName,
      description: stored.description,
      isLocal: stored.isLocal,
      filePath: resolvedFilePath,
      githubUrl: stored.githubUrl ?? base.githubUrl,
      format: stored.format == BibleFormat.auto ? base.format : stored.format,
      sourceType: stored.sourceType,
      bundledByDefault: base.bundledByDefault,
      displayOrder: base.displayOrder,
      artifacts: base.artifacts,
    );
  }

  BibleTranslation _applySessionState(BibleTranslation translation) {
    if (!_sessionTranslationIds.contains(translation.id)) {
      return translation;
    }
    return translation.copyWith(
      isLocal: false,
      sourceType: BibleSourceType.session,
    );
  }

  Future<String> _loadLocalContent(BibleTranslation translation) async {
    return switch (translation.sourceType) {
      BibleSourceType.asset => _loadAssetContent(translation),
      BibleSourceType.import => _loadImportedContent(translation),
      BibleSourceType.session => throw Exception(
        'Session-only translation ${translation.id} is only available in memory for the current app run.',
      ),
      BibleSourceType.download => throw Exception(
        'Downloaded translation ${translation.id} is not available locally without cache.',
      ),
    };
  }

  Future<String> _loadImportedContent(BibleTranslation translation) async {
    final filePath = translation.filePath;
    if (filePath == null || filePath.isEmpty) {
      throw Exception(
        'Imported translation ${translation.id} is missing a file path.',
      );
    }
    if (!await pathExists(filePath)) {
      throw Exception('Imported translation file was not found: $filePath');
    }
    return readTextFile(filePath);
  }

  Future<String> _loadAssetContent(BibleTranslation translation) async {
    final assetPath = translation.filePath;
    if (assetPath == null || assetPath.isEmpty) {
      throw Exception(
        'Bundled translation ${translation.id} is missing an asset path.',
      );
    }
    try {
      return await rootBundle.loadString(assetPath);
    } catch (error) {
      throw Exception(
        'Bundled translation ${translation.id} was not found at $assetPath: $error',
      );
    }
  }

  Future<BibleTranslation> _buildImportedTranslation({
    required String filePath,
    required BibleFormat format,
    required List<BibleBook> importedBooks,
  }) async {
    final storedIds =
        (await _db.getInstalledTranslations()).map((t) => t.id).toSet()
          ..addAll(builtInTranslations.map((t) => t.id));
    final baseName = p.basenameWithoutExtension(filePath);
    final sanitizedId = _sanitizeTranslationId(baseName);
    var candidateId = sanitizedId;
    var suffix = 2;
    while (storedIds.contains(candidateId)) {
      candidateId = '${sanitizedId}_$suffix';
      suffix++;
    }
    return BibleTranslation(
      id: candidateId,
      name: _buildImportedTranslationName(
        filePath: filePath,
        importedBooks: importedBooks,
      ),
      language: 'unknown',
      languageName: 'Imported',
      description: 'Imported from ${p.basename(filePath)}',
      isLocal: true,
      filePath: filePath,
      format: format,
      sourceType: BibleSourceType.import,
    );
  }

  Future<void> _ensureTranslationIdAvailable(String candidateId) async {
    final storedIds =
        (await _db.getInstalledTranslations()).map((t) => t.id).toSet()
          ..addAll(builtInTranslations.map((t) => t.id));
    if (storedIds.contains(candidateId)) {
      throw Exception(
        'A translation with the abbreviation ${candidateId.toUpperCase()} already exists.',
      );
    }
  }

  BibleFormat _detectFormatFromContent(String content) {
    final lower = content.toLowerCase();
    if (lower.contains('<usfx')) return BibleFormat.usfx;
    if (lower.contains('<osis') || lower.contains('<osistext')) {
      return BibleFormat.osis;
    }
    if (lower.contains('<xmlbible')) return BibleFormat.zefania;
    return BibleFormat.auto;
  }

  String _sanitizeTranslationId(String value) {
    final normalized = value.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]+'),
      '_',
    );
    final trimmed = normalized.replaceAll(RegExp(r'^_+|_+$'), '');
    return trimmed.isEmpty ? 'imported_bible' : trimmed;
  }

  String _buildImportedTranslationName({
    required String filePath,
    required List<BibleBook> importedBooks,
  }) {
    final baseName = p
        .basenameWithoutExtension(filePath)
        .replaceAll('_', ' ')
        .trim();
    if (baseName.isNotEmpty) return baseName;
    if (importedBooks.isNotEmpty) return '${importedBooks.first.name} Import';
    return 'Imported Bible';
  }

  String _suggestLanguageCode(String filePath) {
    final baseName = p.basenameWithoutExtension(filePath).toLowerCase();
    final prefix = baseName.split(RegExp(r'[_\-.]')).first;
    return switch (prefix) {
      'eng' || 'en' => 'en',
      'spa' || 'es' => 'es',
      'fra' || 'fre' || 'fr' => 'fr',
      'deu' || 'ger' || 'de' => 'de',
      'por' || 'pt' => 'pt',
      'ita' || 'it' => 'it',
      _ => '',
    };
  }

  bool _isLikelySqliteFile(String filePath) {
    final extension = p.extension(filePath).toLowerCase();
    return extension == '.sqlite' ||
        extension == '.db' ||
        extension == '.sqlite3';
  }

  bool _isLikelyUsfmFile(String filePath) {
    final extension = p.extension(filePath).toLowerCase();
    return extension == '.usfm' || extension == '.sfm';
  }

  bool _isLikelyZipFile(String filePath) {
    return p.extension(filePath).toLowerCase() == '.zip';
  }

  bool _isImportedSqliteTranslation(BibleTranslation translation) {
    return translation.sourceType == BibleSourceType.import &&
        translation.format == BibleFormat.sqlite;
  }

  Future<List<BibleBook>> _readBibleFromSqlite(String filePath) async {
    final translationDb = openTranslationDatabase(filePath);
    try {
      final books = await translationDb.getBible();
      if (books.isEmpty) {
        throw Exception(
          'The selected SQLite database did not contain any Bible books.',
        );
      }
      return books;
    } catch (error) {
      throw Exception('Unable to read SQLite Bible database: $error');
    } finally {
      await translationDb.close();
    }
  }

  Future<void> _installImportedSqlite({
    required String translationId,
    required String managedImportPath,
  }) async {
    final destinationPath = await _sqlitePathFor(translationId);
    await _copySqliteFile(
      sourcePath: managedImportPath,
      destinationPath: destinationPath,
      translationId: translationId,
    );
  }

  Future<void> _restoreImportedSqliteCache({
    required String translationId,
    required BibleTranslation translation,
  }) async {
    final sourcePath = translation.filePath;
    if (sourcePath == null || sourcePath.isEmpty) {
      throw Exception(
        'Imported SQLite translation ${translation.id} is missing a source file.',
      );
    }
    if (!await pathExists(sourcePath)) {
      throw Exception('Imported translation file was not found: $sourcePath');
    }

    final destinationPath = await _sqlitePathFor(translationId);
    await _copySqliteFile(
      sourcePath: sourcePath,
      destinationPath: destinationPath,
      translationId: translationId,
    );
  }

  Future<void> _copySqliteFile({
    required String sourcePath,
    required String destinationPath,
    required String translationId,
  }) async {
    _dbManager.close(translationId);
    if (!await pathExists(sourcePath)) {
      throw Exception('Selected Bible file does not exist.');
    }
    await copyFile(sourcePath, destinationPath);
  }
}

// =============================================================================
// Isolate parser — unchanged, runs in compute()
// =============================================================================

Future<List<Map<String, dynamic>>> _parseBibleToSerializable(
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
