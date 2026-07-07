import 'package:basic_bible/src/features/sync/application/view_models/notes_backup_view_models.dart';
import 'package:basic_bible/src/platform/runtime_support.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Export Notes" / "Import Notes" tiles for the settings screen's Notes
/// section. Disabled on web, matching the translation database exporter.
class NotesBackupTiles extends ConsumerStatefulWidget {
  const NotesBackupTiles({super.key});

  @override
  ConsumerState<NotesBackupTiles> createState() => _NotesBackupTilesState();
}

class _NotesBackupTilesState extends ConsumerState<NotesBackupTiles> {
  bool _busy = false;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 4)),
    );
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
    } catch (e) {
      if (mounted) _showMessage('Import failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = !isWebRuntime && !_busy;
    return Column(
      children: [
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
