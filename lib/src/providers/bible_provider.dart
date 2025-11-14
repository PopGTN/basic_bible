import 'package:bible_parser_flutter/bible_parser_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bible_models.dart';
import '../repositories/app_bible_repository.dart';
import '../services/app_database.dart';

// Repository provider
final bibleRepositoryProvider = Provider<AppBibleRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return AppBibleRepository(db);
});

// Current translation provider
final currentTranslationProvider = StateNotifierProvider<TranslationNotifier, String>((ref) {
  return TranslationNotifier();
});

class TranslationNotifier extends StateNotifier<String> {
  TranslationNotifier() : super('kjv') {
    _loadSavedTranslation();
  }

  Future<void> _loadSavedTranslation() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('bible_translation') ?? 'kjv';
    state = saved;
  }

  Future<void> setTranslation(String translationId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bible_translation', translationId);
    state = translationId;
  }
}

// Current reference provider
final currentReferenceProvider = StateNotifierProvider<ReferenceNotifier, BibleReference>((ref) {
  return ReferenceNotifier();
});

class ReferenceNotifier extends StateNotifier<BibleReference> {
  ReferenceNotifier() : super(BibleReference(bookId: 'GEN', chapter: 1)) {
    _loadSavedReference();
  }

  Future<void> _loadSavedReference() async {
    final prefs = await SharedPreferences.getInstance();
    final bookId = prefs.getString('bible_book') ?? 'GEN';
    final chapter = prefs.getInt('bible_chapter') ?? 1;
    final verse = prefs.getInt('bible_verse');

    state = BibleReference(
      bookId: bookId,
      chapter: chapter,
      verse: verse,
    );
  }

  Future<void> setReference(BibleReference reference) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bible_book', reference.bookId);
    await prefs.setInt('bible_chapter', reference.chapter);
    if (reference.verse != null) {
      await prefs.setInt('bible_verse', reference.verse!);
    } else {
      await prefs.remove('bible_verse');
    }
    state = reference;
  }

  void goToNextChapter(List<BibleBook> books) {
    final currentBook = books.firstWhere((b) => b.id == state.bookId);
    final currentChapterIndex = currentBook.chapters.indexWhere((c) => c.number == state.chapter);

    if (currentChapterIndex < currentBook.chapters.length - 1) {
      // Next chapter in same book
      final nextChapter = currentBook.chapters[currentChapterIndex + 1];
      setReference(BibleReference(bookId: state.bookId, chapter: nextChapter.number));
    } else {
      // First chapter of next book
      final currentBookIndex = books.indexWhere((b) => b.id == state.bookId);
      if (currentBookIndex < books.length - 1) {
        final nextBook = books[currentBookIndex + 1];
        if (nextBook.chapters.isNotEmpty) {
          setReference(BibleReference(bookId: nextBook.id, chapter: nextBook.chapters.first.number));
        }
      }
    }
  }

  void goToPreviousChapter(List<BibleBook> books) {
    final currentBook = books.firstWhere((b) => b.id == state.bookId);
    final currentChapterIndex = currentBook.chapters.indexWhere((c) => c.number == state.chapter);

    if (currentChapterIndex > 0) {
      // Previous chapter in same book
      final prevChapter = currentBook.chapters[currentChapterIndex - 1];
      setReference(BibleReference(bookId: state.bookId, chapter: prevChapter.number));
    } else {
      // Last chapter of previous book
      final currentBookIndex = books.indexWhere((b) => b.id == state.bookId);
      if (currentBookIndex > 0) {
        final prevBook = books[currentBookIndex - 1];
        if (prevBook.chapters.isNotEmpty) {
          setReference(BibleReference(bookId: prevBook.id, chapter: prevBook.chapters.last.number));
        }
      }
    }
  }
}

// Bible books provider
final bibleBooksProvider = StateNotifierProvider<BibleBooksNotifier, AsyncValue<List<BibleBook>>>((ref) {
  final repository = ref.watch(bibleRepositoryProvider);
  final translationId = ref.watch(currentTranslationProvider);
  return BibleBooksNotifier(repository, translationId);
});

class BibleBooksNotifier extends StateNotifier<AsyncValue<List<BibleBook>>> {
  final AppBibleRepository repository;
  String _currentTranslationId;

  BibleBooksNotifier(this.repository, this._currentTranslationId) : super(const AsyncValue.loading()) {
    loadBible();
  }

  Future<void> loadBible() async {
    state = const AsyncValue.loading();

    try {
      List<BibleBook> books;

      // Try to load from local first, then download if needed
      try {
        books = await repository.loadLocalBible(_currentTranslationId);
      } on BibleParserException catch (e, st) {
        if (mounted) {
          state = AsyncValue.error('There was an error parsing the Bible file. Please try a different translation or contact support.', st);
        }
        return;
      }
      catch (e) {
        // Local load failed, try to download
        books = await repository.downloadBible(_currentTranslationId);
      }

      if (mounted) {
        state = AsyncValue.data(books);
      }
    } on BibleParserException catch (e, st) {
      if (mounted) {
        state = AsyncValue.error('There was an error parsing the Bible file. Please try a different translation or contact support.', st);
      }
    }
    catch (e, st) {
      if (mounted) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<void> changeTranslation(String translationId) async {
    if (_currentTranslationId == translationId) return;

    // Immediately mark loading so UI can show a spinner before heavy work starts.
    if (_currentTranslationId == translationId) return;
    _currentTranslationId = translationId;
    if (mounted) {
      state = const AsyncValue.loading();
    }

    // Kick off the actual load asynchronously (allow one event loop tick)
    // so the UI has time to paint the loading state before parsing starts.
    Future(() => loadBible());
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
        state = AsyncValue.error('There was an error parsing the Bible file. Please try a different translation or contact support.', st);
      }
    }
    catch (e, st) {
      if (mounted) {
        state = AsyncValue.error(e, st);
      }
    }
  }
}