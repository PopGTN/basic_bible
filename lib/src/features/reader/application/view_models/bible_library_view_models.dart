import 'package:basic_bible/src/features/library/data/app_bible_repository.dart';
import 'package:basic_bible/src/features/library/data/remote_translation_catalog_service.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/utils/reference_utils.dart';
import 'package:basic_bible/src/features/settings/application/view_models/advanced_preferences_view_models.dart';
import 'package:basic_bible/src/services/app_database.dart';
import 'package:basic_bible/src/services/shared_preferences_provider.dart';
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

/// Progress of one in-progress download or session-open (#55).
class TranslationDownloadStatus {
  const TranslationDownloadStatus({required this.name, this.fraction});

  /// Translation display name, for notifications.
  final String name;

  /// 0..1 while bytes arrive and the size is known; null when the size is
  /// unknown or the file is being parsed/installed (indeterminate).
  final double? fraction;
}

/// In-progress downloads and session-opens keyed by translation ID.
/// Lives here so any screen (and the download notification) can observe it
/// without coupling to widget state.
final translationDownloadsProvider =
    StateNotifierProvider<
      TranslationDownloadsNotifier,
      Map<String, TranslationDownloadStatus>
    >((ref) {
      return TranslationDownloadsNotifier();
    });

class TranslationDownloadsNotifier
    extends StateNotifier<Map<String, TranslationDownloadStatus>> {
  TranslationDownloadsNotifier() : super(const {});

  /// Marks [id] as in progress. Returns false if it already is (callers
  /// treat that as a dedup guard).
  bool markStarted(String id, {String? name}) {
    if (state.containsKey(id)) return false;
    state = {...state, id: TranslationDownloadStatus(name: name ?? id)};
    return true;
  }

  /// Records bytes received. Updates are coalesced to whole percents so a
  /// fast stream doesn't rebuild listeners (or re-post a notification) for
  /// every chunk.
  void reportProgress(String id, int received, int? total) {
    final current = state[id];
    if (current == null) return;
    final fraction = total == null || total <= 0
        ? null
        : (received / total).clamp(0.0, 1.0);
    final before = current.fraction;
    if (fraction != null &&
        before != null &&
        (fraction * 100).floor() == (before * 100).floor()) {
      return;
    }
    if (fraction == before) return;
    state = {
      ...state,
      id: TranslationDownloadStatus(name: current.name, fraction: fraction),
    };
  }

  /// Bytes are in; parsing/installing has no measurable progress.
  void markInstalling(String id) {
    final current = state[id];
    if (current == null || current.fraction == null) return;
    state = {...state, id: TranslationDownloadStatus(name: current.name)};
  }

  void markFinished(String id) {
    if (!state.containsKey(id)) return;
    state = {...state}..remove(id);
  }
}

// =============================================================================
// Repository provider
// =============================================================================

final remoteTranslationCatalogServiceProvider =
    Provider<RemoteTranslationCatalogService>((ref) {
      return RemoteTranslationCatalogService(
        catalogUrlOverride: ref.watch(translationCatalogUrlOverrideProvider),
        prefs: ref.read(sharedPreferencesProvider),
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

/// Catalog entry for the translation the reader is showing, or null while the
/// list loads or for an unknown id. Used for the copyright footer (#18).
final currentTranslationInfoProvider = Provider<BibleTranslation?>((ref) {
  final id = ref.watch(currentTranslationProvider);
  final translations = ref.watch(availableTranslationsProvider).asData?.value;
  return translations?.where((t) => t.id == id).firstOrNull;
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

        // Whenever a book list lands (initial load or translation switch),
        // move the reference to what the reader can actually show, so the
        // reference bar never names a book the translation doesn't have
        // (#46).
        void reconcileReference(AsyncValue<List<BibleBook>> booksState) {
          final books = booksState.asData?.value;
          if (books == null) return;
          final fallback = readerFallbackReference(
            books,
            ref.read(currentReferenceProvider),
          );
          if (fallback != null) {
            ref
                .read(currentReferenceProvider.notifier)
                .setReference(fallback, focusVerse: false);
          }
        }

        var isInitialState = true;
        final removeListener = notifier.addListener((booksState) {
          if (!isInitialState) return reconcileReference(booksState);
          isInitialState = false;
          // Providers may not modify other providers while they are being
          // built, so the check for the initial state runs just after.
          Future.microtask(() {
            if (notifier.mounted) reconcileReference(booksState);
          });
        });
        ref.onDispose(removeListener);
        return notifier;
      },
    );

/// The shell book list as readers navigate it (issue #87).
///
/// Some sources ship books with text but no chapters, such as the WEB's
/// `FRT` preface and `GLO` glossary. They used to sit in the book picker but
/// could only lead to "Chapter not found". Here each one gets a single
/// synthetic page, chapter [kFrontMatterChapter], so the picker, chapter bar,
/// next/previous and continuous scroll all reach it; the reader renders the
/// book's text on that page. Chapterless books with no text are dropped.
/// UI should watch this provider; [bibleBooksShellProvider] keeps the raw
/// list for repository-facing code.
final readableBibleBooksProvider = Provider<AsyncValue<List<BibleBook>>>((
  ref,
) {
  return ref.watch(bibleBooksShellProvider).whenData(readableBooks);
});

/// See [readableBibleBooksProvider]. Returns [books] itself when every book
/// already has chapters, so widgets comparing book lists by identity don't
/// reset.
List<BibleBook> readableBooks(List<BibleBook> books) {
  if (books.every((book) => book.chapters.isNotEmpty)) return books;
  return [
    for (final book in books)
      if (book.chapters.isNotEmpty)
        book
      else if (book.introductionBlocks.any((b) => b.text.trim().isNotEmpty))
        book.copyWith(
          chapters: const [BibleChapter(number: kFrontMatterChapter)],
        ),
  ];
}

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
