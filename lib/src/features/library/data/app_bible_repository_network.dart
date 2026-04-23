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

  Future<List<BibleBook>> downloadBible(String translationId) {
    return _downloadInFlight.putIfAbsent(
      translationId,
      () => _doDownloadBible(translationId)
          .whenComplete(() => _downloadInFlight.remove(translationId)),
    );
  }

  Future<List<BibleBook>> _doDownloadBible(String translationId) async {
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

    await _invalidateCache(translationId);

    try {
      final books = await _installDownloadedArtifact(
        translationId: translationId,
        artifact: artifact,
        responseBody: await _fetchRemoteArtifactBytes(
          artifact,
          actionLabel: 'download ${translation.name}',
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
  Future<List<BibleBook>> openTranslationForSession(String translationId) {
    return _sessionReadInFlight.putIfAbsent(
      translationId,
      () => _doOpenTranslationForSession(translationId)
          .whenComplete(() => _sessionReadInFlight.remove(translationId)),
    );
  }

  Future<List<BibleBook>> _doOpenTranslationForSession(
    String translationId,
  ) async {
    final memoryCached = peekLoadedTranslation(translationId);
    if (memoryCached != null && _sessionTranslationIds.contains(translationId)) {
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

  Future<Uint8List> _fetchRemoteArtifactBytes(
    BibleTranslationArtifact artifact, {
    required String actionLabel,
  }) async {
    final uri = Uri.parse(artifact.downloadUrl);
    try {
      final response = await http
          .get(uri)
          .timeout(AppBibleRepository._remoteRequestTimeout);
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }
      return response.bodyBytes;
    } on TimeoutException {
      throw Exception(
        'Timed out trying to $actionLabel. Please check your internet connection and try again.',
      );
    } catch (error) {
      throw Exception('Failed to $actionLabel: $error');
    }
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
