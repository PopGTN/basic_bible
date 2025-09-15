// lib/src/providers/bible_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bibleModels/bibleBook.dart';
import '../models/bibleModels/bibleChapter.dart';
import '../models/bibleModels/bibleReference.dart';
import '../models/bibleModels/bibleVersus.dart';
import '../models/bible_models.dart';
import '../repositories/bible_repository.dart';

// Repository provider
final bibleRepositoryProvider = Provider<BibleRepository>((ref) {
  return BibleRepository();
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
  final BibleRepository repository;
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
      } catch (e) {
        // Local load failed, try to download
        books = await repository.downloadBible(_currentTranslationId);
      }

      state = AsyncValue.data(books);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> changeTranslation(String translationId) async {
    if (_currentTranslationId == translationId) return;

    _currentTranslationId = translationId;
    await loadBible();
  }

  Future<void> downloadTranslation(String translationId) async {
    state = const AsyncValue.loading();

    try {
      final books = await repository.downloadBible(translationId);
      _currentTranslationId = translationId;
      state = AsyncValue.data(books);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// Current chapter provider
final currentChapterProvider = Provider<AsyncValue<BibleChapter?>>((ref) {
  final booksAsync = ref.watch(bibleBooksProvider);
  final reference = ref.watch(currentReferenceProvider);

  return booksAsync.when(
    data: (books) {
      try {
        final book = books.firstWhere((b) => b.id == reference.bookId);
        final chapter = book.chapters.firstWhere((c) => c.number == reference.chapter);
        return AsyncValue.data(chapter);
      } catch (e) {
        return AsyncValue.error(e, StackTrace.current);
      }
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

// Search provider
final bibleSearchProvider = StateNotifierProvider<SearchNotifier, AsyncValue<List<SearchResult>>>((ref) {
  final repository = ref.watch(bibleRepositoryProvider);
  return SearchNotifier(repository);
});

class SearchNotifier extends StateNotifier<AsyncValue<List<SearchResult>>> {
  final BibleRepository repository;

  SearchNotifier(this.repository) : super(const AsyncValue.data([]));

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();

    try {
      final verses = repository.searchText(query);
      final results = verses.map((verse) {
        // Find which book and chapter this verse belongs to
        final books = repository.getAllBooks();
        for (final book in books) {
          for (final chapter in book.chapters) {
            if (chapter.verses.contains(verse)) {
              return SearchResult(
                verse: verse,
                bookName: book.name,
                bookId: book.id,
                chapterNumber: chapter.number,
              );
            }
          }
        }
        return null;
      }).where((result) => result != null).cast<SearchResult>().toList();

      state = AsyncValue.data(results);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void clearSearch() {
    state = const AsyncValue.data([]);
  }
}

class SearchResult {
  final BibleVerse verse;
  final String bookName;
  final String bookId;
  final int chapterNumber;

  SearchResult({
    required this.verse,
    required this.bookName,
    required this.bookId,
    required this.chapterNumber,
  });
}