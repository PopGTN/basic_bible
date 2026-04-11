part of 'bible_viewer_tab.dart';

class _VerseDetailsSheet extends ConsumerWidget {
  const _VerseDetailsSheet({
    required this.referenceLabel,
    required this.verse,
    required this.annotationEntries,
    required this.onReferenceTap,
  });

  final String referenceLabel;
  final BibleVerse verse;
  final List<_VerseAnnotationEntry> annotationEntries;
  final ValueChanged<BibleCrossReference> onReferenceTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final boldDivineName = ref.watch(boldDivineNameProvider);
    final underlineProperNames = ref.watch(underlineProperNamesProvider);
    final versePreview = _VersePreviewText(
      verse: verse,
      annotationEntries: annotationEntries,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      referenceLabel,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    child: Icon(
                      Icons.info_outline,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: theme.textTheme.headlineSmall?.copyWith(
                    height: 1.55,
                    fontSize: 18,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  children: versePreview.inlineSpans(
                    colors,
                    boldDivineName: boldDivineName,
                    underlineProperNames: underlineProperNames,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Divider(color: colors.outlineVariant.withValues(alpha: 0.35)),
              for (final entry in annotationEntries)
                _VerseAnnotationRow(
                  entry: entry,
                  onReferenceTap: onReferenceTap,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

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
  });

  final int verseNumber;
  final Color color;
  final bool isSelected;
  final bool hasNote;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            Text(
              '$verseNumber',
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
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

class _VerseAnnotationEntry {
  const _VerseAnnotationEntry({
    required this.marker,
    required this.body,
    this.originRef,
    this.bodyText,
    this.quotedText,
    this.reference,
    this.relatedReferences = const [],
  });

  final String marker;
  final String body;
  final String? originRef;
  final String? bodyText;
  final String? quotedText;
  final BibleCrossReference? reference;
  final List<BibleCrossReference> relatedReferences;
}

class _VersePreviewText {
  const _VersePreviewText({
    required this.verse,
    required this.annotationEntries,
  });

  final BibleVerse verse;
  final List<_VerseAnnotationEntry> annotationEntries;

  List<InlineSpan> inlineSpans(
    ColorScheme colors, {
    bool boldDivineName = false,
    bool underlineProperNames = true,
  }) {
    final spans = _displaySpans();
    if (spans.isEmpty) {
      return _fallbackInlineSpans(colors);
    }

    final inlineSpans = <InlineSpan>[];
    var renderedInlineMarkers = false;

    for (final span in spans) {
      inlineSpans.add(
        TextSpan(
          text: _spanText(span),
          style: TextStyle(
            color: _spanColor(span.kind, colors),
            fontStyle: _spanFontStyle(span.kind),
            fontWeight: _spanFontWeight(
              span.kind,
              boldDivineName: boldDivineName,
            ),
            decoration: _spanDecoration(
              span.kind,
              underlineProperNames: underlineProperNames,
            ),
          ),
        ),
      );
      final markers = _buildInlineAnnotationMarkers(colors, span);
      if (markers.isNotEmpty) {
        renderedInlineMarkers = true;
        inlineSpans.addAll(markers);
      }
    }

    if (!renderedInlineMarkers && annotationEntries.isNotEmpty) {
      inlineSpans.addAll(_fallbackMarkerSpans(colors));
    }

    return inlineSpans;
  }

  List<InlineSpan> _fallbackInlineSpans(ColorScheme colors) {
    final spans = <InlineSpan>[TextSpan(text: verse.text)];
    if (annotationEntries.isNotEmpty) {
      spans.addAll(_fallbackMarkerSpans(colors));
    }
    return spans;
  }

  List<InlineSpan> _fallbackMarkerSpans(ColorScheme colors) {
    return [
      const TextSpan(text: ' '),
      for (final entry in annotationEntries) ...[
        _markerSpan(colors, entry.marker),
        const TextSpan(text: ' '),
      ],
    ];
  }

  List<BibleVerseSpan> _displaySpans() {
    if (verse.spans.isEmpty) return const [];

    final displaySpans = <BibleVerseSpan>[];
    var previousText = '';

    for (final span in verse.spans) {
      var text = span.text.trim();
      if (text.isEmpty) continue;

      final startsNewLine = span.metadata['lineStart'] == 'true';

      if (startsNewLine) {
        text = '\n$text';
      } else if (_shouldInsertSpace(previousText, text)) {
        text = ' $text';
      }

      displaySpans.add(
        BibleVerseSpan(text: text, kind: span.kind, metadata: span.metadata),
      );
      previousText = startsNewLine ? text.trimLeft() : text;
    }

    return displaySpans;
  }

  bool _shouldInsertSpace(String previousText, String currentText) {
    if (previousText.isEmpty) return false;
    if (currentText.startsWith(RegExp(r"[.,;:!?)}\]”’]"))) return false;
    if (RegExp(r"[(\[{“‘/]$").hasMatch(previousText)) return false;
    return true;
  }

  String _spanText(BibleVerseSpan span) {
    if (span.metadata case {'quoteLevel': final levelText}) {
      final level = int.tryParse(levelText) ?? 0;
      if (level > 1) {
        return '${' ' * ((level - 1) * 2)}${span.text}';
      }
    }
    return span.text;
  }

  List<InlineSpan> _buildInlineAnnotationMarkers(
    ColorScheme colors,
    BibleVerseSpan span,
  ) {
    final markers = <String>[
      ..._splitAnnotationMarkers(span.metadata['footnoteMarkers']),
      ..._splitAnnotationMarkers(span.metadata['referenceMarkers']),
    ];

    if (markers.isEmpty) return const [];

    return [for (final marker in markers) _markerSpan(colors, marker)];
  }

  InlineSpan _markerSpan(ColorScheme colors, String marker) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.aboveBaseline,
      baseline: TextBaseline.alphabetic,
      child: Padding(
        padding: const EdgeInsets.only(left: 1),
        child: Text(
          marker,
          style: TextStyle(
            fontSize: 13,
            height: 1,
            fontWeight: FontWeight.w700,
            color: colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  List<String> _splitAnnotationMarkers(String? rawValue) {
    if (rawValue == null || rawValue.isEmpty) return const [];
    return rawValue
        .split('|')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
  }

  Color? _spanColor(BibleVerseSpanKind kind, ColorScheme colors) {
    switch (kind) {
      case BibleVerseSpanKind.wordsOfJesus:
        return Colors.red.shade700;
      case BibleVerseSpanKind.word:
        return colors.secondary;
      default:
        return colors.onSurface;
    }
  }

  FontStyle _spanFontStyle(BibleVerseSpanKind kind) {
    switch (kind) {
      case BibleVerseSpanKind.translatorAddition:
      case BibleVerseSpanKind.quote:
      case BibleVerseSpanKind.poetry:
      case BibleVerseSpanKind.selah:
      case BibleVerseSpanKind.emphasis:
      case BibleVerseSpanKind.italic:
      case BibleVerseSpanKind.foreignLanguage:
        return FontStyle.italic;
      default:
        return FontStyle.normal;
    }
  }

  FontWeight _spanFontWeight(
    BibleVerseSpanKind kind, {
    bool boldDivineName = false,
  }) {
    switch (kind) {
      case BibleVerseSpanKind.wordsOfJesus:
        return FontWeight.w600;
      case BibleVerseSpanKind.divineNameTag:
        return boldDivineName ? FontWeight.w700 : FontWeight.normal;
      case BibleVerseSpanKind.acrosticHeading:
      case BibleVerseSpanKind.bold:
      case BibleVerseSpanKind.keyword:
        return FontWeight.w700;
      case BibleVerseSpanKind.word:
        return FontWeight.w500;
      default:
        return FontWeight.normal;
    }
  }

  TextDecoration? _spanDecoration(
    BibleVerseSpanKind kind, {
    bool underlineProperNames = true,
  }) {
    switch (kind) {
      case BibleVerseSpanKind.word:
      case BibleVerseSpanKind.properName:
        return underlineProperNames ? TextDecoration.underline : null;
      default:
        return null;
    }
  }
}

class _VerseAnnotationRow extends StatelessWidget {
  const _VerseAnnotationRow({required this.entry, this.onReferenceTap});

  final _VerseAnnotationEntry entry;
  final ValueChanged<BibleCrossReference>? onReferenceTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.25),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 26,
            child: Text(
              entry.marker,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                entry.bodyText != null
                    ? RichText(
                        text: TextSpan(
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                            color: colors.onSurface,
                          ),
                          children: [
                            if (entry.originRef != null)
                              TextSpan(
                                text: '${entry.originRef} ',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            TextSpan(text: entry.bodyText),
                            if (entry.quotedText != null)
                              TextSpan(
                                text: ' \u201c${entry.quotedText}\u201d',
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      )
                    : Text(
                        entry.body,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),
                if (entry.relatedReferences.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final reference in entry.relatedReferences)
                        ActionChip(
                          avatar: const Icon(Icons.link, size: 16),
                          label: Text(reference.label),
                          onPressed: onReferenceTap == null
                              ? null
                              : () => onReferenceTap!(reference),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (entry.reference != null && onReferenceTap != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => onReferenceTap!(entry.reference!),
              icon: const Icon(Icons.chevron_right),
              color: colors.onSurfaceVariant,
            ),
          ],
        ],
      ),
    );
  }
}

class _PersonalNotesSheet extends StatelessWidget {
  const _PersonalNotesSheet({
    required this.referenceLabel,
    required this.verseText,
    required this.books,
    required this.annotations,
    required this.onOpenReference,
    required this.onEdit,
  });

  final String referenceLabel;
  final String verseText;
  final List<BibleBook> books;
  final List<UserAnnotation> annotations;
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
    required this.onOpenReference,
    required this.onEdit,
  });

  final UserAnnotation annotation;
  final List<BibleBook> books;
  final VoidCallback onOpenReference;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final highlightColor = annotation.highlightColorValue == null
        ? null
        : annotationColorFromValue(
            annotation.highlightColorValue,
            theme.colorScheme.secondary,
          );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  annotation.primaryVerse.translationName,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (highlightColor != null)
                Container(
                  width: 14,
                  height: 14,
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
                  Chip(
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
