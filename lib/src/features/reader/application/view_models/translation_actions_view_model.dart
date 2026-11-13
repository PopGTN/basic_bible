import 'package:basic_bible/src/models/bible_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bible_library_view_models.dart';
import 'reader_preferences_view_models.dart';
import 'reader_session_view_models.dart';

/// Translation lifecycle actions (switch / download / session-open) that must
/// complete even if the screen that started them is closed.
///
/// These used to live in the Versions screen's widget mixin, which meant a
/// download that finished after the user navigated away hit a
/// `context.mounted` early-return and never switched translations or
/// refreshed [availableTranslationsProvider] — the app looked like the
/// download never finished until it was restarted (issue #91).
///
/// Everything here talks to long-lived providers only, so it is safe to await
/// from a widget and then ignore the widget's lifecycle for the result.
final translationActionsProvider = Provider<TranslationActions>(
  TranslationActions.new,
);

class TranslationActions {
  TranslationActions(this._ref);

  final Ref _ref;

  /// Switches the reader to [translationId], first pinning the current
  /// reference to whatever chapter is visible in continuous-scroll mode so the
  /// switch does not jump the reader back to the last *tapped* chapter.
  Future<void> switchTo(String translationId, {bool persist = true}) async {
    await _anchorVisibleReference();
    await _ref
        .read(currentTranslationProvider.notifier)
        .setTranslation(translationId, persist: persist);
  }

  /// Downloads [translation], switches to it and refreshes the translation
  /// list. Returns false without doing anything if the same translation is
  /// already downloading. Errors are rethrown for the caller to report.
  Future<bool> download(BibleTranslation translation) {
    return _runExclusive(translation.id, () async {
      await _ref
          .read(bibleBooksProvider.notifier)
          .downloadTranslation(translation.id);
      await switchTo(translation.id);
    });
  }

  /// Opens [translation] in memory for this run only (nothing persisted).
  /// Same dedup / error contract as [download].
  Future<bool> openForSession(BibleTranslation translation) {
    return _runExclusive(translation.id, () async {
      await _ref
          .read(bibleBooksProvider.notifier)
          .openTranslationForSession(translation.id);
      await switchTo(translation.id, persist: false);
    });
  }

  Future<bool> _runExclusive(
    String translationId,
    Future<void> Function() body,
  ) async {
    final downloads = _ref.read(translationDownloadsProvider.notifier);
    if (!downloads.markStarted(translationId)) return false;
    try {
      await body();
      return true;
    } finally {
      // Refresh on success *and* failure: a failed download may still have
      // changed what is on disk (e.g. invalidated an old cache).
      _ref.invalidate(availableTranslationsProvider);
      downloads.markFinished(translationId);
    }
  }

  Future<void> _anchorVisibleReference() async {
    if (!_ref.read(continuousScrollingProvider)) return;

    final visibleReference = _ref.read(visibleReaderReferenceProvider);
    if (visibleReference == null) return;

    final currentReference = _ref.read(currentReferenceProvider);
    await _ref
        .read(currentReferenceProvider.notifier)
        .setReference(
          BibleReference(
            bookId: visibleReference.bookId,
            chapter: visibleReference.chapter,
            verse: currentReference.verse,
          ),
        );
  }
}
