import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:basic_bible/src/features/library/data/app_bible_repository.dart';
import 'package:basic_bible/src/features/library/presentation/import_translation_screen.dart';
import 'package:basic_bible/src/features/library/presentation/versions_screen.dart';
import 'package:basic_bible/src/features/reader/application/view_models/bible_library_view_models.dart';
import 'package:basic_bible/src/features/reader/application/view_models/reader_preferences_view_models.dart';
import 'package:basic_bible/src/features/reader/application/view_models/reader_session_view_models.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/platform/runtime_support.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// All async user actions for [VersionsScreen], extracted as a mixin to keep
/// the main widget file focused on layout and state.
///
/// The mixin constrains itself to [ConsumerState<VersionsScreen>] so it has
/// direct access to [ref], [context], and [mounted] without extra plumbing.
mixin VersionsScreenActions on ConsumerState<VersionsScreen> {
  Future<void> _anchorReaderReferenceForTranslationSwitch() async {
    if (!ref.read(continuousScrollingProvider)) return;

    final visibleReference = ref.read(visibleReaderReferenceProvider);
    if (visibleReference == null) return;

    final currentReference = ref.read(currentReferenceProvider);
    await ref
        .read(currentReferenceProvider.notifier)
        .setReference(
          BibleReference(
            bookId: visibleReference.bookId,
            chapter: visibleReference.chapter,
            verse: currentReference.verse,
          ),
        );
  }

  // ---------------------------------------------------------------------------
  // Select / switch
  // ---------------------------------------------------------------------------

  Future<void> selectTranslation(
    BuildContext context,
    String translationId, {
    bool persist = true,
  }) async {
    final t = AppLocalizations.of(context)!;
    try {
      await _anchorReaderReferenceForTranslationSwitch();
      await ref
          .read(currentTranslationProvider.notifier)
          .setTranslation(translationId, persist: persist);
      if (!context.mounted) return;
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.couldNotSwitchTranslation(error.toString()))),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Session open
  // ---------------------------------------------------------------------------

  Future<void> openTranslationForSession(
    BuildContext context,
    BibleTranslation translation,
  ) async {
    final downloads = ref.read(translationDownloadsProvider.notifier);
    if (!downloads.markStarted(translation.id)) return;
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(bibleBooksProvider.notifier)
          .openTranslationForSession(translation.id);
      await _anchorReaderReferenceForTranslationSwitch();
      await ref
          .read(currentTranslationProvider.notifier)
          .setTranslation(translation.id, persist: false);
      ref.invalidate(availableTranslationsProvider);
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(t.openedForSessionMessage(translation.name))),
      );
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
    } catch (error) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(t.couldNotOpenTranslation(error.toString()))),
      );
    } finally {
      downloads.markFinished(translation.id);
    }
  }

  // ---------------------------------------------------------------------------
  // Download
  // ---------------------------------------------------------------------------

  Future<void> downloadTranslation(
    BuildContext context,
    BibleTranslation translation,
  ) async {
    final downloads = ref.read(translationDownloadsProvider.notifier);
    if (!downloads.markStarted(translation.id)) return;
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(bibleBooksProvider.notifier)
          .downloadTranslation(translation.id);
      // FIX #5: use context.mounted (not bare mounted) consistently.
      if (!context.mounted) return;
      await _anchorReaderReferenceForTranslationSwitch();
      await ref
          .read(currentTranslationProvider.notifier)
          .setTranslation(translation.id);
      ref.invalidate(availableTranslationsProvider);
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(t.downloadedTranslationMessage(translation.name)),
        ),
      );
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
    } catch (error) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(t.couldNotDownloadTranslation(error.toString())),
        ),
      );
    } finally {
      downloads.markFinished(translation.id);
    }
  }

  // ---------------------------------------------------------------------------
  // Import
  // ---------------------------------------------------------------------------

  Future<void> importBibleFile(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    if (isWebRuntime) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.importNotAvailableOnWeb)));
      return;
    }

    final bibleFileTypeGroup = XTypeGroup(
      label: t.translationsFileTypeLabel,
      extensions: <String>[
        'xml',
        'usfx',
        'osis',
        'sqlite',
        'sqlite3',
        'db',
        'usfm',
        'sfm',
        'zip',
      ],
    );
    final file = await openFile(acceptedTypeGroups: [bibleFileTypeGroup]);
    if (file == null || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      final importedTranslation = await Navigator.of(context)
          .push<BibleTranslation>(
            MaterialPageRoute(
              builder: (context) => ImportTranslationScreen(
                filePath: file.path,
                existingIds:
                    ref
                        .read(availableTranslationsProvider)
                        .asData
                        ?.value
                        .map((tr) => tr.id)
                        .toSet() ??
                    const <String>{},
              ),
            ),
          );
      if (importedTranslation == null || !context.mounted) return;
      await _anchorReaderReferenceForTranslationSwitch();
      await ref
          .read(currentTranslationProvider.notifier)
          .setTranslation(importedTranslation.id);
      ref.invalidate(availableTranslationsProvider);
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(t.importedTranslationMessage(importedTranslation.name)),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(t.importFailedMessage(error.toString()))),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Clear cache
  // ---------------------------------------------------------------------------

  Future<void> clearTranslationCache(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.clearTranslationCacheTitle),
        content: Text(t.clearTranslationCacheDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t.clearCacheAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(bibleBooksProvider.notifier).clearAllTranslationCache();
      final defaultId = AppBibleRepository.builtInTranslations.first.id;
      await _anchorReaderReferenceForTranslationSwitch();
      await ref
          .read(currentTranslationProvider.notifier)
          .setTranslation(defaultId);
      ref.invalidate(availableTranslationsProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.clearedTranslationCacheMessage)));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.couldNotClearTranslationCache(error.toString())),
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Delete imported
  // ---------------------------------------------------------------------------

  Future<void> deleteImportedTranslation(
    BuildContext context, {
    required BibleTranslation translation,
    required String currentTranslationId,
    required List<BibleTranslation> allTranslations,
  }) async {
    final t = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.deleteTranslationTitle(translation.name)),
        content: Text(t.deleteImportedTranslationDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t.deleteAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      if (currentTranslationId == translation.id) {
        final fallback = allTranslations.firstWhere(
          (c) => c.id != translation.id,
          orElse: () => AppBibleRepository.builtInTranslations.first,
        );
        await _anchorReaderReferenceForTranslationSwitch();
        await ref
            .read(currentTranslationProvider.notifier)
            .setTranslation(fallback.id);
      }
      await ref
          .read(bibleBooksProvider.notifier)
          .deleteImportedTranslation(translation.id);
      ref.invalidate(availableTranslationsProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.deletedTranslationMessage(translation.name))),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.couldNotDeleteTranslation(error.toString()))),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Remove downloaded
  // ---------------------------------------------------------------------------

  Future<void> removeDownloadedTranslation(
    BuildContext context, {
    required BibleTranslation translation,
    required String currentTranslationId,
    required List<BibleTranslation> allTranslations,
  }) async {
    final t = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.removeDownloadedTranslationTitle(translation.name)),
        content: Text(t.removeDownloadedTranslationDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t.removeAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      if (currentTranslationId == translation.id) {
        final fallback = allTranslations.firstWhere(
          (c) => c.id != translation.id,
          orElse: () => AppBibleRepository.builtInTranslations.first,
        );
        await _anchorReaderReferenceForTranslationSwitch();
        await ref
            .read(currentTranslationProvider.notifier)
            .setTranslation(fallback.id);
      }
      await ref
          .read(bibleBooksProvider.notifier)
          .removeDownloadedTranslation(translation.id);
      ref.invalidate(availableTranslationsProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.removedLocalDownloadMessage(translation.name)),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.couldNotRemoveDownload(error.toString()))),
      );
    }
  }
}
