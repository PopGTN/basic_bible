import 'package:bible_parser_flutter/bible_parser_flutter.dart';
import 'package:basic_bible/src/features/library/data/app_bible_repository.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'bible_books_notifier.dart' show initialBibleBooksState;

/// Shell-load notifier: books + chapter metadata but no verse content.
/// Displayed immediately on launch so the navigation drawer is responsive
/// before the full Bible parse completes.
///
/// Uses [_loadGeneration] to discard stale async results when the translation
/// changes mid-load.
class BibleBooksShellNotifier
    extends StateNotifier<AsyncValue<List<BibleBook>>> {
  BibleBooksShellNotifier(
    this.repository,
    this._currentTranslationId, {
    required this.onResolvedTranslationChanged,
  }) : super(initialBibleBooksState(repository, _currentTranslationId)) {
    if (!state.hasValue) {
      loadShell();
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

  Future<void> loadShell() async {
    var requestedTranslationId = _currentTranslationId;
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
        // Shell load failed — try a full load, then fall back to a different
        // translation if that also fails.
        try {
          books = await repository.loadBibleForReading(requestedTranslationId);
        } catch (_) {
          final fallbackId = await repository.resolveReadableTranslationId(
            requestedTranslationId,
          );
          if (fallbackId == requestedTranslationId) rethrow;
          requestedTranslationId = fallbackId;
          _currentTranslationId = fallbackId;
          await onResolvedTranslationChanged(fallbackId, persist: false);
          books = await repository.loadLocalBibleShell(fallbackId);
        }
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

  // ---------------------------------------------------------------------------
  // Translation switching
  // ---------------------------------------------------------------------------

  Future<void> changeTranslation(String translationId) async {
    if (_currentTranslationId == translationId) return;
    _currentTranslationId = translationId;

    final inMemoryBooks = repository.peekLoadedTranslation(translationId);
    if (inMemoryBooks != null) {
      // FIX #1: explicitly activate so repository accessors stay consistent.
      repository.activateLoadedTranslation(translationId);
      if (mounted) state = AsyncValue.data(inMemoryBooks);
      return;
    }

    await loadShell();
  }
}
