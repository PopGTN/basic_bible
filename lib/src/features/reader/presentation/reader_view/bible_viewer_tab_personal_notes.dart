part of 'bible_viewer_tab.dart';

/// Personal notes sheet and note row rendering for the reader.
///
/// Notes are conceptually separate from parser annotations, so keeping them in
/// their own part file makes the reader easier to scan and safer to evolve.
class _PersonalNotesSheet extends StatelessWidget {
  const _PersonalNotesSheet({
    required this.referenceLabel,
    required this.verseText,
    required this.books,
    required this.annotations,
    required this.onPreviewLinkedVerse,
    required this.onOpenReference,
    required this.onEdit,
  });

  final String referenceLabel;
  final String verseText;
  final List<BibleBook> books;
  final List<UserAnnotation> annotations;
  final Future<void> Function(AnnotationVerseLink link) onPreviewLinkedVerse;
  final ValueChanged<UserAnnotation> onOpenReference;
  final ValueChanged<UserAnnotation> onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        minChildSize: 0.18,
        maxChildSize: 0.96,
        snap: true,
        snapSizes: const [0.5, 0.96],
        shouldCloseOnMinExtent: true,
        builder: (context, controller) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: ListView(
              controller: controller,
              children: [
                Text(
                  referenceLabel,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.55,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    verseText,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  annotations.length == 1
                      ? l10n.savedNoteLabel
                      : l10n.savedNotesLabel,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                for (final annotation in annotations) ...[
                  _PersonalNoteCard(
                    annotation: annotation,
                    books: books,
                    onPreviewLinkedVerse: onPreviewLinkedVerse,
                    onOpenReference: () => onOpenReference(annotation),
                    onEdit: () => onEdit(annotation),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PersonalNoteCard extends StatelessWidget {
  const _PersonalNoteCard({
    required this.annotation,
    required this.books,
    required this.onPreviewLinkedVerse,
    required this.onOpenReference,
    required this.onEdit,
  });

  final UserAnnotation annotation;
  final List<BibleBook> books;
  final Future<void> Function(AnnotationVerseLink link) onPreviewLinkedVerse;
  final VoidCallback onOpenReference;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final primaryVerse = annotation.primaryVerse;
    final primaryReferenceLabel =
        '${displayBookNameForReference(books, primaryVerse.bookId)} '
        '${primaryVerse.chapter}:${primaryVerse.verse}';
    final highlightColor = annotation.highlightColorValue == null
        ? null
        : annotationColorFromValue(
            annotation.highlightColorValue,
            colors.secondary,
          );

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 4, 4, 14),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: (highlightColor ?? colors.secondary).withValues(alpha: 0.7),
            width: 3,
          ),
          bottom: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  primaryReferenceLabel,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colors.secondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              if (highlightColor != null)
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: highlightColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            annotation.noteText ?? '',
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
          if (annotation.linkedVerses.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final link in annotation.linkedVerses)
                  ActionChip(
                    onPressed: () => onPreviewLinkedVerse(link),
                    avatar: const Icon(Icons.visibility_outlined, size: 16),
                    label: Text(
                      '${displayBookNameForReference(books, link.bookId)} '
                      '${link.chapter}:${link.verse}',
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                onPressed: onOpenReference,
                icon: const Icon(Icons.menu_book_outlined),
                label: Text(l10n.openAction),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: Text(l10n.editAction),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
