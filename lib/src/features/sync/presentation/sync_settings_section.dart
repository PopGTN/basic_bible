import 'package:basic_bible/src/features/sync/application/view_models/sync_view_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Sync" area for the settings screen: sign in with Google, sync now,
/// last-synced time, sign out. Notes sync to the hidden app-data area of the
/// user's own Google Drive.
class SyncSettingsSection extends ConsumerWidget {
  const SyncSettingsSection({super.key});

  String _formatLastSynced(DateTime time) {
    final delta = DateTime.now().difference(time);
    if (delta.inMinutes < 1) return 'just now';
    if (delta.inHours < 1) return '${delta.inMinutes} min ago';
    if (delta.inDays < 1) return '${delta.inHours} h ago';
    return '${time.year}-${time.month.toString().padLeft(2, '0')}-'
        '${time.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(googleAuthServiceProvider);
    final sync = ref.watch(syncControllerProvider);
    final syncMode = ref.watch(syncModeProvider);
    final controller = ref.read(syncControllerProvider.notifier);
    final syncModeController = ref.read(syncModeProvider.notifier);

    final children = <Widget>[
      Text(
        'Sync',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 10),
    ];

    if (!auth.isSupported) {
      children.add(
        const ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.cloud_off_outlined),
          title: Text('Google sync is not available in the browser'),
          subtitle: Text('Use the mobile or desktop app to sync notes.'),
          enabled: false,
        ),
      );
    } else if (!auth.isConfigured) {
      children.add(
        const ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.cloud_off_outlined),
          title: Text('Google sync is not configured for this build'),
          subtitle: Text(
            'OAuth client ids are missing — see docs/google_sync_setup.md.',
          ),
          enabled: false,
        ),
      );
    } else if (!sync.isSignedIn) {
      children.add(
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.cloud_outlined),
          title: const Text('Sign in with Google'),
          subtitle: const Text(
            'Back up notes and highlights to your own Google Drive and sync '
            'them across your devices.',
          ),
          onTap: sync.isSyncing ? null : controller.signIn,
        ),
      );
    } else {
      children.addAll([
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Sync mode'),
          subtitle: const Text(
            'Automatic syncs after note changes and on app resume. Manual sync only runs when you tap Sync now.',
          ),
        ),
        SegmentedButton<SyncMode>(
          segments: const [
            ButtonSegment(
              value: SyncMode.automatic,
              icon: Icon(Icons.auto_awesome_motion_outlined),
              label: Text('Automatic'),
            ),
            ButtonSegment(
              value: SyncMode.manual,
              icon: Icon(Icons.touch_app_outlined),
              label: Text('Manual'),
            ),
          ],
          selected: {syncMode},
          onSelectionChanged: (selection) {
            if (selection.isEmpty) return;
            syncModeController.setMode(selection.first);
          },
        ),
        const SizedBox(height: 12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.cloud_done_outlined),
          title: Text(sync.account!.email),
          subtitle: Text(
            sync.isSyncing
                ? 'Syncing…'
                : sync.lastSyncedAt == null
                ? 'Not synced yet'
                : 'Last synced ${_formatLastSynced(sync.lastSyncedAt!)}',
          ),
          trailing: sync.isSyncing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : null,
        ),
        Wrap(
          spacing: 10,
          children: [
            FilledButton.tonal(
              onPressed: sync.isSyncing ? null : controller.triggerSync,
              child: const Text('Sync now'),
            ),
            TextButton(
              onPressed: sync.isSyncing ? null : controller.signOut,
              child: const Text('Sign out'),
            ),
          ],
        ),
      ]);
    }

    if (sync.phase == SyncPhase.error && sync.errorMessage != null) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            sync.errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
