import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:flutter/material.dart';

// =============================================================================
// Language filter row
// =============================================================================

class LanguageFilterRow extends StatelessWidget {
  const LanguageFilterRow({
    super.key,
    required this.languages,
    required this.selected,
    required this.onSelected,
  });

  final List<String> languages;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final label = selected ?? t.allLanguagesOption;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        // Only tappable when there are multiple languages to choose from.
        onTap: languages.length <= 1
            ? null
            : () async {
                final picked = await showDialog<String?>(
                  context: context,
                  builder: (context) =>
                      LanguagePickerDialog(languages: languages),
                );
                if (picked == null) return; // dismissed
                // Empty string sentinel means "All languages".
                onSelected(picked.isEmpty ? null : picked);
              },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Row(
            children: [
              Icon(Icons.language, size: 20, color: colors.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Text(t.languageFilterLabel, style: textTheme.bodyLarge),
              ),
              Text(
                label,
                style: textTheme.bodyLarge?.copyWith(color: colors.primary),
              ),
              const SizedBox(width: 4),
              if (languages.length > 1)
                Icon(Icons.chevron_right, size: 20, color: colors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class LanguagePickerDialog extends StatelessWidget {
  const LanguagePickerDialog({super.key, required this.languages});
  final List<String> languages;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return SimpleDialog(
      title: Text(t.selectLanguageTitle),
      children: [
        SimpleDialogOption(
          onPressed: () => Navigator.of(context).pop(''),
          child: Text(t.allLanguagesOption),
        ),
        for (final lang in languages)
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(lang),
            child: Text(lang),
          ),
      ],
    );
  }
}

// =============================================================================
// Section header
// =============================================================================

class TranslationSectionHeader extends StatelessWidget {
  const TranslationSectionHeader({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

// =============================================================================
// Translation list tile
// =============================================================================

enum TranslationTileAction { removeDownloaded, deleteImported, openForSession }

class TranslationTile extends StatelessWidget {
  const TranslationTile({
    super.key,
    required this.translation,
    required this.isSelected,
    required this.isLoading,
    required this.onTap,
    this.onOpenForSession,
    this.onDownload,
    this.onRemoveDownloaded,
    this.onDeleteImported,
  });

  final BibleTranslation translation;
  final bool isSelected;
  final bool isLoading;
  final VoidCallback? onTap;
  final VoidCallback? onOpenForSession;
  final VoidCallback? onDownload;
  final VoidCallback? onRemoveDownloaded;
  final VoidCallback? onDeleteImported;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final t = AppLocalizations.of(context)!;

    final hasMenu = onRemoveDownloaded != null || onDeleteImported != null;
    final hasSecondaryActions = hasMenu || onOpenForSession != null;
    final isStoredLocally =
        translation.availability == BibleTranslationAvailability.bundled ||
        translation.availability == BibleTranslationAvailability.downloaded ||
        translation.availability == BibleTranslationAvailability.imported;

    final Widget statusAction = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.primary,
            ),
          )
        : isStoredLocally
        ? Tooltip(
            message: t.availableOfflineTooltip,
            child: Icon(Icons.check_circle, color: colors.primary),
          )
        : IconButton(
            tooltip: t.downloadAction,
            onPressed: onDownload,
            icon: const Icon(Icons.download_rounded),
            color: colors.primary,
          );

    final Widget? overflowMenu = !hasSecondaryActions
        ? null
        : PopupMenuButton<TranslationTileAction>(
            icon: const Icon(Icons.more_vert),
            onSelected: (action) {
              switch (action) {
                case TranslationTileAction.removeDownloaded:
                  onRemoveDownloaded?.call();
                case TranslationTileAction.deleteImported:
                  onDeleteImported?.call();
                case TranslationTileAction.openForSession:
                  onOpenForSession?.call();
              }
            },
            itemBuilder: (context) => [
              if (onOpenForSession != null)
                PopupMenuItem(
                  value: TranslationTileAction.openForSession,
                  child: Text(t.openForSessionAction),
                ),
              if (onRemoveDownloaded != null)
                PopupMenuItem(
                  value: TranslationTileAction.removeDownloaded,
                  child: Text(t.removeDownloadAction),
                ),
              if (onDeleteImported != null)
                PopupMenuItem(
                  value: TranslationTileAction.deleteImported,
                  child: Text(t.deleteAction),
                ),
            ],
          );

    return ListTile(
      onTap: isLoading ? null : onTap,
      tileColor: isSelected
          ? colors.primaryContainer.withValues(alpha: 0.25)
          : null,
      title: Text(
        translation.id.toUpperCase(),
        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        translation.name,
        style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          statusAction,
          if (overflowMenu != null) ...[
            const SizedBox(width: 4),
            overflowMenu,
          ],
        ],
      ),
    );
  }
}
