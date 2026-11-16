import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:basic_bible/src/features/annotations/models/annotation_verse_ranges.dart';
import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/utils/reference_utils.dart';
import 'package:flutter/material.dart';

/// How many linked-reference chips a note *preview* (Notes list card, reader
/// notes sheet) shows before collapsing the rest behind "Show all". Shared so
/// the two previews truncate identically (#82).
const int kLinkedReferencesPreviewLimit = 3;

class LinkedVersesSection extends StatefulWidget {
  /// One chip per linked verse, in reading order. Use this where individual
  /// verses can be removed (e.g. the note editor).
  LinkedVersesSection({
    super.key,
    required this.books,
    required List<AnnotationVerseLink> links,
    required this.onPreviewVerses,
    this.onDeleteLink,
    this.title = 'Linked Verses',
    this.maxVisible = 24,
    this.emptyMessage,
  }) : ranges = [
         for (final link in sortVerseLinksInReadingOrder(links))
           AnnotationVerseRange([link]),
       ];

  /// One chip per run of consecutive verses ("Genesis 1:2-5"). Read-only:
  /// tapping a chip previews the whole range.
  const LinkedVersesSection.grouped({
    super.key,
    required this.books,
    required this.ranges,
    required this.onPreviewVerses,
    this.title = 'Linked Verses',
    this.maxVisible = 24,
    this.emptyMessage,
  }) : onDeleteLink = null;

  final List<BibleBook> books;
  final List<AnnotationVerseRange> ranges;
  /// Called with the tapped chip's verses (one verse, or a range like
  /// "Luke 15:5-7") so the preview shows all of them.
  final Future<void> Function(AnnotationVerseRange verses) onPreviewVerses;

  /// When provided, each chip shows a delete icon. Tapping it calls this
  /// callback — the caller decides whether to confirm before removing.
  final void Function(AnnotationVerseLink link)? onDeleteLink;
  final String title;

  /// Chips shown before the rest collapse behind "Show all".
  final int maxVisible;
  final String? emptyMessage;

  @override
  State<LinkedVersesSection> createState() => _LinkedVersesSectionState();
}

class _LinkedVersesSectionState extends State<LinkedVersesSection> {
  // "+N more" used to be a plain label, so verses past the limit could not be
  // seen, or removed in the editor. It is now a toggle.
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final ranges = widget.ranges;
    if (ranges.isEmpty) {
      if (widget.emptyMessage == null) return const SizedBox.shrink();
      return Text(widget.emptyMessage!);
    }

    final theme = Theme.of(context);
    final collapsible = ranges.length > widget.maxVisible;
    final visibleRanges = collapsible && !_expanded
        ? ranges.take(widget.maxVisible).toList(growable: false)
        : ranges;
    final hiddenCount = ranges.length - visibleRanges.length;
    final onDeleteLink = widget.onDeleteLink;

    String labelFor(AnnotationVerseRange range) =>
        range.label(displayBookNameForReference(widget.books, range.bookId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
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
              if (onDeleteLink != null)
                InputChip(
                  onPressed: () => widget.onPreviewVerses(range),
                  avatar: const Icon(Icons.visibility_outlined, size: 16),
                  label: Text(labelFor(range)),
                  onDeleted: () => onDeleteLink(range.first),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  deleteButtonTooltipMessage: AppLocalizations.of(context)!.removeAction,
                )
              else
                ActionChip(
                  onPressed: () => widget.onPreviewVerses(range),
                  avatar: const Icon(Icons.visibility_outlined, size: 16),
                  label: Text(labelFor(range)),
                ),
            if (collapsible)
              ActionChip(
                avatar: Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                ),
                label: Text(_expanded ? AppLocalizations.of(context)!.showLessAction : AppLocalizations.of(context)!.showAllAction(hiddenCount)),
                onPressed: () => setState(() => _expanded = !_expanded),
              ),
          ],
        ),
      ],
    );
  }
}
