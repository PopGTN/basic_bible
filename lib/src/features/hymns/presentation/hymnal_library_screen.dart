import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/view_models/hymnal_library_view_models.dart';
import '../application/view_models/hymnal_view_models.dart';
import '../models/content_repository.dart';
import '../models/hymnal.dart';
import '../data/content_reporting.dart';
import 'guide_links.dart';
import 'hymnal_about_sheet.dart';
import 'hymnal_name_dialog.dart';
import 'hymnal_picker_sheet.dart';

/// Manage hymn books: what's on the device, import a file, and download
/// from repositories.
class HymnalLibraryScreen extends ConsumerWidget {
  const HymnalLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final installed = ref.watch(hymnalListProvider);
    final indexes = ref.watch(repoIndexesProvider);
    final installedIds = {
      for (final info in installed.value ?? const <HymnalInfo>[]) info.id,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(t.hymnalLibraryTitle),
        actions: [
          IconButton(
            tooltip: t.manageRepositories,
            icon: const Icon(Icons.dns_outlined),
            onPressed: () => context.push('/home/hymns/repos'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(contentReposProvider.notifier).refresh();
          await ref.read(repoIndexesProvider.future);
        },
        child: ListView(
          children: [
            _SectionHeader(t.hymnalInstalledSection),
            for (final info in installed.value ?? const <HymnalInfo>[])
              _InstalledTile(info: info),
            ListTile(
              leading: const Icon(Icons.file_open_outlined),
              title: Text(t.hymnalImportFile),
              subtitle: Text(t.hymnalImportSubtitle),
              onTap: () => _importFile(context, ref),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Wrap(
                children: [
                  HymnGuideLink(
                    label: t.hymnalImportGuide,
                    url: kImportGuideUrl,
                  ),
                  HymnGuideLink(
                    label: t.hymnalMakeGuide,
                    url: kMakeHymnbookGuideUrl,
                  ),
                ],
              ),
            ),
            const Divider(),
            _SectionHeader(t.hymnalAvailableSection),
            ...switch (indexes) {
              AsyncData(:final value) => _availableTiles(
                context,
                value,
                installedIds,
              ),
              AsyncError(:final error) => [ListTile(title: Text('$error'))],
              _ => [
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            },
          ],
        ),
      ),
    );
  }

  List<Widget> _availableTiles(
    BuildContext context,
    List<RepoIndexResult> results,
    Set<String> installedIds,
  ) {
    final t = AppLocalizations.of(context)!;
    final tiles = <Widget>[];
    for (final result in results) {
      if (result.error != null) {
        tiles.add(
          ListTile(
            leading: const Icon(Icons.cloud_off_outlined),
            title: Text(result.repo.name),
            subtitle: Text(t.repositoryLoadFailed),
          ),
        );
        continue;
      }
      for (final entry in result.index!.hymnals) {
        tiles.add(
          _AvailableTile(
            repo: result.repo,
            entry: entry,
            installed: installedIds.contains('${result.repo.id}/${entry.id}'),
          ),
        );
      }
    }
    if (tiles.isEmpty) {
      tiles.add(ListTile(subtitle: Text(t.hymnalNoRepoBooks)));
    }
    return tiles;
  }

  Future<void> _importFile(BuildContext context, WidgetRef ref) async {
    final t = AppLocalizations.of(context)!;
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(
          label: 'Hymn book',
          extensions: ['json', 'gz'],
          mimeTypes: ['application/json', 'application/gzip'],
          uniformTypeIdentifiers: ['public.json', 'org.gnu.gnu-zip-archive'],
        ),
      ],
    );
    if (file == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final installs = ref.read(hymnalInstallsProvider.notifier);
    try {
      // 1. Check the file. 2. Let the user name the book. 3. Save it.
      final prepared = await installs.prepareImport(
        await file.readAsBytes(),
        file.name,
      );
      if (!context.mounted) return;
      final name = await showHymnalNameDialog(
        context,
        dialogTitle: t.hymnalNameTitle,
        confirmLabel: t.hymnalImportAction,
        initialTitle: prepared.info.title,
        initialShortTitle: prepared.info.shortTitle,
        message: [
          t.hymnalImportFound(prepared.info.hymnCount),
          if (prepared.replacesExisting) t.hymnalImportReplaces,
        ].join('\n\n'),
      );
      if (name == null) return;
      final info = await installs.completeImport(
        prepared,
        title: name.title,
        shortTitle: name.shortTitle,
      );
      messenger.showSnackBar(
        SnackBar(
          content: Text(t.hymnalImported(info.title)),
          action: SnackBarAction(
            label: t.hymnalOpenBook,
            onPressed: () =>
                ref.read(selectedHymnalIdProvider.notifier).select(info.id),
          ),
        ),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(t.hymnalImportFailed('$error'))),
      );
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
    child: Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  );
}

class _InstalledTile extends ConsumerWidget {
  const _InstalledTile({required this.info});

  final HymnalInfo info;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final selected = ref.watch(selectedHymnalIdProvider) == info.id;
    return ListTile(
      leading: Icon(selected ? Icons.check_circle : Icons.menu_book_outlined),
      title: Text(info.title),
      subtitle: Text(hymnalSourceLabel(t, info)),
      onTap: () {
        ref.read(selectedHymnalIdProvider.notifier).select(info.id);
        context.pop();
      },
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: t.hymnAboutBook,
            icon: const Icon(Icons.info_outline),
            onPressed: () => showHymnalAboutSheet(context, info),
          ),
          if (info.sourceKind != HymnalSourceKind.bundled)
            PopupMenuButton<VoidCallback>(
              tooltip: MaterialLocalizations.of(context).showMenuTooltip,
              onSelected: (action) => action(),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: () => _rename(context, ref, t),
                  child: ListTile(
                    leading: const Icon(Icons.edit_outlined),
                    title: Text(t.hymnalRename),
                  ),
                ),
                PopupMenuItem(
                  value: () => _confirmDelete(context, ref, t),
                  child: ListTile(
                    leading: const Icon(Icons.delete_outline),
                    title: Text(t.removeAction),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _rename(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations t,
  ) async {
    final name = await showHymnalNameDialog(
      context,
      dialogTitle: t.hymnalRename,
      confirmLabel: t.hymnalRenameAction,
      initialTitle: info.title,
      initialShortTitle: info.shortTitle,
    );
    if (name == null) return;
    await ref
        .read(hymnalInstallsProvider.notifier)
        .rename(info, title: name.title, shortTitle: name.shortTitle);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations t,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.hymnalDeleteTitle(info.title)),
        content: Text(t.hymnalDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.removeAction),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(hymnalInstallsProvider.notifier).delete(info);
    }
  }
}

class _AvailableTile extends ConsumerWidget {
  const _AvailableTile({
    required this.repo,
    required this.entry,
    required this.installed,
  });

  final ContentRepository repo;
  final RepoHymnalEntry entry;
  final bool installed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final key = '${repo.id}/${entry.id}';
    final installs = ref.watch(hymnalInstallsProvider);
    final downloading = installs.containsKey(key);
    final subtitle = [
      ?entry.publisher,
      if (entry.hymnCount != null) t.hymnCount(entry.hymnCount!),
      repo.name,
      if (!entry.isDownloadable) t.hymnalNotDownloadable,
    ].join(' · ');

    return ListTile(
      leading: const Icon(Icons.cloud_outlined),
      title: Text(entry.title),
      subtitle: Text(subtitle),
      trailing: downloading
          ? SizedBox.square(
              dimension: 28,
              child: CircularProgressIndicator(value: installs[key]),
            )
          : installed
          ? Tooltip(
              message: t.hymnalDownloaded,
              child: const Icon(Icons.download_done),
            )
          : entry.isDownloadable
          ? IconButton(
              tooltip: t.hymnalDownload,
              icon: const Icon(Icons.download_outlined),
              onPressed: () => _download(context, ref, t),
            )
          : null,
    );
  }

  Future<void> _download(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations t,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final info = await ref
          .read(hymnalInstallsProvider.notifier)
          .install(repo, entry);
      messenger.showSnackBar(
        SnackBar(
          content: Text(t.hymnalImported(info.title)),
          action: SnackBarAction(
            label: t.hymnalOpenBook,
            onPressed: () =>
                ref.read(selectedHymnalIdProvider.notifier).select(info.id),
          ),
        ),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(t.hymnalDownloadFailed('$error'))),
      );
    }
  }
}
