import 'package:basic_bible/src/features/annotations/application/view_models/annotation_data_view_models.dart';
import 'package:basic_bible/src/features/annotations/application/view_models/annotation_selection_view_models.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/services/shared_preferences_provider.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/misc.dart' show Override, ProviderListenable;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bible_library_view_models.dart';
import 'bible_search_view_models.dart';
import 'current_chapter_view_model.dart';
import 'reader_session_view_models.dart';
import 'translation_actions_view_model.dart';

// Split view (#84): a second reading pane beside the main reader. The pane is
// the same reader widget as the main one, so every reader feature works in
// both. It runs inside a nested ProviderScope that swaps in its own
// translation, location and verse selection (see [splitPaneOverrides]).

/// Prefix the pane's translation is saved under.
const splitPaneKeyPrefix = 'split_view';

/// Whether split view is on. Not saved: the app always opens on the single
/// reader.
final splitViewEnabledProvider = StateNotifierProvider<SplitViewNotifier, bool>(
  SplitViewNotifier.new,
  dependencies: [
    splitPaneContainerProvider,
    searchContextReferenceProvider,
    currentReferenceProvider,
    visibleReaderReferenceProvider,
  ],
);

class SplitViewNotifier extends StateNotifier<bool> {
  SplitViewNotifier(this._ref) : super(false);

  final Ref _ref;

  void toggle() {
    final pane = _ref.read(splitPaneContainerProvider);
    final target = state
        // Closing: continuous scrolling only moves the visible reference, so
        // pin the chapter on screen for the pane to reopen on.
        ? _shownChapter(pane.read)
        : _ref.read(splitPaneFollowsMainProvider)
        ? _shownChapter(_ref.read)
        : null;
    if (target != null) {
      pane.read(visibleReaderReferenceProvider.notifier).state = null;
      pane
          .read(currentReferenceProvider.notifier)
          .setReference(target, focusVerse: false);
    }
    state = !state;
  }
}

/// The chapter a reader shows: in continuous scrolling the one on screen
/// rather than the last one picked. [read] is that reader's scope.
BibleReference _shownChapter(
  T Function<T>(ProviderListenable<T> provider) read,
) {
  final shown = read(searchContextReferenceProvider);
  return BibleReference(bookId: shown.bookId, chapter: shown.chapter);
}

/// The second pane's provider scope. A provider rather than widget state so
/// the app bar can show the pane's translation chip, and so the pane keeps its
/// place while split view is closed. Created the first time split view opens,
/// at the main reader's chapter; lives until the app is relaunched.
final splitPaneContainerProvider = Provider<ProviderContainer>((ref) {
  final container = ProviderContainer(
    parent: ref.container,
    overrides: splitPaneOverrides(
      ref.read(sharedPreferencesProvider),
      mainTranslation: ref.read(currentTranslationProvider),
      mainReference: _shownChapter(ref.read),
    ),
  );
  ref.onDispose(container.dispose);
  return container;
}, dependencies: [currentTranslationProvider, searchContextReferenceProvider]);

/// Setting: open split view at the main reader's chapter every time, instead
/// of where the pane was left (it always starts there after a relaunch).
final splitPaneFollowsMainProvider =
    StateNotifierProvider<SplitPaneFollowsMainNotifier, bool>(
      (ref) =>
          SplitPaneFollowsMainNotifier(ref.read(sharedPreferencesProvider)),
    );

class SplitPaneFollowsMainNotifier extends StateNotifier<bool> {
  SplitPaneFollowsMainNotifier(this._prefs)
    : super(_prefs.getBool(_key) ?? false);

  static const _key = 'split_view_follow_main';
  final SharedPreferences _prefs;

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await _prefs.setBool(_key, enabled);
  }
}

/// Overrides that make a reader subtree the second pane: its own translation,
/// location and selection. The pane starts at [mainReference]; its
/// translation is its own, defaulting to [mainTranslation] the first time.
List<Override> splitPaneOverrides(
  SharedPreferences prefs, {
  required String mainTranslation,
  required BibleReference mainReference,
}) => [
  currentTranslationProvider.overrideWith(
    (ref) => TranslationNotifier(
      prefs,
      keyPrefix: splitPaneKeyPrefix,
      fallback: mainTranslation,
    ),
  ),
  currentReferenceProvider.overrideWith(
    (ref) => ReferenceNotifier.unsaved(
      BibleReference(
        bookId: mainReference.bookId,
        chapter: mainReference.chapter,
      ),
    ),
  ),
  visibleReaderReferenceProvider.overrideWith((ref) => null),
  selectedVersesProvider.overrideWith((ref) => SelectedVersesNotifier()),
  highlightPaletteExpandedProvider.overrideWith((ref) => false),
  ..._derivedReaderProviders,
];

/// Every provider computed from the ones overridden above, listed so the pane
/// gets its own copy. Riverpod is meant to scope these by itself through
/// their `dependencies`, but (as of riverpod 3.0.3) a provider already
/// created in the parent is copied into the child unscoped, and the pane would
/// silently show the main reader's books/chapter/annotations, or switch the
/// main reader's translation from the pane's Versions screen. Listing a
/// provider as its own override scopes it explicitly.
///
/// A new provider that watches any of the above (directly or not) and is used
/// inside the reader must be added here; split_view_scoping_guard_test fails
/// (naming it) if one is missing.
final _derivedReaderProviders = <Override>[
  bibleBooksShellProvider,
  readableBibleBooksProvider,
  bibleBooksProvider,
  currentChapterProvider,
  currentTranslationInfoProvider,
  searchContextReferenceProvider,
  selectedVerseProvider,
  selectedVerseAnnotationsProvider,
  annotationTranslationFilterProvider,
  annotationsByChapterProvider,
  visibleChapterAnnotationsProvider,
  translationActionsProvider,
];

/// Moves readers off translations that are going away (deleted, removed,
/// cache cleared), for every reader: the main one and the split-view pane.
/// Has no `dependencies`, so it always lives in the root scope and reaches
/// both readers whichever one's Versions screen calls it.
final readerTranslationFallbackProvider = Provider<ReaderTranslationFallback>(
  (ref) => ReaderTranslationFallback(ref.container),
);

class ReaderTranslationFallback {
  ReaderTranslationFallback(this._root);

  final ProviderContainer _root;

  /// Switches every reader whose translation [isGone] to [fallbackId], the
  /// same way picking it on the Versions screen would. If split view has not
  /// been opened since launch the pane only exists as its saved translation,
  /// which is updated instead.
  Future<void> moveReadersOff(
    bool Function(String translationId) isGone,
    String fallbackId,
  ) async {
    final paneCreated = _root.exists(splitPaneContainerProvider);
    final readers = [
      _root,
      if (paneCreated) _root.read(splitPaneContainerProvider),
    ];
    for (final reader in readers) {
      if (isGone(reader.read(currentTranslationProvider))) {
        await reader.read(translationActionsProvider).switchTo(fallbackId);
      }
    }
    if (!paneCreated) {
      final prefs = _root.read(sharedPreferencesProvider);
      final key = TranslationNotifier.storageKey(splitPaneKeyPrefix);
      final saved = prefs.getString(key);
      if (saved != null && isGone(saved)) {
        await prefs.setString(key, fallbackId);
      }
    }
  }
}
