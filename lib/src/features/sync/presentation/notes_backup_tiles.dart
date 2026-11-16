import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:basic_bible/src/features/sync/application/view_models/notes_backup_view_models.dart';
import 'package:basic_bible/src/features/sync/application/view_models/sync_view_models.dart';
import 'package:basic_bible/src/platform/runtime_support.dart';
import 'package:basic_bible/src/services/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Export Notes" / "Import Notes" tiles for the settings screen's Notes
/// section. Disabled on web, matching the translation database exporter.
class NotesBackupTiles extends ConsumerStatefulWidget {
  const NotesBackupTiles({super.key});

  @override
  ConsumerState<NotesBackupTiles> createState() => _NotesBackupTilesState();
}

String _formatStorageBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
}

class _NotesBackupTilesState extends ConsumerState<NotesBackupTiles> {
  bool _busy = false;
  late Future<AnnotationStorageSummary> _storageSummaryFuture;

  @override
  void initState() {
    super.initState();
    _storageSummaryFuture = ref
        .read(appDatabaseProvider)
        .getAnnotationStorageSummary();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 4)),
    );
  }

  Future<void> _refreshStorageSummary() async {
    if (!mounted) return;
    setState(() {
      _storageSummaryFuture = ref
          .read(appDatabaseProvider)
          .getAnnotationStorageSummary();
    });
  }

  Future<void> _export() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final saved = await ref.read(notesBackupServiceProvider).exportNotes();
      if (mounted && saved && !isMobileRuntime) {
        _showMessage(AppLocalizations.of(context)!.notesExported);
      }
    } catch (e) {
      if (mounted) _showMessage(AppLocalizations.of(context)!.exportFailed(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final result = await ref.read(notesBackupServiceProvider).importNotes();
      if (mounted && result != null) {
        final upToDate = result.total - result.applied;
        _showMessage(
          result.applied == 0
              ? AppLocalizations.of(context)!.importUpToDate(result.total)
              : upToDate > 0
              ? AppLocalizations.of(context)!.importedNotesCountWithUpToDate(
                  result.applied,
                  result.total,
                  upToDate,
                )
              : AppLocalizations.of(context)!.importedNotesCount(result.applied, result.total),
        );
      }
      await _refreshStorageSummary();
    } catch (e) {
      if (mounted) _showMessage(AppLocalizations.of(context)!.importFailedShort(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _purgeDeletedNotes() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final removed = await ref
          .read(appDatabaseProvider)
          .runLocalRetentionCleanup();
      if (mounted) {
        _showMessage(
          removed > 0
              ? AppLocalizations.of(context)!.cleanupRemoved(removed)
              : AppLocalizations.of(context)!.cleanupNothing,
        );
        await _refreshStorageSummary();
      }
    } catch (e) {
      if (mounted) _showMessage(AppLocalizations.of(context)!.cleanupFailed(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resetAllNotes() async {
    if (_busy) return;
    // Reset is local-only on purpose (tombstoning everything would wipe every
    // synced device), so be upfront that Drive will restore the notes.
    final isSignedIn = ref.read(syncControllerProvider).isSignedIn;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.resetAllNotesTitle),
        content: Text(
          isSignedIn
              ? AppLocalizations.of(context)!.resetAllNotesSignedIn
              : AppLocalizations.of(context)!.resetAllNotesLocal,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancelAction),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)!.deleteAllAction),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _busy = true);
    try {
      await ref.read(appDatabaseProvider).deleteAllUserAnnotations();
      if (mounted) {
        _showMessage(AppLocalizations.of(context)!.allNotesDeleted);
        await _refreshStorageSummary();
      }
    } catch (e) {
      if (mounted) _showMessage(AppLocalizations.of(context)!.resetFailed(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = !isWebRuntime && !_busy;

    return Column(
      children: [
        FutureBuilder<AnnotationStorageSummary>(
          future: _storageSummaryFuture,
          builder: (context, snapshot) {
            final summary = snapshot.data;
            final detailText = summary == null
                ? AppLocalizations.of(context)!.noteStorageCalculating
                : AppLocalizations.of(context)!.noteStorageDetail(
                    summary.activeNotes,
                    summary.deletedNotes,
                  );

            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.storage_outlined),
              title: Text(AppLocalizations.of(context)!.noteStorageTitle),
              subtitle: Text(detailText),
              trailing: Text(
                summary == null
                    ? ''
                    : _formatStorageBytes(summary.databaseBytes),
                style: Theme.of(context).textTheme.labelLarge,
              ),
            );
          },
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.cleaning_services_outlined),
          title: Text(AppLocalizations.of(context)!.purgeDeletedNotesTitle),
          subtitle: Text(AppLocalizations.of(context)!.purgeDeletedNotesDesc),
          enabled: enabled,
          onTap: _purgeDeletedNotes,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.delete_forever_outlined),
          title: Text(AppLocalizations.of(context)!.resetAllSavedNotesTitle),
          subtitle: Text(AppLocalizations.of(context)!.resetAllSavedNotesDesc),
          enabled: enabled,
          onTap: _resetAllNotes,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.upload_file_outlined),
          title: Text(AppLocalizations.of(context)!.exportNotesTitle),
          subtitle: Text(
            isWebRuntime
                ? AppLocalizations.of(context)!.notAvailableInBrowser
                : AppLocalizations.of(context)!.exportNotesDesc,
          ),
          enabled: enabled,
          onTap: _export,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.download_outlined),
          title: Text(AppLocalizations.of(context)!.importNotesTitle),
          subtitle: Text(
            isWebRuntime
                ? AppLocalizations.of(context)!.notAvailableInBrowser
                : AppLocalizations.of(context)!.importNotesDesc,
          ),
          enabled: enabled,
          onTap: _import,
        ),
        if (_busy)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }
}
