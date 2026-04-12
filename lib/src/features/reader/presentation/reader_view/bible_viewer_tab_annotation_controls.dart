part of 'bible_viewer_tab.dart';

/// Compact reader controls that are shared across verse-list and document mode.
///
/// Keeping these small interaction widgets together makes it easier to tune
/// selection affordances without hunting through the larger sheet/content files.
class _VerseAnnotationButton extends StatelessWidget {
  const _VerseAnnotationButton({required this.onPressed, this.compact = false});

  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Tooltip(
      message: l10n.readerFootnotesTooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            width: compact ? 22 : 30,
            height: compact ? 22 : 30,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.38),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.notes_outlined,
              size: compact ? 14 : 18,
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _VerseNoteButton extends StatelessWidget {
  const _VerseNoteButton({required this.onPressed, this.compact = false});

  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Tooltip(
      message: l10n.readerNotesTooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            width: compact ? 22 : 30,
            height: compact ? 22 : 30,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.38),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.sticky_note_2_outlined,
              size: compact ? 14 : 18,
              color: colors.secondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _InlineVerseSelector extends StatelessWidget {
  const _InlineVerseSelector({
    required this.verseNumber,
    required this.color,
    required this.isSelected,
    required this.hasNote,
    required this.onTap,
    this.inlineOnly = false,
    this.backgroundColor,
  });

  final int verseNumber;
  final Color color;
  final bool isSelected;
  final bool hasNote;
  final VoidCallback onTap;
  final bool inlineOnly;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final numberText = Text(
      '$verseNumber',
      style: TextStyle(fontWeight: FontWeight.bold, color: color),
    );

    if (inlineOnly) {
      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              numberText,
              if (hasNote) ...[
                const SizedBox(width: 3),
                Icon(
                  Icons.bookmark_rounded,
                  size: 11,
                  color: theme.colorScheme.secondary,
                ),
              ],
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.secondary.withValues(alpha: 0.16)
              : null,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.5),
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            numberText,
            if (hasNote) ...[
              const SizedBox(width: 3),
              Icon(
                Icons.bookmark_rounded,
                size: 12,
                color: theme.colorScheme.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VerseSelectionBar extends StatelessWidget {
  const _VerseSelectionBar({
    required this.references,
    required this.books,
    required this.existingAnnotations,
    required this.showHighlightPalette,
    required this.isBusy,
    required this.onDismiss,
    required this.onHighlightPressed,
    required this.onHighlightSelected,
    required this.onClearHighlightPressed,
    required this.onNotePressed,
    required this.onCopyPressed,
    required this.onSharePressed,
  });

  final List<BibleReference> references;
  final List<BibleBook> books;
  final List<UserAnnotation> existingAnnotations;
  final bool showHighlightPalette;
  final bool isBusy;
  final VoidCallback onDismiss;
  final VoidCallback onHighlightPressed;
  final ValueChanged<Color> onHighlightSelected;
  final VoidCallback onClearHighlightPressed;
  final VoidCallback onNotePressed;
  final VoidCallback onCopyPressed;
  final VoidCallback onSharePressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstReference = references.first;
    final referenceLabel = references.length == 1
        ? '${displayBookNameForReference(books, firstReference.bookId)} '
              '${firstReference.chapter}:${firstReference.verse ?? ''}'
        : '${references.length} verses selected';
    final hasSavedNote = existingAnnotations.any(
      (annotation) => annotation.hasNoteText,
    );
    final hasHighlight = existingAnnotations.any(
      (annotation) => annotation.highlightColorValue != null,
    );
    final hasStandaloneHighlight = existingAnnotations.any(
      (annotation) => annotation.isHighlightOnly,
    );
    final hasNoteHighlight = existingAnnotations.any(
      (annotation) => annotation.hasNoteText && annotation.hasHighlight,
    );

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    referenceLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (hasSavedNote || hasHighlight)
                  Text(
                    [
                      if (hasSavedNote) 'saved note',
                      if (hasHighlight) 'saved highlight',
                    ].join(' • '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                IconButton(
                  onPressed: isBusy ? null : onDismiss,
                  icon: const Icon(Icons.close),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _SelectionActionButton(
                    icon: Icons.highlight_alt_rounded,
                    label: 'Highlight',
                    onPressed: isBusy ? null : onHighlightPressed,
                  ),
                  _SelectionActionButton(
                    icon: Icons.note_alt_outlined,
                    label: 'Note',
                    onPressed: isBusy ? null : onNotePressed,
                  ),
                  _SelectionActionButton(
                    icon: Icons.copy_all_outlined,
                    label: 'Copy',
                    onPressed: isBusy ? null : onCopyPressed,
                  ),
                  _SelectionActionButton(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    onPressed: isBusy ? null : onSharePressed,
                  ),
                ],
              ),
            ),
            if (showHighlightPalette) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  if (hasStandaloneHighlight)
                    InkWell(
                      onTap: isBusy ? null : onClearHighlightPressed,
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.onSurface,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  for (final color in annotationHighlightPalette)
                    InkWell(
                      onTap: isBusy ? null : () => onHighlightSelected(color),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.onSurface,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (hasNoteHighlight && !hasStandaloneHighlight) ...[
                const SizedBox(height: 8),
                Text(
                  'Note highlights are edited from the note itself.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _SelectionActionButton extends StatelessWidget {
  const _SelectionActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
      ),
    );
  }
}
