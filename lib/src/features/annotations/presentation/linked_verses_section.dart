import 'package:basic_bible/src/features/annotations/models/annotation_verse_ranges.dart';
import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/utils/reference_utils.dart';
import 'package:flutter/material.dart';

/// How many linked-reference chips a note *preview* (Notes list card, reader
/// notes sheet) shows before collapsing the rest into "+N more". Shared so the
/// two previews truncate identically (#82). Full detail views show everything.
const int kLinkedReferencesPreviewLimit = 3;

class LinkedVersesSection extends StatelessWidget {
  /// One chip per linked verse. Use this where individual verses can be
  /// removed (e.g. the note editor).
  LinkedVersesSection({
    super.key,
    required this.books,
    required List<AnnotationVerseLink> links,
    required this.onPreviewLinkedVerse,
    this.onDeleteLink,
    this.title = 'Linked Verses',
    this.maxVisible = 24,
    this.emptyMessage,
  }) : ranges = [for (final link in links) AnnotationVerseRange([link])];

  /// One chip per run of consecutive verses ("Genesis 1:2-5"). Read-only:
  /// tapping a chip previews the first verse of its range.
  const LinkedVersesSection.grouped({
    super.key,
    required this.books,
    required this.ranges,
    required this.onPreviewLinkedVerse,
    this.title = 'Linked Verses',
    this.maxVisible = 24,
    this.emptyMessage,
  }) : onDeleteLink = null;

  final List<BibleBook> books;
  final List<AnnotationVerseRange> ranges;
  final Future<void> Function(AnnotationVerseLink link) onPreviewLinkedVerse;

  /// When provided, each chip shows a delete icon. Tapping it calls this
  /// callback — the caller decides whether to confirm before removing.
  final void Function(AnnotationVerseLink link)? onDeleteLink;
  final String title;
  final int maxVisible;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (ranges.isEmpty) {
      if (emptyMessage == null) return const SizedBox.shrink();
      return Text(emptyMessage!);
    }

    final theme = Theme.of(context);
    final visibleRanges = ranges.take(maxVisible).toList(growable: false);
    final hiddenCount = ranges.length - visibleRanges.length;
    final canDelete = onDeleteLink != null;

    String labelFor(AnnotationVerseRange range) =>
        range.label(displayBookNameForReference(books, range.bookId));

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
            for (final range in visibleRanges)
              if (canDelete)
                InputChip(
                  onPressed: () => onPreviewLinkedVerse(range.first),
                  avatar: const Icon(Icons.visibility_outlined, size: 16),
                  label: Text(labelFor(range)),
                  onDeleted: () => onDeleteLink!(range.first),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  deleteButtonTooltipMessage: 'Remove',
                )
              else
                ActionChip(
                  onPressed: () => onPreviewLinkedVerse(range.first),
                  avatar: const Icon(Icons.visibility_outlined, size: 16),
                  label: Text(labelFor(range)),
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
            'Showing ${visibleRanges.length} of ${ranges.length} linked '
            'references.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
