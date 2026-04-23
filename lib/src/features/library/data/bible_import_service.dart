import 'package:basic_bible/src/features/library/data/bible_parser_worker.dart';
import 'package:basic_bible/src/features/library/data/bible_archive_support.dart';
import 'package:basic_bible/src/features/library/data/bible_source_parser.dart';
import 'package:basic_bible/src/features/library/data/bible_translation_catalog.dart';
import 'package:basic_bible/src/features/library/data/library_source_io.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/services/app_database.dart';
import 'package:basic_bible/src/services/translation_database.dart';
import 'package:basic_bible/src/services/translation_database_manager.dart';
import 'package:path/path.dart' as p;

// =============================================================================
// Transfer objects
// =============================================================================

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

// =============================================================================
// Service
// =============================================================================

/// Handles all Bible import operations: parsing a local file, storing it in
/// the app's managed directories, and registering it in the main DB.
///
/// Does NOT manage in-memory translation caches — callers are responsible for
/// updating cache state after a successful import.
class AppBibleImportService {
  AppBibleImportService({
    required AppDatabase db,
    required TranslationDatabaseManager dbManager,
  }) : _db = db,
       _dbManager = dbManager;

  final AppDatabase _db;
  final TranslationDatabaseManager _dbManager;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Parses [filePath] and returns a draft with suggested metadata.
  /// Does not persist anything — that happens in [importPreparedBible].
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

    if (_isLikelySqliteFile(filePath)) {
      detectedFormat = BibleFormat.sqlite;
      importedBooks = await _readBibleFromSqlite(filePath);
    } else {
      final parsed = await _readBibleDocument(filePath);
      importedBooks = parsed.books;
      detectedFormat = parsed.format;
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

  /// Persists a confirmed import. Returns the stored translation and the books
  /// so the caller can update the in-memory cache.
  Future<({BibleTranslation translation, List<BibleBook> books})>
  importPreparedBible(BibleImportRequest request) async {
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
      final path = await TranslationDatabaseManager.pathForTranslation(
        normalizedId,
      );
      final translationDb = await _dbManager.open(normalizedId, path);
      await translationDb.insertBible(request.importedBooks);
    }

    await _db.upsertInstalledTranslation(
      translation: translation,
      sourceLocation: managedImportPath,
      sourceTypeOverride: BibleSourceType.import,
      parserVersion: kCurrentParserVersion,
    );

    return (translation: translation, books: request.importedBooks);
  }

  /// Convenience: prepare + import in one call using the suggested defaults.
  Future<({BibleTranslation translation, List<BibleBook> books})>
  importBibleFromFile(String filePath) async {
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

  /// Deletes the managed source snapshot file for an imported translation.
  /// Does not touch the SQLite cache or the main DB — callers handle that.
  Future<void> deleteSourceFile(BibleTranslation translation) async {
    final filePath = translation.filePath;
    if (filePath == null || filePath.isEmpty) return;
    try {
      await deleteFileIfExists(filePath);
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

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

  Future<void> _installImportedSqlite({
    required String translationId,
    required String managedImportPath,
  }) async {
    final destinationPath = await TranslationDatabaseManager.pathForTranslation(
      translationId,
    );
    await _copySqliteFile(
      sourcePath: managedImportPath,
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

  Future<BibleTranslation> _buildImportedTranslation({
    required String filePath,
    required BibleFormat format,
    required List<BibleBook> importedBooks,
  }) async {
    final storedIds = await _db.getInstalledTranslationIds()
      ..addAll(kBuiltInTranslations.map((t) => t.id));
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
    final storedIds = await _db.getInstalledTranslationIds()
      ..addAll(kBuiltInTranslations.map((t) => t.id));
    if (storedIds.contains(candidateId)) {
      throw Exception(
        'A translation with the abbreviation ${candidateId.toUpperCase()} already exists.',
      );
    }
  }

  Future<ParsedBibleSource> _readBibleDocument(String filePath) async {
    final bytes = await readBinaryFile(filePath);
    return parseBibleSourceBytes(
      bytes,
      sourceName: p.basename(filePath),
      hintedFormat: detectBibleFormatFromSourceName(filePath),
    );
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
    final baseName = p.basenameWithoutExtension(filePath)
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
    final ext = p.extension(filePath).toLowerCase();
    return ext == '.sqlite' || ext == '.db' || ext == '.sqlite3';
  }
}
