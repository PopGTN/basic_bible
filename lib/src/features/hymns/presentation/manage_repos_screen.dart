import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/view_models/hymnal_library_view_models.dart';
import '../models/content_repository.dart';

/// F-Droid style repository management: list, enable/disable, add (after
/// accepting the third-party disclaimer) and remove repositories.
class ManageReposScreen extends ConsumerWidget {
  const ManageReposScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final repos = ref.watch(contentReposProvider);
    final indexes = ref.watch(repoIndexesProvider).value;
    String? errorFor(ContentRepository repo) =>
        indexes?.where((r) => r.repo.id == repo.id).firstOrNull?.error;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.repositoriesTitle),
        actions: [
          IconButton(
            tooltip: t.repositoryRefresh,
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(contentReposProvider.notifier).refresh(),
          ),
          IconButton(
            tooltip: t.legalTitle,
            icon: const Icon(Icons.gavel_outlined),
            onPressed: () => context.push('/home/settings/legal'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: Text(t.repositoryAdd),
        onPressed: () => _addRepository(context, ref),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              t.repositoriesIntro,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          for (final repo in repos)
            _RepoTile(repo: repo, error: errorFor(repo)),
        ],
      ),
    );
  }

  Future<void> _addRepository(BuildContext context, WidgetRef ref) async {
    final t = AppLocalizations.of(context)!;
    final url = await showDialog<String>(
      context: context,
      builder: (_) => const _AddRepoDialog(),
    );
    if (url == null || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final notifier = ref.read(contentReposProvider.notifier);
    final RepoIndex index;
    try {
      index = await notifier.probe(url);
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(t.repositoryAddFailed('$error'))),
      );
      return;
    }
    if (!context.mounted) return;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (_) => _DisclaimerDialog(index: index, url: url),
    );
    if (accepted != true) return;
    try {
      await notifier.add(url, index);
      messenger.showSnackBar(
        SnackBar(content: Text(t.repositoryAdded(index.name))),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(t.repositoryAddFailed('$error'))),
      );
    }
  }
}

class _RepoTile extends ConsumerWidget {
  const _RepoTile({required this.repo, required this.error});

  final ContentRepository repo;
  final String? error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final notifier = ref.read(contentReposProvider.notifier);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(repo.name, style: theme.textTheme.titleMedium),
                ),
                if (repo.isOfficial)
                  Chip(
                    label: Text(t.repositoryOfficial),
                    visualDensity: VisualDensity.compact,
                  ),
                Switch(
                  value: repo.enabled,
                  onChanged: (on) => notifier.setEnabled(repo, on),
                ),
              ],
            ),
            Text(
              repo.url,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (repo.description != null) ...[
              const SizedBox(height: 4),
              Text(repo.description!),
            ],
            if (repo.enabled && error != null) ...[
              const SizedBox(height: 4),
              Text(
                t.repositoryLoadFailed,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
            if (!repo.isOfficial)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.delete_outline),
                  label: Text(t.repositoryRemove),
                  onPressed: () => _confirmRemove(context, notifier, t),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmRemove(
    BuildContext context,
    ContentReposNotifier notifier,
    AppLocalizations t,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.repositoryRemoveTitle(repo.name)),
        content: Text(t.repositoryRemoveMessage),
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
    if (ok == true) await notifier.remove(repo);
  }
}

class _AddRepoDialog extends StatefulWidget {
  const _AddRepoDialog();

  @override
  State<_AddRepoDialog> createState() => _AddRepoDialogState();
}

class _AddRepoDialogState extends State<_AddRepoDialog> {
  final _controller = TextEditingController(text: 'https://');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    void submit() => Navigator.pop(context, _controller.text.trim());
    return AlertDialog(
      title: Text(t.repositoryAdd),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.url,
        autocorrect: false,
        decoration: InputDecoration(labelText: t.repositoryUrlLabel),
        onSubmitted: (_) => submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.cancelAction),
        ),
        FilledButton(onPressed: submit, child: Text(t.repositoryCheck)),
      ],
    );
  }
}

/// Must be accepted before any third-party repository is saved.
class _DisclaimerDialog extends StatefulWidget {
  const _DisclaimerDialog({required this.index, required this.url});

  final RepoIndex index;
  final String url;

  @override
  State<_DisclaimerDialog> createState() => _DisclaimerDialogState();
}

class _DisclaimerDialogState extends State<_DisclaimerDialog> {
  bool _understood = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final index = widget.index;
    return AlertDialog(
      title: Text(t.repositoryDisclaimerTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(index.name, style: theme.textTheme.titleMedium),
            Text(widget.url, style: theme.textTheme.bodySmall),
            if (index.maintainer != null)
              Text(t.repositoryMaintainer(index.maintainer!)),
            const SizedBox(height: 12),
            Text(t.repositoryDisclaimerBody),
            if (index.disclaimer != null) ...[
              const SizedBox(height: 12),
              Text(t.repositoryOwnerNote, style: theme.textTheme.labelMedium),
              Text(index.disclaimer!),
            ],
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _understood,
              onChanged: (v) => setState(() => _understood = v ?? false),
              title: Text(t.repositoryDisclaimerAccept),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(t.cancelAction),
        ),
        FilledButton(
          onPressed: _understood ? () => Navigator.pop(context, true) : null,
          child: Text(t.repositoryAdd),
        ),
      ],
    );
  }
}
