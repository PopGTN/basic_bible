import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'translation_database.dart';

/// Manages open [TranslationDatabase] connections keyed by translation ID.
///
/// Each Bible translation lives in its own SQLite file at
/// `<appSupportDir>/bibles/<id>.sqlite`. This manager opens a connection on
/// first access and keeps it alive for the lifetime of the app (or until
/// [close] is called). On dispose, all connections are closed cleanly.
class TranslationDatabaseManager {
  final Map<String, TranslationDatabase> _cache = {};

  /// Returns an open [TranslationDatabase] for [translationId], opening it at
  /// [filePath] if not already cached.
  Future<TranslationDatabase> open(
    String translationId,
    String filePath,
  ) async {
    return _cache.putIfAbsent(
      translationId,
      () => openTranslationDatabase(filePath),
    );
  }

  /// Closes and removes the connection for [translationId].
  /// Call this before deleting the underlying file.
  void close(String translationId) {
    _cache.remove(translationId)?.close();
  }

  /// Closes all open connections.
  Future<void> closeAll() async {
    for (final db in _cache.values) {
      await db.close();
    }
    _cache.clear();
  }

  // ---------------------------------------------------------------------------
  // Path helpers — static so callers outside the manager can resolve paths
  // without holding a manager reference.
  // ---------------------------------------------------------------------------

  /// Absolute path to the `bibles/` directory, creating it if absent.
  static Future<String> biblesDir() async {
    final appDir = await getApplicationSupportDirectory();
    final dir = Directory(p.join(appDir.path, 'bibles'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir.path;
  }

  /// Absolute path for a translation's SQLite file.
  static Future<String> pathForTranslation(String id) async {
    return p.join(await biblesDir(), '$id.sqlite');
  }

  /// Absolute path to the `imported_sources/` directory, creating it if absent.
  static Future<String> importedSourcesDir() async {
    final appDir = await getApplicationSupportDirectory();
    final dir = Directory(p.join(appDir.path, 'imported_sources'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir.path;
  }

  /// Absolute path for a managed copy of an imported source file.
  static Future<String> pathForImportedSource(
    String id, {
    String extension = '.xml',
  }) async {
    final normalizedExtension = extension.isEmpty
        ? '.xml'
        : extension.startsWith('.')
        ? extension
        : '.$extension';
    return p.join(await importedSourcesDir(), '$id$normalizedExtension');
  }
}

final translationDatabaseManagerProvider = Provider<TranslationDatabaseManager>(
  (ref) {
    final manager = TranslationDatabaseManager();
    ref.onDispose(() => manager.closeAll());
    return manager;
  },
);
