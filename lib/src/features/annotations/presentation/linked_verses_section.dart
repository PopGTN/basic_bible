import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/utils/reference_utils.dart';
import 'package:flutter/material.dart';

class LinkedVersesSection extends StatelessWidget {
  const LinkedVersesSection({
    super.key,
    required this.books,
    required this.links,
    required this.onPreviewLinkedVerse,
    this.onDeleteLink,
    this.title = 'Linked Verses',
    this.maxVisible = 24,
    this.emptyMessage,
  });

  final List<BibleBook> books;
  final List<AnnotationVerseLink> links;
  final Future<void> Function(AnnotationVerseLink link) onPreviewLinkedVerse;
  /// When provided, each chip shows a delete icon. Tapping it calls this
  /// callback — the caller decides whether to confirm before removing.
  final void Function(AnnotationVerseLink link)? onDeleteLink;
  final String title;
  final int maxVisible;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (links.isEmpty) {
      if (emptyMessage == null) return const SizedBox.shrink();
      return Text(emptyMessage!);
    }

    final theme = Theme.of(context);
    final visibleLinks = links.take(maxVisible).toList(growable: false);
    final hiddenCount = links.length - visibleLinks.length;
    final canDelete = onDeleteLink != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final link in visibleLinks)
              if (canDelete)
                InputChip(
                  onPressed: () => onPreviewLinkedVerse(link),
                  avatar: const Icon(Icons.visibility_outlined, size: 16),
                  label: Text(
                    '${displayBookNameForReference(books, link.bookId)} '
                    '${link.chapter}:${link.verse}',
                  ),
                  onDeleted: () => onDeleteLink!(link),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  deleteButtonTooltipMessage: 'Remove',
                )
              else
                ActionChip(
                  onPressed: () => onPreviewLinkedVerse(link),
                  avatar: const Icon(Icons.visibility_outlined, size: 16),
                  label: Text(
                    '${displayBookNameForReference(books, link.bookId)} '
                    '${link.chapter}:${link.verse}',
                  ),
                ),
            if (hiddenCount > 0)
              Chip(
                label: Text('+$hiddenCount more'),
                avatar: const Icon(Icons.more_horiz, size: 16),
              ),
          ],
        ),
        if (hiddenCount > 0) ...[
          const SizedBox(height: 8),
          Text(
            'Showing ${visibleLinks.length} of ${links.length} linked verses.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
