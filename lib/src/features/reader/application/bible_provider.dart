import 'package:bible_parser_flutter/bible_parser_flutter.dart';
import 'package:basic_bible/src/features/library/data/app_bible_repository.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/services/app_database.dart';
import 'package:basic_bible/src/services/shared_preferences_provider.dart';
import 'package:basic_bible/src/utils/reference_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ReaderLayoutMode { verseList, document }

final continuousScrollingProvider =
    StateNotifierProvider<ContinuousScrollingNotifier, bool>((ref) {
      return ContinuousScrollingNotifier(
        ref.read(sharedPreferencesProvider),
      );
    });

final showBookIntroductionsProvider =
    StateNotifierProvider<ShowBookIntroductionsNotifier, bool>((ref) {
      return ShowBookIntroductionsNotifier(
        ref.read(sharedPreferencesProvider),
      );
    });

final showVerseSelectorProvider =
    StateNotifierProvider<ShowVerseSelectorNotifier, bool>((ref) {
      return ShowVerseSelectorNotifier(
        ref.read(sharedPreferencesProvider),
      );
    });

class ContinuousScrollingNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;

  ContinuousScrollingNotifier(this._prefs)
    : super(_prefs.getBool('reader_continuous_scrolling') ?? false);

  Future<void> setEnabled(bool enabled) async {
    await _prefs.setBool('reader_continuous_scrolling', enabled);
    state = enabled;
  }
}

class ShowBookIntroductionsNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;

  ShowBookIntroductionsNotifier(this._prefs)
    : super(
        _prefs.getBool('reader_show_book_introductions') ??
        _prefs.getBool('reader_show_chapter_headers') ??
        true,
      );

  Future<void> setEnabled(bool enabled) async {
    await _prefs.setBool('reader_show_book_introductions', enabled);
    state = enabled;
  }
}

class ShowVerseSelectorNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;

  ShowVerseSelectorNotifier(this._prefs)
    : super(_prefs.getBool('reader_show_verse_selector') ?? true);

  Future<void> setEnabled(bool enabled) async {
    await _prefs.setBool('reader_show_verse_selector', enabled);
    state = enabled;
  }
}

// Repository provider
final bibleRepositoryProvider = Provider<AppBibleRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return AppBibleRepository(db);
});

// Current translation provider
final currentTranslationProvider =
    StateNotifierProvider<TranslationNotifier, String>((ref) {
      return TranslationNotifier(ref.read(sharedPreferencesProvider));
    });

class TranslationNotifier extends StateNotifier<String> {
  final SharedPreferences _prefs;

  TranslationNotifier(this._prefs)
    : super(_prefs.getString('bible_translation') ?? 'kjv');

  Future<void> setTranslation(String translationId) async {
    await _prefs.setString('bible_translation', translationId);
    state = translationId;
  }
}

final readerLayoutModeProvider =
    StateNotifierProvider<ReaderLayoutModeNotifier, ReaderLayoutMode>((ref) {
      return ReaderLayoutModeNotifier(ref.read(sharedPreferencesProvider));
    });

class ReaderLayoutModeNotifier extends StateNotifier<ReaderLayoutMode> {
  final SharedPreferences _prefs;

  ReaderLayoutModeNotifier(this._prefs)
    : super(_parseLayoutMode(_prefs.getString('reader_layout_mode')));

  static ReaderLayoutMode _parseLayoutMode(String? rawMode) {
    if (rawMode == 'paragraph') {
      // Migrate the older name to the clearer "document" mode label.
      return ReaderLayoutMode.document;
    }
    return ReaderLayoutMode.values.firstWhere(
      (mode) => mode.name == rawMode,
      orElse: () => ReaderLayoutMode.verseList,
    );
  }

  Future<void> setLayoutMode(ReaderLayoutMode mode) async {
    await _prefs.setString('reader_layout_mode', mode.name);
    state = mode;
  }
}

final availableTranslationsProvider = FutureProvider<List<BibleTranslation>>((
  ref,
) async {
  final repository = ref.watch(bibleRepositoryProvider);
  return repository.getAvailableTranslations();
});

// Current reference provider
final currentReferenceProvider =
    StateNotifierProvider<ReferenceNotifier, BibleReference>((ref) {
      return ReferenceNotifier(ref.read(sharedPreferencesProvider));
    });

class ReferenceNotifier extends StateNotifier<BibleReference> {
  final SharedPreferences _prefs;

  ReferenceNotifier(this._prefs)
    : super(
        BibleReference(
          bookId: _prefs.getString('bible_book') ?? 'GEN',
          chapter: _prefs.getInt('bible_chapter') ?? 1,
          verse: _prefs.getInt('bible_verse'),
        ),
      );

  Future<void> setReference(BibleReference reference) async {
    await _prefs.setString('bible_book', reference.bookId);
    await _prefs.setInt('bible_chapter', reference.chapter);
    if (reference.verse != null) {
      await _prefs.setInt('bible_verse', reference.verse!);
    } else {
      await _prefs.remove('bible_verse');
    }
    state = reference;
  }

  void goToNextChapter(List<BibleBook> books) {
    if (books.isEmpty) return;
    final currentBook =
        resolveBookFromReference(books, state.bookId) ?? books.first;
    final currentChapterIndex = currentBook.chapters.indexWhere(
      (c) => c.number == state.chapter,
    );

    if (currentChapterIndex < currentBook.chapters.length - 1) {
      // Next chapter in same book
      final nextChapter = currentBook.chapters[currentChapterIndex + 1];
      setReference(
        BibleReference(bookId: currentBook.id, chapter: nextChapter.number),
      );
    } else {
      // First chapter of next book
      final currentBookIndex = books.indexWhere((b) => b.id == currentBook.id);
      if (currentBookIndex < books.length - 1) {
        final nextBook = books[currentBookIndex + 1];
        if (nextBook.chapters.isNotEmpty) {
          setReference(
            BibleReference(
              bookId: nextBook.id,
              chapter: nextBook.chapters.first.number,
            ),
          );
        }
      }
    }
  }

  void goToPreviousChapter(List<BibleBook> books) {
    if (books.isEmpty) return;
    final currentBook =
        resolveBookFromReference(books, state.bookId) ?? books.first;
    final currentChapterIndex = currentBook.chapters.indexWhere(
      (c) => c.number == state.chapter,
    );

    if (currentChapterIndex > 0) {
      // Previous chapter in same book
      final prevChapter = currentBook.chapters[currentChapterIndex - 1];
      setReference(
        BibleReference(bookId: currentBook.id, chapter: prevChapter.number),
      );
    } else {
      // Last chapter of previous book
      final currentBookIndex = books.indexWhere((b) => b.id == currentBook.id);
      if (currentBookIndex > 0) {
        final prevBook = books[currentBookIndex - 1];
        if (prevBook.chapters.isNotEmpty) {
          setReference(
            BibleReference(
              bookId: prevBook.id,
              chapter: prevBook.chapters.last.number,
            ),
          );
        }
      }
    }
  }
}

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
      // Keep the notifier alive across translation changes so switching feels instant
      ref.listen<String>(currentTranslationProvider, (previous, next) {
        notifier.changeTranslation(next);
      });
      return notifier;
    });

class BibleBooksShellNotifier extends StateNotifier<AsyncValue<List<BibleBook>>> {
  final AppBibleRepository repository;
  String _currentTranslationId;
  int _loadGeneration = 0;

  BibleBooksShellNotifier(this.repository, this._currentTranslationId)
    : super(_initialBibleBooksState(repository, _currentTranslationId)) {
    if (!state.hasValue) {
      loadShell();
    }
  }

  Future<void> loadShell() async {
    final requestedTranslationId = _currentTranslationId;
    final loadGeneration = ++_loadGeneration;
    if (!state.hasValue) {
      state = const AsyncValue.loading();
    }

    try {
      List<BibleBook> books;

      // Try to load shell from local first
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
        // Shell load failed, try full load
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

    // Load the shell for this translation
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
      // Keep the notifier alive across translation changes so cached
      // translations can swap in quickly without recreating the whole loading
      // state from scratch on every pill selection.
      ref.listen<String>(currentTranslationProvider, (previous, next) {
        notifier.changeTranslation(next);
      });
      return notifier;
    });

class BibleBooksNotifier extends StateNotifier<AsyncValue<List<BibleBook>>> {
  final AppBibleRepository repository;
  String _currentTranslationId;
  int _loadGeneration = 0;

  BibleBooksNotifier(this.repository, this._currentTranslationId)
    : super(_initialBibleBooksState(repository, _currentTranslationId)) {
    if (!state.hasValue) {
      loadBible();
    }
  }

  Future<void> loadBible({bool showLoading = true}) async {
    final requestedTranslationId = _currentTranslationId;
    final loadGeneration = ++_loadGeneration;
    if (showLoading || !state.hasValue) {
      state = const AsyncValue.loading();
    }

    try {
      List<BibleBook> books;

      // Try to load from local first, then download if needed
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
        // Local load failed, try to download
        books = await repository.downloadBible(requestedTranslationId);
      }

      // If the user already switched again while this load was running, keep
      // the newer request in control instead of repainting stale Bible data.
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

    // When we already have a rendered translation on screen, keep it visible
    // until the next translation has finished loading from disk/network.
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
