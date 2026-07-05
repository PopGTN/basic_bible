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
    required this.onCreate,
    required this.onPreviewLinkedVerse,
    required this.onOpenReference,
    required this.onViewDetails,
    required this.onEdit,
    required this.onDelete,
  });

  final String referenceLabel;
  final String verseText;
  final List<BibleBook> books;
  final List<UserAnnotation> annotations;
  final Future<void> Function() onCreate;
  final Future<void> Function(AnnotationVerseLink link) onPreviewLinkedVerse;
  final ValueChanged<UserAnnotation> onOpenReference;
  final ValueChanged<UserAnnotation> onViewDetails;
  final ValueChanged<UserAnnotation> onEdit;
  final ValueChanged<UserAnnotation> onDelete;

  @override
  Widget build(BuildContext context) {
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
                      ? 'Saved Annotation'
                      : 'Saved Annotations',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: () => onCreate(),
                    icon: const Icon(Icons.note_add_outlined),
                    label: const Text('Add Note'),
                  ),
                ),
                const SizedBox(height: 12),
                for (final annotation in annotations) ...[
                  _PersonalNoteCard(
                    annotation: annotation,
                    books: books,
                    onPreviewLinkedVerse: onPreviewLinkedVerse,
                    onOpenReference: () => onOpenReference(annotation),
                    onViewDetails: () => onViewDetails(annotation),
                    onEdit: () => onEdit(annotation),
                    onDelete: () => onDelete(annotation),
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
    required this.onViewDetails,
    required this.onEdit,
    required this.onDelete,
  });

  final UserAnnotation annotation;
  final List<BibleBook> books;
  final Future<void> Function(AnnotationVerseLink link) onPreviewLinkedVerse;
  final VoidCallback onOpenReference;
  final VoidCallback onViewDetails;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onViewDetails,
        borderRadius: BorderRadius.circular(12),
        child: Container(
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
              InkWell(
                onTap: annotation.hasNoteText ? () => onViewDetails() : null,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: annotation.hasNoteText
                        ? theme.colorScheme.surfaceContainerHighest
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    annotation.noteText?.trim().isNotEmpty == true
                        ? annotation.noteText!.trim()
                        : 'Saved highlight',
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (annotation.linkedVerses.isNotEmpty) ...[
                const SizedBox(height: 12),
                LinkedVersesSection(
                  books: books,
                  links: annotation.linkedVerses,
                  onPreviewLinkedVerse: onPreviewLinkedVerse,
                  maxVisible: 3,
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  TextButton.icon(
                    onPressed: onOpenReference,
                    icon: const Icon(Icons.menu_book_outlined),
                    label: Text(l10n.openAction),
                  ),
                  TextButton.icon(
                    onPressed: onViewDetails,
                    icon: const Icon(Icons.visibility_outlined),
                    label: const Text('View'),
                  ),
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    label: Text(l10n.editAction),
                  ),
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
