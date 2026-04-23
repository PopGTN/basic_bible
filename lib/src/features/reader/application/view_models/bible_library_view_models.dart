import 'package:basic_bible/src/features/library/data/app_bible_repository.dart';
import 'package:basic_bible/src/features/library/data/remote_translation_catalog_service.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/features/settings/application/view_models/advanced_preferences_view_models.dart';
import 'package:basic_bible/src/services/app_database.dart';
import 'package:basic_bible/src/services/translation_database_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'bible_books_notifier.dart';
import 'bible_books_shell_notifier.dart';
import 'reader_session_view_models.dart';

// Re-export so screens only need one view-model import.
export 'bible_books_notifier.dart' show BibleBooksNotifier;
export 'bible_books_shell_notifier.dart' show BibleBooksShellNotifier;

// =============================================================================
// Download-progress provider
// =============================================================================

/// Tracks which translation IDs have an in-progress download or session-open.
/// Lives here so any screen can observe it without coupling to widget state.
final translationDownloadsProvider =
    StateNotifierProvider<TranslationDownloadsNotifier, Set<String>>((ref) {
      return TranslationDownloadsNotifier();
    });

class TranslationDownloadsNotifier extends StateNotifier<Set<String>> {
  TranslationDownloadsNotifier() : super(const {});

  /// Marks [id] as in-progress. Returns false if already in-progress
  /// (caller should treat this as a dedup guard).
  bool markStarted(String id) {
    if (state.contains(id)) return false;
    state = {...state, id};
    return true;
  }

  void markFinished(String id) {
    if (state.contains(id)) state = state.difference({id});
  }
}

// =============================================================================
// Repository provider
// =============================================================================

final remoteTranslationCatalogServiceProvider =
    Provider<RemoteTranslationCatalogService>((ref) {
      return RemoteTranslationCatalogService(
        catalogUrlOverride: ref.watch(translationCatalogUrlOverrideProvider),
      );
    });

final bibleRepositoryProvider = Provider<AppBibleRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final dbManager = ref.watch(translationDatabaseManagerProvider);
  final catalogService = ref.watch(remoteTranslationCatalogServiceProvider);
  return AppBibleRepository(db, dbManager, catalogService);
});

// =============================================================================
// Translation list
// =============================================================================

final availableTranslationsProvider = FutureProvider<List<BibleTranslation>>((
  ref,
) async {
  final repository = ref.watch(bibleRepositoryProvider);
  return repository.getAvailableTranslations();
});

// =============================================================================
// Bible books — shell (fast, no verses)
// =============================================================================

final bibleBooksShellProvider =
    StateNotifierProvider<BibleBooksShellNotifier, AsyncValue<List<BibleBook>>>(
      (ref) {
        final repository = ref.watch(bibleRepositoryProvider);
        final translationNotifier = ref.read(
          currentTranslationProvider.notifier,
        );
        final notifier = BibleBooksShellNotifier(
          repository,
          ref.read(currentTranslationProvider),
          onResolvedTranslationChanged: (id, {persist = true}) =>
              translationNotifier.setTranslation(id, persist: persist),
        );
        ref.listen<String>(currentTranslationProvider, (_, next) {
          notifier.changeTranslation(next);
        });
        return notifier;
      },
    );

// =============================================================================
// Bible books — full (all verses)
// =============================================================================

final bibleBooksProvider =
    StateNotifierProvider<BibleBooksNotifier, AsyncValue<List<BibleBook>>>((
      ref,
    ) {
      final repository = ref.watch(bibleRepositoryProvider);
      final translationNotifier = ref.read(currentTranslationProvider.notifier);
      final notifier = BibleBooksNotifier(
        repository,
        ref.read(currentTranslationProvider),
        onResolvedTranslationChanged: (id, {persist = true}) =>
            translationNotifier.setTranslation(id, persist: persist),
      );
      ref.listen<String>(currentTranslationProvider, (_, next) {
        notifier.changeTranslation(next);
      });
      return notifier;
    });
