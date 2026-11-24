part of 'app_bible_repository.dart';

// All imports come from the parent library (app_bible_repository.dart).
// Private members of AppBibleRepository are accessible here because this file
// is part of the same library.

// Formats supported for session-open (no on-disk write; bytes stay in memory).
// BibleFormat.zip is included because the ZIP is decoded in-memory — no file
// I/O is needed. SQLite is intentionally excluded (needs file-backed storage).
const _sessionReadableFormats = <BibleFormat>{
  BibleFormat.zip,
  BibleFormat.usfm,
  BibleFormat.usfx,
  BibleFormat.osis,
  BibleFormat.zefania,
};

extension AppBibleRepositoryNetwork on AppBibleRepository {
  // ---------------------------------------------------------------------------
  // Download (cached to SQLite on disk)
  // ---------------------------------------------------------------------------

  /// [onProgress] reports bytes received (#55). Only the caller that starts
  /// a download gets callbacks; a concurrent duplicate call shares the same
  /// future without them.
  Future<List<BibleBook>> downloadBible(
    String translationId, {
    DownloadProgressCallback? onProgress,
  }) {
    return _downloadInFlight.run(
      translationId,
      () => _doDownloadBible(translationId, onProgress: onProgress),
    );
  }

  Future<List<BibleBook>> _doDownloadBible(
    String translationId, {
    DownloadProgressCallback? onProgress,
  }) async {
    // A session-only translation is in memory but not on disk; downloading it
    // must still install it, so only short-circuit for persisted ones (#28).
    final memoryCached = peekLoadedTranslation(translationId);
    if (memoryCached != null &&
        !_sessionTranslationIds.contains(translationId)) {
      activateLoadedTranslation(translationId);
      return memoryCached;
    }

    if (await _isCacheValid(translationId)) {
      final path = await _sqlitePathFor(translationId);
      final translationDb = await _dbManager.open(translationId, path);
      final books = await translationDb.getBible();
      if (books.isNotEmpty)
        return _rememberLoadedTranslation(translationId, books);
    }

    // FIX #2: resolve the translation and verify an artifact exists BEFORE
    // invalidating the cache. Previously the cache was wiped first, meaning a
    // missing artifact or failed lookup would destroy the user's cached data.
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

    // Mark any existing install row incomplete *before* touching the files.
    // `_isCacheValid` trusts "row at current parser version + file exists",
    // so if the app is killed mid-write (issue #55) a re-download would
    // otherwise leave a half-written database that looks fully installed.
    // The row is promoted back to the current parser version only after the
    // install below finishes.
    await _db.updateInstalledTranslationParserVersion(translationId, 0);
    _storedTranslationsDirty = true;
    await _invalidateCache(translationId);

    try {
      final books = await _installDownloadedArtifact(
        translationId: translationId,
        artifact: artifact,
        responseBody: await _fetchRemoteArtifactBytes(
          artifact,
          actionLabel: 'download ${translation.name}',
          onProgress: onProgress,
        ),
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
        parserVersion: kCurrentParserVersion,
      );
      _sessionTranslationIds.remove(translationId);

      return _rememberLoadedTranslation(translationId, books);
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Failed to download Bible: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Session open (bytes parsed in memory, not written to disk)
  // ---------------------------------------------------------------------------

  // FIX #8: use putIfAbsent for consistent in-flight dedup.
  Future<List<BibleBook>> openTranslationForSession(
    String translationId, {
    DownloadProgressCallback? onProgress,
  }) {
    return _sessionReadInFlight.run(
      translationId,
      () => _doOpenTranslationForSession(translationId, onProgress: onProgress),
    );
  }

  Future<List<BibleBook>> _doOpenTranslationForSession(
    String translationId, {
    DownloadProgressCallback? onProgress,
  }) async {
    final memoryCached = peekLoadedTranslation(translationId);
    if (memoryCached != null &&
        _sessionTranslationIds.contains(translationId)) {
      activateLoadedTranslation(translationId);
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

    final books = await _parseBibleBytes(
      await _fetchRemoteArtifactBytes(
        artifact,
        actionLabel: 'open ${translation.name}',
        onProgress: onProgress,
      ),
    );
    if (books.isEmpty) {
      throw Exception(
        'The remote translation ${translation.name} did not contain any Bible books.',
      );
    }

    _sessionTranslationIds.add(translationId);
    return _rememberLoadedTranslation(translationId, books);
  }

  // ---------------------------------------------------------------------------
  // HTTP fetch
  // ---------------------------------------------------------------------------

  /// Hard ceiling on a single translation download. The largest real-world
  /// artifacts (full SQLite Bibles) are well under this; anything bigger is
  /// either a catalog mistake or a hostile server.
  static const int _maxDownloadBytes = 100 * 1024 * 1024;

  /// https-only, size-capped, SHA-256-checked download. The rules live in
  /// [fetchVerifiedHttps] so hymnal downloads share them.
  Future<Uint8List> _fetchRemoteArtifactBytes(
    BibleTranslationArtifact artifact, {
    required String actionLabel,
    DownloadProgressCallback? onProgress,
  }) {
    return fetchVerifiedHttps(
      Uri.parse(artifact.downloadUrl),
      client: AppBibleRepository._httpClient,
      maxBytes: _maxDownloadBytes,
      actionLabel: actionLabel,
      expectedSize: artifact.sizeBytes,
      expectedSha256: artifact.sha256,
      timeout: AppBibleRepository._remoteRequestTimeout,
      onProgress: onProgress,
    );
  }

  // ---------------------------------------------------------------------------
  // Install helpers
  // ---------------------------------------------------------------------------

  Set<BibleFormat> get _downloadSupportedFormats => <BibleFormat>{
    BibleFormat.zip,
    BibleFormat.usfm,
    BibleFormat.usfx,
    BibleFormat.osis,
    BibleFormat.zefania,
    if (usesFileBackedStorage) BibleFormat.sqlite,
  };

  Future<List<BibleBook>> _installDownloadedArtifact({
    required String translationId,
    required BibleTranslationArtifact artifact,
    required List<int> responseBody,
  }) async {
    final normalizedFormat = normalizeBibleFormat(
      declaredFormat: artifact.format,
      fileName: artifact.fileName,
      bytes: responseBody,
    );

    switch (normalizedFormat) {
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
      case BibleFormat.zip:
      case BibleFormat.usfm:
        final books = await _parseBibleBytes(
          responseBody,
          sourceName: artifact.fileName,
          hintedFormat: normalizedFormat,
        );
        final path = await _sqlitePathFor(translationId);
        final translationDb = await _dbManager.open(translationId, path);
        await translationDb.insertBible(books);
        return books;
      case BibleFormat.usfmDirectory:
      case BibleFormat.auto:
        throw Exception(
          'The ${normalizedFormat.name} download path is not connected yet.',
        );
    }
  }

  Future<List<BibleBook>> _parseBibleBytes(
    List<int> bytes, {
    String? sourceName,
    BibleFormat? hintedFormat,
  }) async {
    final parsed = await parseBibleSourceBytes(
      bytes,
      sourceName: sourceName ?? 'document',
      hintedFormat: hintedFormat,
    );
    return parsed.books;
  }
}
