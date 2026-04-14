part of 'app_bible_repository.dart';

// All imports come from the parent library (app_bible_repository.dart).
// Private members of AppBibleRepository are accessible here because this file
// is part of the same library.

extension AppBibleRepositoryLoading on AppBibleRepository {
  // ---------------------------------------------------------------------------
  // Shell load (books + chapter metadata, no verses)
  // ---------------------------------------------------------------------------

  Future<List<BibleBook>> loadLocalBibleShell(String translationId) async {
    final memoryCached = peekLoadedTranslation(translationId);
    if (memoryCached != null) {
      return _rememberLoadedTranslation(translationId, memoryCached);
    }

    if (await _isCacheValid(translationId)) {
      final path = await _sqlitePathFor(translationId);
      final translationDb = await _dbManager.open(translationId, path);
      final shell = await translationDb.getBooksShell();
      if (shell.isNotEmpty) return shell;
    }

    return loadLocalBible(translationId);
  }

  // ---------------------------------------------------------------------------
  // Full load (parses XML if needed, in-flight dedup via _inFlight map)
  // ---------------------------------------------------------------------------

  Future<List<BibleBook>> loadLocalBible(String translationId) {
    final memoryCached = peekLoadedTranslation(translationId);
    if (memoryCached != null) {
      return Future.value(_rememberLoadedTranslation(translationId, memoryCached));
    }
    return _inFlight.putIfAbsent(
      translationId,
      () => _doLoadLocalBible(translationId)
          .whenComplete(() => _inFlight.remove(translationId)),
    );
  }

  Future<List<BibleBook>> _doLoadLocalBible(String translationId) async {
    final memoryCached = peekLoadedTranslation(translationId);
    if (memoryCached != null) {
      return _rememberLoadedTranslation(translationId, memoryCached);
    }

    if (await _isCacheValid(translationId)) {
      final path = await _sqlitePathFor(translationId);
      final translationDb = await _dbManager.open(translationId, path);
      final books = await translationDb.getBible();
      if (books.isNotEmpty) return _rememberLoadedTranslation(translationId, books);
    }

    try {
      final translation = await _getTranslation(translationId);
      await _invalidateCache(translationId);

      if (_isImportedSqliteTranslation(translation)) {
        await _restoreImportedSqliteCache(translation: translation);
        await _db.updateInstalledTranslationParserVersion(
          translationId,
          kCurrentParserVersion,
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
      final parsed = await compute(parseBibleToSerializable, content);
      final books = parsed.map(mapSerializableBook).toList();

      final path = await _sqlitePathFor(translationId);
      final translationDb = await _dbManager.open(translationId, path);
      await translationDb.insertBible(books);

      await _db.upsertInstalledTranslation(
        translation: translation,
        sourceLocation: sourceLocationForTranslation(translation),
        sourceTypeOverride: translation.sourceType,
      );
      await _db.updateInstalledTranslationParserVersion(
        translationId,
        kCurrentParserVersion,
      );

      return _rememberLoadedTranslation(translationId, books);
    } catch (e) {
      throw Exception('Failed to load local Bible: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Chapter load (on-demand verse hydration)
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

  /// Loads from local storage only. Never makes a network request.
  Future<List<BibleBook>> loadBibleForReading(String translationId) =>
      loadLocalBible(translationId);

  // ---------------------------------------------------------------------------
  // Local content helpers
  // ---------------------------------------------------------------------------

  Future<bool> _canReadWithoutNetwork(BibleTranslation translation) async {
    return switch (translation.sourceType) {
      BibleSourceType.asset => true,
      BibleSourceType.session =>
        peekLoadedTranslation(translation.id) != null,
      BibleSourceType.download => _isCacheValid(translation.id),
      BibleSourceType.import => await _isCacheValid(translation.id) ||
          (translation.filePath != null &&
              translation.filePath!.isNotEmpty &&
              await pathExists(translation.filePath!)),
    };
  }

  Future<String> _loadLocalContent(BibleTranslation translation) {
    return switch (translation.sourceType) {
      BibleSourceType.asset => _loadAssetContent(translation),
      BibleSourceType.import => _loadImportedContent(translation),
      BibleSourceType.session => throw Exception(
        'Session-only translation ${translation.id} is only available in memory.',
      ),
      BibleSourceType.download => throw Exception(
        'Downloaded translation ${translation.id} is not cached locally.',
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
        'Bundled translation ${translation.id} not found at $assetPath: $error',
      );
    }
  }

  bool _isImportedSqliteTranslation(BibleTranslation translation) =>
      translation.sourceType == BibleSourceType.import &&
      translation.format == BibleFormat.sqlite;

  Future<void> _restoreImportedSqliteCache({
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
    _dbManager.close(translation.id);
    await copyFile(sourcePath, await _sqlitePathFor(translation.id));
  }
}
