import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/services/shared_preferences_provider.dart';
import 'package:basic_bible/src/utils/reference_utils.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

final currentTranslationProvider =
    StateNotifierProvider<TranslationNotifier, String>((ref) {
      return TranslationNotifier(ref.read(sharedPreferencesProvider));
    });

final currentReferenceProvider =
    StateNotifierProvider<ReferenceNotifier, BibleReference>((ref) {
      return ReferenceNotifier(ref.read(sharedPreferencesProvider));
    });

class TranslationNotifier extends StateNotifier<String> {
  TranslationNotifier(this._prefs)
    // KJV remains the built-in default translation so the app has a guaranteed
    // local Bible available on first launch even before any remote catalog or
    // downloads are configured.
    : super(_prefs.getString('bible_translation') ?? 'kjv');

  final SharedPreferences _prefs;

  Future<void> setTranslation(String translationId) async {
    await _prefs.setString('bible_translation', translationId);
    state = translationId;
  }
}

/// ViewModel for the reader's current translation and location.
class ReferenceNotifier extends StateNotifier<BibleReference> {
  ReferenceNotifier(this._prefs)
    : super(
        BibleReference(
          bookId: _prefs.getString('bible_book') ?? 'GEN',
          chapter: _prefs.getInt('bible_chapter') ?? 1,
          verse: _prefs.getInt('bible_verse'),
        ),
      );

  final SharedPreferences _prefs;

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
      final nextChapter = currentBook.chapters[currentChapterIndex + 1];
      setReference(
        BibleReference(bookId: currentBook.id, chapter: nextChapter.number),
      );
    } else {
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
      final prevChapter = currentBook.chapters[currentChapterIndex - 1];
      setReference(
        BibleReference(bookId: currentBook.id, chapter: prevChapter.number),
      );
    } else {
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
