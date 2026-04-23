import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';
import 'package:basic_bible/src/features/annotations/presentation/annotation_theme.dart';
import 'package:basic_bible/src/features/annotations/presentation/linked_verses_section.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/utils/reference_utils.dart';
import 'package:flutter/material.dart';

class AnnotationDetailScreen extends StatelessWidget {
  const AnnotationDetailScreen({
    super.key,
    required this.annotation,
    required this.books,
    required this.onPreviewLinkedVerse,
    required this.onOpenReference,
    required this.onEdit,
    required this.onDelete,
  });

  final UserAnnotation annotation;
  final List<BibleBook> books;
  final Future<void> Function(AnnotationVerseLink link) onPreviewLinkedVerse;
  final Future<void> Function() onOpenReference;
  final Future<void> Function() onEdit;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final highlightColor = annotation.highlightColorValue == null
        ? null
        : annotationColorFromValue(
            annotation.highlightColorValue,
            theme.colorScheme.primary,
          );
    final primary = annotation.primaryVerse;
    final referenceLabel =
        '${displayBookNameForReference(books, primary.bookId)} '
        '${primary.chapter}:${primary.verse}';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          annotation.hasNoteText ? 'Note Details' : 'Highlight Details',
        ),
        actions: [
          IconButton(
            onPressed: () async => onEdit(),
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
          ),
          IconButton(
            onPressed: () async => onDelete(),
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _TypePill(
                      label: annotation.hasNoteText ? 'Note' : 'Highlight',
                    ),
                    if (highlightColor != null)
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: highlightColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    Text(
                      primary.translationName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  referenceLabel,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: annotation.hasNoteText ? () async => onEdit() : null,
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
                  const SizedBox(height: 16),
                  LinkedVersesSection(
                    books: books,
                    links: annotation.linkedVerses,
                    onPreviewLinkedVerse: onPreviewLinkedVerse,
                  ),
                ],
                if (annotation.labels.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Labels',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final label in annotation.labels)
                        Chip(label: Text(label)),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () async => onOpenReference(),
                      icon: const Icon(Icons.menu_book_outlined),
                      label: const Text('Open in Reader'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () async => onEdit(),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  const _TypePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
