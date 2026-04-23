import 'package:bible_parser_flutter/bible_parser_flutter.dart';
import 'package:basic_bible/src/features/library/data/app_bible_repository.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Full-load notifier: holds all verses for every book.
///
/// Uses [_loadGeneration] to discard stale async results when the requested
/// translation changes while a load is in progress.
class BibleBooksNotifier extends StateNotifier<AsyncValue<List<BibleBook>>> {
  BibleBooksNotifier(
    this.repository,
    this._currentTranslationId, {
    required this.onResolvedTranslationChanged,
  }) : super(initialBibleBooksState(repository, _currentTranslationId)) {
    if (!state.hasValue) {
      loadBible();
    }
  }

  final AppBibleRepository repository;
  String _currentTranslationId;
  final Future<void> Function(String translationId, {bool persist})
  onResolvedTranslationChanged;
  int _loadGeneration = 0;

  // ---------------------------------------------------------------------------
  // Load
  // ---------------------------------------------------------------------------

  Future<void> loadBible({bool showLoading = true}) async {
    var requestedTranslationId = _currentTranslationId;
    final loadGeneration = ++_loadGeneration;
    if (showLoading || !state.hasValue) {
      state = const AsyncValue.loading();
    }

    try {
      List<BibleBook> books;

      try {
        books = await repository.loadBibleForReading(requestedTranslationId);
      } on BibleParserException catch (e, st) {
        if (mounted && loadGeneration == _loadGeneration) {
          state = AsyncValue.error(
            'There was an error parsing the Bible file. Please try a different translation or contact support.',
            st,
          );
        }
        return;
      } catch (e) {
        // Local load failed — try resolving a fallback translation.
        final fallbackId = await repository.resolveReadableTranslationId(
          requestedTranslationId,
        );
        if (fallbackId == requestedTranslationId) rethrow;
        requestedTranslationId = fallbackId;
        _currentTranslationId = fallbackId;
        await onResolvedTranslationChanged(fallbackId, persist: false);
        books = await repository.loadBibleForReading(fallbackId);
      }

      if (mounted &&
          loadGeneration == _loadGeneration &&
          requestedTranslationId == _currentTranslationId) {
        state = AsyncValue.data(books);
      }
    } on BibleParserException catch (e, st) {
      if (mounted && loadGeneration == _loadGeneration) {
        state = AsyncValue.error(
          'There was an error parsing the Bible file. Please try a different translation or contact support.',
          st,
        );
      }
    } catch (e, st) {
      if (mounted && loadGeneration == _loadGeneration) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<void> preloadCurrentTranslation() async {
    if (state.isLoading || state.hasValue) return;
    await loadBible(showLoading: false);
  }

  // ---------------------------------------------------------------------------
  // Translation switching
  // ---------------------------------------------------------------------------

  // Note: returns Future<void> but kicks off loadBible() without awaiting it.
  // The caller observes completion via state changes, not the returned future.
  Future<void> changeTranslation(String translationId) async {
    if (_currentTranslationId == translationId) return;
    _currentTranslationId = translationId;

    final inMemoryBooks = repository.peekLoadedTranslation(translationId);
    if (inMemoryBooks != null) {
      // FIX #1: explicitly activate the cached translation in the repository
      // so getBook() / getAllBooks() return the correct data after this switch.
      repository.activateLoadedTranslation(translationId);
      if (mounted) state = AsyncValue.data(inMemoryBooks);
      return;
    }

    // FIX #6: fire-and-forget is intentional here — callers observe state.
    // ignore: unawaited_futures
    loadBible(showLoading: !state.hasValue);
  }

  // ---------------------------------------------------------------------------
  // Download / import / session (background operations)
  // ---------------------------------------------------------------------------

  /// Downloads without blanking the reader. After this returns, call
  /// setTranslation() so changeTranslation() picks up the cached books.
  Future<void> downloadTranslation(String translationId) =>
      repository.downloadBible(translationId);

  // FIX #3: bump _loadGeneration so a concurrent loadBible() cannot overwrite
  // the result of openTranslationForSession after it completes.
  Future<void> openTranslationForSession(String translationId) async {
    final loadGeneration = ++_loadGeneration;
    state = const AsyncValue.loading();

    try {
      final books = await repository.openTranslationForSession(translationId);
      _currentTranslationId = translationId;
      if (mounted && loadGeneration == _loadGeneration) {
        state = AsyncValue.data(books);
      }
    } on BibleParserException catch (e, st) {
      if (mounted && loadGeneration == _loadGeneration) {
        state = AsyncValue.error(
          'There was an error opening the Bible file for this session.',
          st,
        );
      }
    } catch (e, st) {
      if (mounted && loadGeneration == _loadGeneration) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  // FIX #3: bump _loadGeneration on import operations too.
  Future<BibleTranslation> importTranslation(String filePath) async {
    final loadGeneration = ++_loadGeneration;
    state = const AsyncValue.loading();

    try {
      final translation = await repository.importBibleFromFile(filePath);
      _currentTranslationId = translation.id;
      final books = repository.getAllBooks();
      if (mounted && loadGeneration == _loadGeneration) {
        state = AsyncValue.data(books);
      }
      return translation;
    } on BibleParserException catch (e, st) {
      if (mounted && loadGeneration == _loadGeneration) {
        state = AsyncValue.error(
          'There was an error importing the Bible file. Please make sure the selected file is a valid XML Bible or exported SQLite translation database.',
          st,
        );
      }
      rethrow;
    } catch (e, st) {
      if (mounted && loadGeneration == _loadGeneration) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }

  Future<BibleImportDraft> prepareImportTranslation(String filePath) =>
      repository.prepareBibleImport(filePath);

  // FIX #3: bump _loadGeneration on prepared import too.
  Future<BibleTranslation> importPreparedTranslation(
    BibleImportRequest request,
  ) async {
    final loadGeneration = ++_loadGeneration;
    state = const AsyncValue.loading();

    try {
      final translation = await repository.importPreparedBible(request);
      _currentTranslationId = translation.id;
      final books = repository.getAllBooks();
      if (mounted && loadGeneration == _loadGeneration) {
        state = AsyncValue.data(books);
      }
      return translation;
    } on BibleParserException catch (e, st) {
      if (mounted && loadGeneration == _loadGeneration) {
        state = AsyncValue.error(
          'There was an error importing the Bible file. Please make sure the selected file is a valid XML Bible or exported SQLite translation database.',
          st,
        );
      }
      rethrow;
    } catch (e, st) {
      if (mounted && loadGeneration == _loadGeneration) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Delete / remove
  // ---------------------------------------------------------------------------

  Future<void> deleteImportedTranslation(String translationId) async {
    await repository.deleteImportedTranslation(translationId);
    if (_currentTranslationId == translationId && mounted) {
      state = const AsyncValue.loading();
    }
  }

  Future<void> removeDownloadedTranslation(String translationId) async {
    await repository.removeDownloadedTranslation(translationId);
    if (_currentTranslationId == translationId && mounted) {
      state = const AsyncValue.loading();
    }
  }

  Future<void> clearAllTranslationCache() async {
    await repository.clearAllCache();
    if (mounted) {
      state = const AsyncValue.loading();
    }
  }
}

/// Returns a synchronous initial state if the translation is already in memory,
/// avoiding a flash of the loading indicator on provider creation.
AsyncValue<List<BibleBook>> initialBibleBooksState(
  AppBibleRepository repository,
  String translationId,
) {
  final books = repository.peekLoadedTranslation(translationId);
  if (books != null && books.isNotEmpty) return AsyncValue.data(books);
  return const AsyncValue.loading();
}
