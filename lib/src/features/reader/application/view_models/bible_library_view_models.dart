import 'package:bible_parser_flutter/bible_parser_flutter.dart';
import 'package:basic_bible/src/features/library/data/app_bible_repository.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/services/app_database.dart';
import 'package:basic_bible/src/services/translation_database_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'reader_session_view_models.dart';

// Repository provider
final bibleRepositoryProvider = Provider<AppBibleRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final dbManager = ref.watch(translationDatabaseManagerProvider);
  return AppBibleRepository(db, dbManager);
});

final availableTranslationsProvider = FutureProvider<List<BibleTranslation>>((
  ref,
) async {
  final repository = ref.watch(bibleRepositoryProvider);
  return repository.getAvailableTranslations();
});

// Bible books shell provider (fast load without verses)
final bibleBooksShellProvider =
    StateNotifierProvider<BibleBooksShellNotifier, AsyncValue<List<BibleBook>>>((
      ref,
    ) {
      final repository = ref.watch(bibleRepositoryProvider);
      final notifier = BibleBooksShellNotifier(
        repository,
        ref.read(currentTranslationProvider),
      );
      ref.listen<String>(currentTranslationProvider, (previous, next) {
        notifier.changeTranslation(next);
      });
      return notifier;
    });

class BibleBooksShellNotifier extends StateNotifier<AsyncValue<List<BibleBook>>> {
  BibleBooksShellNotifier(this.repository, this._currentTranslationId)
    : super(_initialBibleBooksState(repository, _currentTranslationId)) {
    if (!state.hasValue) {
      loadShell();
    }
  }

  final AppBibleRepository repository;
  String _currentTranslationId;
  int _loadGeneration = 0;

  Future<void> loadShell() async {
    final requestedTranslationId = _currentTranslationId;
    final loadGeneration = ++_loadGeneration;
    if (!state.hasValue) {
      state = const AsyncValue.loading();
    }

    try {
      List<BibleBook> books;

      try {
        books = await repository.loadLocalBibleShell(requestedTranslationId);
      } on BibleParserException catch (e, st) {
        if (mounted && loadGeneration == _loadGeneration) {
          state = AsyncValue.error(
            'There was an error loading the Bible. Please try a different translation or contact support.',
            st,
          );
        }
        return;
      } catch (e) {
        books = await repository.loadLocalBible(requestedTranslationId);
      }

      if (mounted &&
          loadGeneration == _loadGeneration &&
          requestedTranslationId == _currentTranslationId) {
        state = AsyncValue.data(books);
      }
    } on BibleParserException catch (e, st) {
      if (mounted && loadGeneration == _loadGeneration) {
        state = AsyncValue.error(
          'There was an error loading the Bible. Please try a different translation or contact support.',
          st,
        );
      }
    } catch (e, st) {
      if (mounted && loadGeneration == _loadGeneration) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<void> changeTranslation(String translationId) async {
    if (_currentTranslationId == translationId) return;

    _currentTranslationId = translationId;
    final inMemoryBooks = repository.getLoadedTranslation(translationId);
    if (inMemoryBooks != null) {
      if (mounted) {
        state = AsyncValue.data(inMemoryBooks);
      }
      return;
    }

    await loadShell();
  }
}

// Bible books provider (full load with all verses)
final bibleBooksProvider =
    StateNotifierProvider<BibleBooksNotifier, AsyncValue<List<BibleBook>>>((
      ref,
    ) {
      final repository = ref.watch(bibleRepositoryProvider);
      final notifier = BibleBooksNotifier(
        repository,
        ref.read(currentTranslationProvider),
      );
      ref.listen<String>(currentTranslationProvider, (previous, next) {
        notifier.changeTranslation(next);
      });
      return notifier;
    });

class BibleBooksNotifier extends StateNotifier<AsyncValue<List<BibleBook>>> {
  BibleBooksNotifier(this.repository, this._currentTranslationId)
    : super(_initialBibleBooksState(repository, _currentTranslationId)) {
    if (!state.hasValue) {
      loadBible();
    }
  }

  final AppBibleRepository repository;
  String _currentTranslationId;
  int _loadGeneration = 0;

  Future<void> loadBible({bool showLoading = true}) async {
    final requestedTranslationId = _currentTranslationId;
    final loadGeneration = ++_loadGeneration;
    if (showLoading || !state.hasValue) {
      state = const AsyncValue.loading();
    }

    try {
      List<BibleBook> books;

      try {
        books = await repository.loadLocalBible(requestedTranslationId);
      } on BibleParserException catch (e, st) {
        if (mounted && loadGeneration == _loadGeneration) {
          state = AsyncValue.error(
            'There was an error parsing the Bible file. Please try a different translation or contact support.',
            st,
          );
        }
        return;
      } catch (e) {
        books = await repository.downloadBible(requestedTranslationId);
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

  Future<void> changeTranslation(String translationId) async {
    if (_currentTranslationId == translationId) return;

    _currentTranslationId = translationId;
    final inMemoryBooks = repository.getLoadedTranslation(translationId);
    if (inMemoryBooks != null) {
      if (mounted) {
        state = AsyncValue.data(inMemoryBooks);
      }
      return;
    }

    loadBible(showLoading: !state.hasValue);
  }

  Future<void> downloadTranslation(String translationId) async {
    state = const AsyncValue.loading();

    try {
      final books = await repository.downloadBible(translationId);
      _currentTranslationId = translationId;
      if (mounted) {
        state = AsyncValue.data(books);
      }
    } on BibleParserException catch (e, st) {
      if (mounted) {
        state = AsyncValue.error(
          'There was an error parsing the Bible file. Please try a different translation or contact support.',
          st,
        );
      }
    } catch (e, st) {
      if (mounted) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<BibleTranslation> importTranslation(String filePath) async {
    state = const AsyncValue.loading();

    try {
      final translation = await repository.importBibleFromFile(filePath);
      _currentTranslationId = translation.id;
      final books = repository.getAllBooks();
      if (mounted) {
        state = AsyncValue.data(books);
      }
      return translation;
    } on BibleParserException catch (e, st) {
      if (mounted) {
        state = AsyncValue.error(
          'There was an error parsing the Bible file. Please make sure the selected file is valid USFX, OSIS, or Zefania XML.',
          st,
        );
      }
      rethrow;
    } catch (e, st) {
      if (mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }

  Future<BibleImportDraft> prepareImportTranslation(String filePath) {
    return repository.prepareBibleImport(filePath);
  }

  Future<BibleTranslation> importPreparedTranslation(
    BibleImportRequest request,
  ) async {
    state = const AsyncValue.loading();

    try {
      final translation = await repository.importPreparedBible(request);
      _currentTranslationId = translation.id;
      final books = repository.getAllBooks();
      if (mounted) {
        state = AsyncValue.data(books);
      }
      return translation;
    } on BibleParserException catch (e, st) {
      if (mounted) {
        state = AsyncValue.error(
          'There was an error parsing the Bible file. Please make sure the selected file is valid USFX, OSIS, or Zefania XML.',
          st,
        );
      }
      rethrow;
    } catch (e, st) {
      if (mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }

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
}

AsyncValue<List<BibleBook>> _initialBibleBooksState(
  AppBibleRepository repository,
  String translationId,
) {
  final books = repository.getLoadedTranslation(translationId);
  if (books != null && books.isNotEmpty) {
    return AsyncValue.data(books);
  }
  return const AsyncValue.loading();
}
