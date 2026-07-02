import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:basic_bible/src/features/library/data/bible_import_service.dart';
import 'package:basic_bible/src/features/library/data/bible_parser_worker.dart';
import 'package:basic_bible/src/features/library/data/bible_archive_support.dart';
import 'package:basic_bible/src/features/library/data/bible_source_parser.dart';
import 'package:basic_bible/src/features/library/data/bible_translation_catalog.dart';
import 'package:basic_bible/src/features/library/data/remote_translation_catalog_service.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/services/app_database.dart';
import 'package:basic_bible/src/services/translation_database_manager.dart';

import 'library_source_io.dart';

// Re-export transfer objects so existing import sites keep working.
export 'bible_import_service.dart' show BibleImportDraft, BibleImportRequest;

part 'app_bible_repository_loading.dart';
part 'app_bible_repository_network.dart';

class AppBibleRepository {
  AppBibleRepository(this._db, this._dbManager, this._catalogService)
    : _importService = AppBibleImportService(db: _db, dbManager: _dbManager);

  final AppDatabase _db;
  final TranslationDatabaseManager _dbManager;
  final RemoteTranslationCatalogService _catalogService;
  final AppBibleImportService _importService;

  // In-memory cache: single source of truth for loaded books.
  final Map<String, List<BibleBook>> _memoryCacheByTranslation = {};
  final LinkedHashMap<String, List<BibleBook>> _fullTranslationLru =
      LinkedHashMap<String, List<BibleBook>>();
  final Map<String, LinkedHashMap<String, BibleChapter>> _chapterCacheByTranslation =
      {};
  final Set<String> _sessionTranslationIds = {};
  String? _currentTranslationId;
  List<BibleBook> _currentBooks = [];
  // Set to true whenever a file-backed translation is added or removed so that
  // _reconcileStoredTranslations runs exactly once per structural change rather
  // than on every getAvailableTranslations() call.
  bool _storedTranslationsDirty = true;

  // In-flight guards: shared Futures prevent concurrent parses/downloads of
  // the same translation racing to write the same SQLite file.
  final Map<String, Future<List<BibleBook>>> _inFlight = {};
  final Map<String, Future<List<BibleBook>>> _downloadInFlight = {};
  final Map<String, Future<List<BibleBook>>> _sessionReadInFlight = {};

  static const Duration _remoteRequestTimeout = Duration(seconds: 20);
  static const int _maxFullTranslationCacheCount = 2;
  static const int _maxChapterCacheEntriesPerTranslation = 12;

  // Shared client so downloads reuse connections instead of opening a fresh
  // one per request (top-level http.get creates a new client every call).
  static final http.Client _httpClient = http.Client();

  /// Delegates to the catalog constant so existing call sites keep working.
  static List<BibleTranslation> get builtInTranslations => kBuiltInTranslations;

  // ---------------------------------------------------------------------------
  // Available translations
  // ---------------------------------------------------------------------------

  Future<List<BibleTranslation>> getAvailableTranslations() async {
    var stored = await _db.getInstalledTranslations();
    if (_storedTranslationsDirty) {
      stored = await _reconcileStoredTranslations(stored);
      _storedTranslationsDirty = false;
    }
    final remote = await _fetchRemoteTranslationsSafely();
    final builtInIds = builtInTranslations.map((t) => t.id).toSet();
    final remoteById = {for (final t in remote) t.id: t};
    final storedById = {for (final t in stored) t.id: t};

    final mergedBuiltIns = [
      for (final t in builtInTranslations)
        applySessionState(
          mergeStoredTranslation(
            base: mergeCatalogTranslation(
              builtIn: t,
              remote: remoteById[t.id],
            ),
            stored: storedById[t.id],
            overrideSourceType: true,
          ),
          _sessionTranslationIds,
        ),
    ];
    final remainingIds = {...remoteById.keys, ...storedById.keys}
      ..removeAll(builtInIds);

    return [
      ...mergedBuiltIns,
      for (final id in remainingIds)
        applySessionState(
          mergeStoredTranslation(
            base: remoteById[id] ?? storedById[id]!,
            stored: storedById[id],
          ),
          _sessionTranslationIds,
        ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Import — thin wrappers; AppBibleImportService owns the implementation
  // ---------------------------------------------------------------------------

  Future<BibleImportDraft> prepareBibleImport(String filePath) =>
      _importService.prepareBibleImport(filePath);

  Future<BibleTranslation> importBibleFromFile(String filePath) async {
    final result = await _importService.importBibleFromFile(filePath);
    _rememberLoadedTranslation(result.translation.id, result.books);
    return result.translation;
  }

  Future<BibleTranslation> importPreparedBible(
    BibleImportRequest request,
  ) async {
    final result = await _importService.importPreparedBible(request);
    _rememberLoadedTranslation(result.translation.id, result.books);
    return result.translation;
  }

  // ---------------------------------------------------------------------------
  // Delete / remove
  // ---------------------------------------------------------------------------

  Future<void> deleteImportedTranslation(String translationId) async {
    final stored = await _db.getInstalledTranslations();
    final translation = stored.firstWhere(
      (t) => t.id == translationId,
      orElse: () => throw Exception('Translation $translationId not found.'),
    );
    if (translation.sourceType != BibleSourceType.import) {
      throw Exception('Only imported translations can be deleted.');
    }
    await _invalidateCache(translationId);
    await _importService.deleteSourceFile(translation);
    await _db.deleteInstalledTranslation(translationId);
    _evictFromCache(translationId);
  }

  Future<void> removeDownloadedTranslation(String translationId) async {
    final stored = await _db.getInstalledTranslations();
    final storedTranslation = stored.firstWhere(
      (t) => t.id == translationId,
      orElse: () => throw Exception('Translation $translationId not found.'),
    );

    BibleTranslation? catalogTranslation;
    try {
      catalogTranslation = await _getTranslation(
        translationId,
        includeRemoteCatalog: true,
      );
    } catch (_) {
      catalogTranslation = null;
    }

    final effectiveTranslation = catalogTranslation ?? storedTranslation;
    if (effectiveTranslation.sourceType == BibleSourceType.import ||
        storedTranslation.sourceType == BibleSourceType.import) {
      throw Exception('Imported translations must be deleted, not removed as downloads.');
    }
    if (effectiveTranslation.sourceType == BibleSourceType.asset ||
        effectiveTranslation.bundledByDefault) {
      throw Exception('Bundled translations cannot be removed.');
    }

    await _invalidateCache(translationId);

    final resetTranslation = BibleTranslation(
      id: effectiveTranslation.id,
      name: effectiveTranslation.name,
      language: effectiveTranslation.language,
      languageName: effectiveTranslation.languageName,
      description: effectiveTranslation.description,
      isLocal: false,
      githubUrl:
          effectiveTranslation.githubUrl ?? storedTranslation.githubUrl,
      format: effectiveTranslation.format,
      sourceType: BibleSourceType.download,
      bundledByDefault: effectiveTranslation.bundledByDefault,
      displayOrder: effectiveTranslation.displayOrder,
      artifacts: effectiveTranslation.artifacts,
    );

    // Keep the registry row marked as not-local so the Download action shows.
    await _db.upsertInstalledTranslation(
      translation: resetTranslation,
      sourceLocation: resetTranslation.githubUrl,
      sourceTypeOverride: BibleSourceType.download,
    );
    _evictFromCache(translationId);
  }

  // ---------------------------------------------------------------------------
  // In-memory read accessors
  // ---------------------------------------------------------------------------

  // FIX #4: non-nullable return type to match actual behavior (always throws).
  BibleBook getBook(String bookId) {
    return _currentBooks.firstWhere(
      (book) => book.id == bookId,
      orElse: () => throw Exception('Book $bookId not found'),
    );
  }

  BibleChapter? getChapter(String bookId, int chapterNumber) {
    return getBook(bookId).chapters.firstWhere(
      (c) => c.number == chapterNumber,
      orElse: () =>
          throw Exception('Chapter $chapterNumber not found in $bookId'),
    );
  }

  List<BibleVerse> getVerses(String bookId, int chapterNumber) =>
      getChapter(bookId, chapterNumber)?.verses ?? [];

  List<BibleVerse> searchText(String query, {String? bookId}) {
    final results = <BibleVerse>[];
    final q = query.toLowerCase();
    final booksToSearch = bookId != null
        ? [
            _currentBooks.firstWhere(
              (b) => b.id == bookId,
              orElse: () => throw Exception('Book $bookId not found'),
            ),
          ]
        : _currentBooks;
    for (final book in booksToSearch) {
      for (final chapter in book.chapters) {
        for (final verse in chapter.verses) {
          if (verse.text.toLowerCase().contains(q)) results.add(verse);
        }
      }
    }
    return results;
  }

  List<BibleBook> getAllBooks() => List.unmodifiable(_currentBooks);
  String? getCurrentTranslationId() => _currentTranslationId;
  Future<bool> isCached(String translationId) => _isCacheValid(translationId);

  // FIX #1: pure query — no side effects on _currentTranslationId/_currentBooks.
  List<BibleBook>? peekLoadedTranslation(String translationId) {
    final books = _memoryCacheByTranslation[translationId];
    return (books == null || books.isEmpty) ? null : books;
  }

  /// Activates a cached translation as the current one without reloading.
  /// Call when switching to a translation already in memory so that getBook()
  /// and getAllBooks() reflect the correct data immediately.
  void activateLoadedTranslation(String translationId) {
    final books = _memoryCacheByTranslation[translationId];
    if (books != null && books.isNotEmpty) {
      _touchLoadedTranslation(translationId);
      _currentTranslationId = translationId;
      _currentBooks = books;
    }
  }

  // ---------------------------------------------------------------------------
  // Fallback resolution
  // ---------------------------------------------------------------------------

  Future<String> resolveReadableTranslationId(String preferredId) async {
    // FIX #1: peek does not mutate active translation state.
    if (peekLoadedTranslation(preferredId) != null) return preferredId;
    final preferred = await _getTranslation(preferredId);
    if (await _canReadWithoutNetwork(preferred)) return preferredId;
    if (preferredId != 'kjv') {
      final kjv = builtInTranslations.firstWhere(
        (t) => t.id == 'kjv',
        orElse: () => builtInTranslations.first,
      );
      if (await _canReadWithoutNetwork(kjv)) return kjv.id;
    }
    for (final t in builtInTranslations) {
      if (await _canReadWithoutNetwork(t)) return t.id;
    }
    return preferredId;
  }

  // ---------------------------------------------------------------------------
  // Cache management
  // ---------------------------------------------------------------------------

  Future<void> clearCache(String translationId) async {
    final translation = await _db.getInstalledTranslations().then(
      (rows) => rows.where((r) => r.id == translationId).firstOrNull,
    );
    await _invalidateCache(translationId);
    await _db.deleteInstalledTranslation(translationId);
    if (translation?.sourceType == BibleSourceType.import) {
      await _importService.deleteSourceFile(translation!);
    }
    _evictFromCache(translationId);
  }

  Future<void> clearAllCache() async {
    // FIX #9: log errors instead of silently swallowing them.
    try {
      await clearDirectoryFiles(
        await TranslationDatabaseManager.biblesDir(),
        extension: '.sqlite',
      );
    } catch (e) {
      assert(() {
        debugPrint('[AppBibleRepository] clearAllCache – bibles dir: $e');
        return true;
      }());
    }
    try {
      await clearDirectoryFiles(
        await TranslationDatabaseManager.importedSourcesDir(),
      );
    } catch (e) {
      assert(() {
        debugPrint('[AppBibleRepository] clearAllCache – imports dir: $e');
        return true;
      }());
    }
    await _dbManager.closeAll();
    await _db.deleteAllInstalledTranslations();
    _memoryCacheByTranslation.clear();
    _fullTranslationLru.clear();
    _chapterCacheByTranslation.clear();
    _sessionTranslationIds.clear();
    _currentTranslationId = null;
    _currentBooks = const [];
    _storedTranslationsDirty = true;
  }

  Future<List<BibleTranslation>> _reconcileStoredTranslations(
    List<BibleTranslation> stored,
  ) async {
    final reconciled = <BibleTranslation>[];
    for (final translation in stored) {
      if (translation.sourceType == BibleSourceType.download &&
          translation.isLocal &&
          !await _isCacheValid(translation.id)) {
        final staleDownload = translation.copyWith(
          isLocal: false,
          sourceType: BibleSourceType.download,
        );
        await _db.upsertInstalledTranslation(
          translation: staleDownload,
          sourceLocation: translation.githubUrl,
          sourceTypeOverride: BibleSourceType.download,
        );
        _evictFromCache(translation.id);
        reconciled.add(staleDownload);
        continue;
      }
      reconciled.add(translation);
    }
    return reconciled;
  }

  // ---------------------------------------------------------------------------
  // Private infrastructure helpers
  // ---------------------------------------------------------------------------

  Future<String> _sqlitePathFor(String id) =>
      TranslationDatabaseManager.pathForTranslation(id);

  Future<bool> _isCacheValid(String translationId) async {
    final meta = await _db.getInstalledTranslation(translationId);
    if (meta == null || meta.parserVersion < kCurrentParserVersion) return false;
    if (!usesFileBackedStorage) return true;
    return pathExists(await _sqlitePathFor(translationId));
  }

  Future<void> _invalidateCache(String translationId) async {
    _dbManager.close(translationId);
    if (!usesFileBackedStorage) {
      final path = await _sqlitePathFor(translationId);
      final db = await _dbManager.open(translationId, path);
      await db.clearBible();
      _dbManager.close(translationId);
      return;
    }
    await deleteFileIfExists(await _sqlitePathFor(translationId));
  }

  void _evictFromCache(String translationId) {
    _memoryCacheByTranslation.remove(translationId);
    _fullTranslationLru.remove(translationId);
    _chapterCacheByTranslation.remove(translationId);
    _sessionTranslationIds.remove(translationId);
    if (_currentTranslationId == translationId) {
      _currentTranslationId = null;
      _currentBooks = const [];
    }
    _storedTranslationsDirty = true;
  }

  List<BibleBook> _rememberLoadedTranslation(
    String translationId,
    List<BibleBook> books,
  ) {
    _memoryCacheByTranslation[translationId] = books;
    _fullTranslationLru.remove(translationId);
    _fullTranslationLru[translationId] = books;
    _trimFullTranslationCache();
    _currentTranslationId = translationId;
    _currentBooks = books;
    return books;
  }

  void _touchLoadedTranslation(String translationId) {
    final books = _fullTranslationLru.remove(translationId);
    if (books != null) {
      _fullTranslationLru[translationId] = books;
    }
  }

  void _trimFullTranslationCache() {
    while (_fullTranslationLru.length > _maxFullTranslationCacheCount) {
      final oldestTranslationId = _fullTranslationLru.keys.first;
      if (oldestTranslationId == _currentTranslationId) {
        final currentBooks = _fullTranslationLru.remove(oldestTranslationId);
        if (currentBooks != null) {
          _fullTranslationLru[oldestTranslationId] = currentBooks;
        }
        if (_fullTranslationLru.length <= _maxFullTranslationCacheCount) {
          break;
        }
        continue;
      }
      _memoryCacheByTranslation.remove(oldestTranslationId);
      _fullTranslationLru.remove(oldestTranslationId);
      _chapterCacheByTranslation.remove(oldestTranslationId);
    }
  }

  BibleChapter? _lookupCachedChapter(
    String translationId,
    String bookId,
    int chapterNumber,
  ) {
    final translationCache = _chapterCacheByTranslation[translationId];
    if (translationCache == null) return null;
    final cacheKey = '$bookId:$chapterNumber';
    final chapter = translationCache.remove(cacheKey);
    if (chapter != null) {
      translationCache[cacheKey] = chapter;
    }
    return chapter;
  }

  BibleChapter _rememberHydratedChapter(
    String translationId,
    String bookId,
    BibleChapter chapter,
  ) {
    final translationCache = _chapterCacheByTranslation.putIfAbsent(
      translationId,
      () => LinkedHashMap<String, BibleChapter>(),
    );
    final cacheKey = '$bookId:${chapter.number}';
    translationCache.remove(cacheKey);
    translationCache[cacheKey] = chapter;
    while (translationCache.length > _maxChapterCacheEntriesPerTranslation) {
      translationCache.remove(translationCache.keys.first);
    }
    return chapter;
  }

  // ---------------------------------------------------------------------------
  // Private catalog helpers (used by both loading and network extensions)
  // ---------------------------------------------------------------------------

  Future<BibleTranslation> _getTranslation(
    String translationId, {
    bool includeRemoteCatalog = false,
  }) async {
    final builtIn =
        builtInTranslations.where((t) => t.id == translationId).firstOrNull;
    final storedMatch = await _db.getInstalledTranslationModel(translationId);
    final remote = includeRemoteCatalog
        ? (await _fetchRemoteTranslationsSafely())
              .where((t) => t.id == translationId)
              .firstOrNull
        : null;

    if (builtIn != null) {
      return applySessionState(
        mergeStoredTranslation(
          base: mergeCatalogTranslation(builtIn: builtIn, remote: remote),
          stored: storedMatch,
          overrideSourceType: true,
        ),
        _sessionTranslationIds,
      );
    }
    if (storedMatch != null) {
      return applySessionState(
        mergeStoredTranslation(
          base: remote ?? storedMatch,
          stored: storedMatch,
        ),
        _sessionTranslationIds,
      );
    }
    if (remote != null) return applySessionState(remote, _sessionTranslationIds);
    throw Exception('Translation $translationId not found');
  }

  // FIX #7: apply the same timeout used for artifact fetches.
  Future<List<BibleTranslation>> _fetchRemoteTranslationsSafely() async {
    try {
      return await _catalogService
          .fetchTranslations()
          .timeout(_remoteRequestTimeout);
    } catch (e) {
      assert(() {
        debugPrint('[AppBibleRepository] Remote catalog fetch failed: $e');
        return true;
      }());
      return const <BibleTranslation>[];
    }
  }
}
