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
        _showMessage('Notes exported.');
      }
    } catch (e) {
      if (mounted) _showMessage('Export failed: $e');
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
              ? 'Import finished — all ${result.total} notes were already up '
                    'to date.'
              : 'Imported ${result.applied} of ${result.total} notes'
                    '${upToDate > 0 ? ' ($upToDate already up to date)' : ''}.',
        );
      }
      await _refreshStorageSummary();
    } catch (e) {
      if (mounted) _showMessage('Import failed: $e');
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
              ? 'Removed $removed old deleted notes.'
              : 'No old deleted notes needed cleanup yet.',
        );
        await _refreshStorageSummary();
      }
    } catch (e) {
      if (mounted) _showMessage('Cleanup failed: $e');
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
        title: const Text('Reset all notes?'),
        content: Text(
          isSignedIn
              ? 'This removes every saved note and highlight from this device '
                    'only. Notes synced to Google Drive will download again on '
                    'the next sync — sign out first to keep this device empty.'
              : 'This permanently deletes every saved note and highlight on '
                    'this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete all'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _busy = true);
    try {
      await ref.read(appDatabaseProvider).deleteAllUserAnnotations();
      if (mounted) {
        _showMessage('All notes deleted from this device.');
        await _refreshStorageSummary();
      }
    } catch (e) {
      if (mounted) _showMessage('Reset failed: $e');
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
                ? 'Calculating local note database size…'
                : '${summary.activeNotes} active • '
                      '${summary.deletedNotes} deleted tombstones';

            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.storage_outlined),
              title: const Text('Note storage'),
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
          title: const Text('Delete old deleted notes'),
          subtitle: const Text(
            'Removes tombstones older than 30 days so storage stays tidy without deleting active notes.',
          ),
          enabled: enabled,
          onTap: _purgeDeletedNotes,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.delete_forever_outlined),
          title: const Text('Reset all saved notes'),
          subtitle: const Text(
            'Clears every note and highlight from this device.',
          ),
          enabled: enabled,
          onTap: _resetAllNotes,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.upload_file_outlined),
          title: const Text('Export Notes'),
          subtitle: Text(
            isWebRuntime
                ? 'Not available in the browser.'
                : 'Save all notes and highlights as a SQLite backup file.',
          ),
          enabled: enabled,
          onTap: _export,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.download_outlined),
          title: const Text('Import Notes'),
          subtitle: Text(
            isWebRuntime
                ? 'Not available in the browser.'
                : 'Merge notes from a backup file. Never overwrites newer '
                      'local edits.',
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
