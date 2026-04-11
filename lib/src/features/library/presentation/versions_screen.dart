import 'package:basic_bible/src/features/library/data/app_bible_repository.dart';
import 'package:basic_bible/src/features/reader/application/view_models/bible_library_view_models.dart';
import 'package:basic_bible/src/features/reader/application/view_models/reader_session_view_models.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/widgets/app_back_button.dart';
import 'package:basic_bible/src/features/library/presentation/import_translation_screen.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VersionsScreen extends ConsumerWidget {
  const VersionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationsAsync = ref.watch(availableTranslationsProvider);
    final currentTranslationId = ref.watch(currentTranslationProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Versions'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
            tooltip: 'Search translations',
          ),
          PopupMenuButton<_VersionsMenuAction>(
            onSelected: (action) {
              switch (action) {
                case _VersionsMenuAction.importBibleXml:
                  _importBibleFile(context, ref);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _VersionsMenuAction.importBibleXml,
                child: Row(
                  children: [
                    Icon(Icons.upload_file),
                    SizedBox(width: 8),
                    Text('Import Bible File'),
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
            child: Text('Unable to load translations: $error'),
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
        SnackBar(content: Text('Could not switch translation: $error')),
      );
    }
  }

  Future<void> _importBibleFile(BuildContext context, WidgetRef ref) async {
    const bibleFileTypeGroup = XTypeGroup(
      label: 'Bible files',
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
        SnackBar(content: Text('Imported ${importedTranslation.name}.')),
      );
    } catch (error) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Import failed: $error')));
    }
  }

  Future<void> _deleteImportedTranslation(
    BuildContext context,
    WidgetRef ref, {
    required BibleTranslation translation,
    required String currentTranslationId,
    required List<BibleTranslation> allTranslations,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${translation.name}?'),
        content: Text(
          'This removes the imported Bible from the app library and cache. The original file on disk will not be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Deleted ${translation.name}.')));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete translation: $error')),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove ${translation.name} download?'),
        content: const Text(
          'This removes the downloaded Bible from local app storage. It will stay in the library as a downloadable option so you can download it again later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
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
          content: Text('Removed local download for ${translation.name}.'),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not remove download: $error')),
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
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final sourceLabel = switch (translation.sourceType) {
      BibleSourceType.asset => 'Bundled',
      BibleSourceType.download =>
        translation.isLocal ? 'Downloaded' : 'Downloadable',
      BibleSourceType.import => 'Imported',
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
                      const PopupMenuItem(
                        value: _TranslationAction.deleteImported,
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline),
                            SizedBox(width: 8),
                            Text('Delete import'),
                          ],
                        ),
                      ),
                    if (onRemoveDownloaded != null)
                      const PopupMenuItem(
                        value: _TranslationAction.removeDownloaded,
                        child: Row(
                          children: [
                            Icon(Icons.delete_sweep_outlined),
                            SizedBox(width: 8),
                            Text('Remove download'),
                          ],
                        ),
                      ),
                  ],
                  icon: const Icon(Icons.more_vert),
                  tooltip: 'More actions',
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
          tooltip: 'Available offline',
          color: colors.primaryContainer,
          iconColor: colors.onPrimaryContainer,
        ),
      );
    } else if (translation.githubUrl != null) {
      buttons.add(
        _TranslationActionChip(
          icon: Icons.download_rounded,
          tooltip: 'Download translation',
          color: colors.surfaceContainerHigh,
        ),
      );
    }

    if (translation.sourceType != BibleSourceType.import) {
      buttons.add(
        _TranslationActionChip(
          icon: Icons.volume_up_outlined,
          tooltip: 'Audio options',
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
