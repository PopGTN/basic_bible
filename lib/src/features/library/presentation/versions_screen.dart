import 'package:basic_bible/src/features/library/data/app_bible_repository.dart';
import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:basic_bible/src/features/reader/application/view_models/bible_library_view_models.dart';
import 'package:basic_bible/src/features/reader/application/view_models/reader_session_view_models.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/platform/runtime_support.dart';
import 'package:basic_bible/src/widgets/app_back_button.dart';
import 'package:basic_bible/src/features/library/presentation/import_translation_screen.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VersionsScreen extends ConsumerWidget {
  const VersionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final translationsAsync = ref.watch(availableTranslationsProvider);
    final currentTranslationId = ref.watch(currentTranslationProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(t.versionsTitle),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
            tooltip: t.searchTranslationsTooltip,
          ),
          PopupMenuButton<_VersionsMenuAction>(
            onSelected: (action) {
              switch (action) {
                case _VersionsMenuAction.importBibleXml:
                  _importBibleFile(context, ref);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _VersionsMenuAction.importBibleXml,
                child: Row(
                  children: [
                    const Icon(Icons.upload_file),
                    const SizedBox(width: 8),
                    Text(t.importBibleFileAction),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: translationsAsync.when(
        data: (translations) => ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: translations.length,
          separatorBuilder: (context, index) => const SizedBox(height: 6),
          itemBuilder: (context, index) {
            final translation = translations[index];
            final isSelected = translation.id == currentTranslationId;

            return _TranslationListTile(
              translation: translation,
              isSelected: isSelected,
              onTap: () => _selectTranslation(context, ref, translation.id),
              onDeleteImported: translation.sourceType == BibleSourceType.import
                  ? () => _deleteImportedTranslation(
                      context,
                      ref,
                      translation: translation,
                      currentTranslationId: currentTranslationId,
                      allTranslations: translations,
                    )
                  : null,
              onRemoveDownloaded:
                  translation.sourceType == BibleSourceType.download &&
                      translation.isLocal
                  ? () => _removeDownloadedTranslation(
                      context,
                      ref,
                      translation: translation,
                      currentTranslationId: currentTranslationId,
                      allTranslations: translations,
                    )
                  : null,
            );
          },
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(t.unableToLoadTranslations(error.toString())),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      backgroundColor: colors.surface,
    );
  }

  Future<void> _selectTranslation(
    BuildContext context,
    WidgetRef ref,
    String translationId,
  ) async {
    final t = AppLocalizations.of(context)!;
    try {
      await ref
          .read(currentTranslationProvider.notifier)
          .setTranslation(translationId);

      if (!context.mounted) return;
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.couldNotSwitchTranslation(error.toString()))),
      );
    }
  }

  Future<void> _importBibleFile(BuildContext context, WidgetRef ref) async {
    final t = AppLocalizations.of(context)!;
    if (isWebRuntime) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Importing local Bible files is not available in the browser yet.',
          ),
        ),
      );
      return;
    }

    final bibleFileTypeGroup = XTypeGroup(
      label: t.translationsFileTypeLabel,
      extensions: <String>['xml', 'usfx', 'osis', 'sqlite', 'sqlite3', 'db'],
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
                        .map((translation) => translation.id)
                        .toSet() ??
                    const <String>{},
              ),
            ),
          );
      if (importedTranslation == null || !context.mounted) return;
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

  Future<void> _deleteImportedTranslation(
    BuildContext context,
    WidgetRef ref, {
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
          (candidate) => candidate.id != translation.id,
          orElse: () => AppBibleRepository.builtInTranslations.first,
        );
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

  Future<void> _removeDownloadedTranslation(
    BuildContext context,
    WidgetRef ref, {
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
          (candidate) => candidate.id != translation.id,
          orElse: () => AppBibleRepository.builtInTranslations.first,
        );
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

enum _VersionsMenuAction { importBibleXml }

class _TranslationListTile extends StatelessWidget {
  const _TranslationListTile({
    required this.translation,
    required this.isSelected,
    required this.onTap,
    this.onDeleteImported,
    this.onRemoveDownloaded,
  });

  final BibleTranslation translation;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onDeleteImported;
  final VoidCallback? onRemoveDownloaded;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final sourceLabel = switch (translation.sourceType) {
      BibleSourceType.asset => t.bundledTranslationSource,
      BibleSourceType.download =>
        translation.isLocal
            ? t.downloadedTranslationSource
            : t.downloadableTranslationSource,
      BibleSourceType.import => t.importedTranslationSource,
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            translation.id.toUpperCase(),
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? colors.onSurface
                                  : colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ..._buildActionButtons(context, translation),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      translation.name,
                      style: textTheme.titleMedium?.copyWith(
                        color: isSelected
                            ? colors.onSurface
                            : colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$sourceLabel • ${translation.language.toUpperCase()}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.outline,
                      ),
                    ),
                    if (translation.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        translation.description,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (onDeleteImported != null || onRemoveDownloaded != null)
                PopupMenuButton<_TranslationAction>(
                  onSelected: (action) {
                    if (action == _TranslationAction.deleteImported) {
                      onDeleteImported!();
                    } else if (action == _TranslationAction.removeDownloaded) {
                      onRemoveDownloaded!();
                    }
                  },
                  itemBuilder: (context) => [
                    if (onDeleteImported != null)
                      PopupMenuItem(
                        value: _TranslationAction.deleteImported,
                        child: Row(
                          children: [
                            const Icon(Icons.delete_outline),
                            const SizedBox(width: 8),
                            Text(t.deleteImportAction),
                          ],
                        ),
                      ),
                    if (onRemoveDownloaded != null)
                      PopupMenuItem(
                        value: _TranslationAction.removeDownloaded,
                        child: Row(
                          children: [
                            const Icon(Icons.delete_sweep_outlined),
                            const SizedBox(width: 8),
                            Text(t.removeDownloadAction),
                          ],
                        ),
                      ),
                  ],
                  icon: const Icon(Icons.more_vert),
                  tooltip: t.moreActionsTooltip,
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActionButtons(
    BuildContext context,
    BibleTranslation translation,
  ) {
    final t = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final buttons = <Widget>[];
    final isAvailableOffline =
        translation.isLocal ||
        translation.sourceType == BibleSourceType.asset ||
        translation.sourceType == BibleSourceType.import ||
        (translation.filePath?.isNotEmpty ?? false);

    // The first Versions screen pass is intentionally lightweight: these
    // chips show the planned affordances without yet committing the app to
    // full download/audio/library workflows.
    if (isAvailableOffline) {
      buttons.add(
        _TranslationActionChip(
          icon: Icons.check_rounded,
          tooltip: t.availableOfflineTooltip,
          color: colors.primaryContainer,
          iconColor: colors.onPrimaryContainer,
        ),
      );
    } else if (translation.githubUrl != null) {
      buttons.add(
        _TranslationActionChip(
          icon: Icons.download_rounded,
          tooltip: t.downloadTranslationTooltip,
          color: colors.surfaceContainerHigh,
        ),
      );
    }

    if (translation.sourceType != BibleSourceType.import) {
      buttons.add(
        _TranslationActionChip(
          icon: Icons.volume_up_outlined,
          tooltip: t.audioOptionsTooltip,
          color: colors.surfaceContainerHigh,
        ),
      );
    }

    final widgets = <Widget>[];
    for (var i = 0; i < buttons.length; i++) {
      widgets.add(buttons[i]);
      if (i < buttons.length - 1) {
        widgets.add(const SizedBox(width: 8));
      }
    }

    return widgets;
  }
}

enum _TranslationAction { deleteImported, removeDownloaded }

class _TranslationActionChip extends StatelessWidget {
  const _TranslationActionChip({
    required this.icon,
    required this.tooltip,
    required this.color,
    this.iconColor,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: IconButton(
          onPressed: () {},
          splashRadius: 18,
          iconSize: 18,
          icon: Icon(
            icon,
            color: iconColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
