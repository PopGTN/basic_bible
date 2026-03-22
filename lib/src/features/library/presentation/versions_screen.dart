import 'package:basic_bible/src/features/reader/application/bible_provider.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/widgets/app_back_button.dart';
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
                    Text('Import Bible XML'),
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
    final messenger = ScaffoldMessenger.of(context);

    try {
      await ref
          .read(currentTranslationProvider.notifier)
          .setTranslation(translationId);
      await ref
          .read(bibleBooksProvider.notifier)
          .changeTranslation(translationId);

      if (!context.mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Translation selected.')),
      );
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Could not switch translation: $error')),
      );
    }
  }

  Future<void> _importBibleFile(BuildContext context, WidgetRef ref) async {
    const xmlTypeGroup = XTypeGroup(
      label: 'Bible XML',
      extensions: <String>['xml', 'usfx', 'osis'],
    );
    final file = await openFile(acceptedTypeGroups: [xmlTypeGroup]);
    if (file == null || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    try {
      final importedTranslation = await ref
          .read(bibleBooksProvider.notifier)
          .importTranslation(file.path);
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
}

enum _VersionsMenuAction { importBibleXml }

class _TranslationListTile extends StatelessWidget {
  const _TranslationListTile({
    required this.translation,
    required this.isSelected,
    required this.onTap,
  });

  final BibleTranslation translation;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final sourceLabel = switch (translation.sourceType) {
      BibleSourceType.asset => 'Bundled',
      BibleSourceType.download => 'Downloaded',
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
              IconButton(
                onPressed: () {},
                tooltip: 'More actions',
                icon: const Icon(Icons.more_vert),
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

    // The first Versions screen pass is intentionally lightweight: these
    // chips show the planned affordances without yet committing the app to
    // full download/audio/library workflows.
    if (translation.githubUrl != null) {
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

class _TranslationActionChip extends StatelessWidget {
  const _TranslationActionChip({
    required this.icon,
    required this.tooltip,
    required this.color,
  });

  final IconData icon;
  final String tooltip;
  final Color color;

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
          icon: Icon(icon),
        ),
      ),
    );
  }
}
