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
      activateLoadedTranslation(translationId);
      return memoryCached;
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
      activateLoadedTranslation(translationId);
      return Future.value(memoryCached);
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
      activateLoadedTranslation(translationId);
      return memoryCached;
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

      if (_isBuiltInSqliteTranslation(translation)) {
        try {
          await _restoreBuiltInSqliteCache(translation: translation);
          await _db.upsertInstalledTranslation(
            translation: translation,
            sourceLocation: sourceLocationForTranslation(translation),
            sourceTypeOverride: translation.sourceType,
            parserVersion: kCurrentParserVersion,
          );
          final path = await _sqlitePathFor(translationId);
          final translationDb = await _dbManager.open(translationId, path);
          // Use shell load (no verses) — the SQLite file itself is the cache.
          // Verses are hydrated on-demand via loadChapterVerses/getChapter().
          final books = await translationDb.getBooksShell();
          if (books.isNotEmpty) {
            return _rememberLoadedTranslation(translationId, books);
          }
        } catch (_) {
          // Asset restore failed or produced no data — fall through to network.
        }
        // Clean up any partial state before falling back to a network download.
        await _invalidateCache(translationId);
        await _db.deleteInstalledTranslation(translationId);
        return downloadBible(translationId);
      }

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

      if (translation.sourceType == BibleSourceType.import &&
          (translation.format == BibleFormat.usfm ||
              translation.format == BibleFormat.zip)) {
        final books = await _loadImportedBooks(translation);
        final path = await _sqlitePathFor(translationId);
        final translationDb = await _dbManager.open(translationId, path);
        await translationDb.insertBible(books);
        await _db.updateInstalledTranslationParserVersion(
          translationId,
          kCurrentParserVersion,
        );
        return _rememberLoadedTranslation(translationId, books);
      }

      final content = await _loadLocalContent(translation);
      // parse + model mapping both happen inside the worker isolate.
      final books = await compute(parseBibleContentToBooks, content);

      final path = await _sqlitePathFor(translationId);
      final translationDb = await _dbManager.open(translationId, path);
      await translationDb.insertBible(books);

      // Single round-trip: upsert metadata and stamp the parser version together.
      await _db.upsertInstalledTranslation(
        translation: translation,
        sourceLocation: sourceLocationForTranslation(translation),
        sourceTypeOverride: translation.sourceType,
        parserVersion: kCurrentParserVersion,
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
    final cachedChapter = _lookupCachedChapter(translationId, bookId, chapterNumber);
    if (cachedChapter != null) {
      return cachedChapter;
    }

    final fullBooks = peekLoadedTranslation(translationId);
    if (fullBooks != null) {
      for (final book in fullBooks) {
        if (book.id != bookId) continue;
        for (final chapter in book.chapters) {
          if (chapter.number != chapterNumber || chapter.verses.isEmpty) {
            continue;
          }
          return _rememberHydratedChapter(translationId, bookId, chapter);
        }
      }
    }

    final path = await _sqlitePathFor(translationId);
    if (usesFileBackedStorage && !await pathExists(path)) {
      return null;
    }
    final translationDb = await _dbManager.open(translationId, path);
    final chapter = await translationDb.getChapter(bookId, chapterNumber);
    if (chapter == null) return null;
    return _rememberHydratedChapter(translationId, bookId, chapter);
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
    final document = decodeBibleArchiveText(
      await readBinaryFile(filePath),
      sourceName: p.basename(filePath),
      hintedFormat: translation.format,
    );
    return document.content;
  }

  Future<List<BibleBook>> _loadImportedBooks(BibleTranslation translation) async {
    final filePath = translation.filePath;
    if (filePath == null || filePath.isEmpty) {
      throw Exception(
        'Imported translation ${translation.id} is missing a file path.',
      );
    }
    if (!await pathExists(filePath)) {
      throw Exception('Imported translation file was not found: $filePath');
    }
    final parsed = await parseBibleSourceBytes(
      await readBinaryFile(filePath),
      sourceName: p.basename(filePath),
      hintedFormat: translation.format,
    );
    return parsed.books;
  }

  Future<String> _loadAssetContent(BibleTranslation translation) async {
    final assetPath = translation.filePath;
    if (assetPath == null || assetPath.isEmpty) {
      throw Exception(
        'Bundled translation ${translation.id} is missing an asset path.',
      );
    }
    try {
      if (assetPath.endsWith('.gz')) {
        return utf8.decode(_gunzipAssetBytes(await rootBundle.load(assetPath)));
      }
      return await rootBundle.loadString(assetPath);
    } catch (error) {
      throw Exception(
        'Bundled translation ${translation.id} not found at $assetPath: $error',
      );
    }
  }

  /// Bundled Bible assets ship gzipped to keep install size down (the raw
  /// KJV pair is 62 MB; gzipped it is 8 MB). Uses package:archive so the
  /// same code runs on web.
  List<int> _gunzipAssetBytes(ByteData byteData) {
    final compressed = byteData.buffer.asUint8List(
      byteData.offsetInBytes,
      byteData.lengthInBytes,
    );
    return GZipDecoder().decodeBytes(compressed);
  }

  bool _isBuiltInSqliteTranslation(BibleTranslation translation) =>
      translation.sourceType == BibleSourceType.asset &&
      translation.format == BibleFormat.sqlite;

  Future<void> _restoreBuiltInSqliteCache({
    required BibleTranslation translation,
  }) async {
    final assetPath = translation.filePath;
    if (assetPath == null || assetPath.isEmpty) {
      throw Exception(
        'Built-in SQLite translation ${translation.id} is missing an asset path.',
      );
    }
    final byteData = await rootBundle.load(assetPath);
    final bytes = assetPath.endsWith('.gz')
        ? _gunzipAssetBytes(byteData)
        : byteData.buffer.asUint8List(
            byteData.offsetInBytes,
            byteData.lengthInBytes,
          );
    _dbManager.close(translation.id);
    await writeBinaryFile(await _sqlitePathFor(translation.id), bytes);
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
