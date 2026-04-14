part of 'bible_viewer_tab.dart';

extension _BibleTextViewStateAnnotations on _BibleTextViewState {
  void _showVerseDetailsSheet(
    BuildContext context,
    int chapterNumber,
    BibleVerse verse,
  ) {
    final footnotes = _displayFootnotes(verse);
    final references = _structuredReferences(verse);
    final annotationEntries = _annotationEntries(
      footnotes: footnotes,
      references: references,
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return _VerseDetailsSheet(
          referenceLabel:
              '${displayBookNameForReference(widget.books, widget.reference.bookId)} $chapterNumber:${verse.number}',
          verse: verse,
          annotationEntries: annotationEntries,
          onReferenceTap: (referenceEntry) =>
              _previewReferenceFromSheet(sheetContext, referenceEntry),
        );
      },
    );
  }

  Future<void> _previewReferenceFromSheet(
    BuildContext sheetContext,
    BibleCrossReference referenceEntry,
  ) async {
    final parsedReference = parseAnyReference(
      target: referenceEntry.target,
      label: referenceEntry.label,
    );

    await showModalBottomSheet<void>(
      context: sheetContext,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (previewContext) {
        return ReferencePreviewSheet(
          referenceLabel: referenceEntry.label,
          reference: parsedReference,
          preferredTranslationId: ref.read(currentTranslationProvider),
          preferredTranslationName:
              ref
                  .read(availableTranslationsProvider)
                  .asData
                  ?.value
                  .where(
                    (translation) =>
                        translation.id == ref.read(currentTranslationProvider),
                  )
                  .firstOrNull
                  ?.name ??
              'Current translation',
          books: widget.books,
          returnLabel: 'Back to Details',
          onOpenInBible: (previewSheetContext, preview) async {
            await ref
                .read(currentReferenceProvider.notifier)
                .setReference(preview.reference);
            if (previewSheetContext.mounted) {
              Navigator.of(previewSheetContext).pop();
            }
            if (sheetContext.mounted) {
              Navigator.of(sheetContext).pop();
            }
          },
        );
      },
    );
  }

  List<BibleFootnote> _displayFootnotes(BibleVerse verse) {
    if (verse.footnotes.isNotEmpty) {
      return verse.footnotes;
    }

    return (verse.notes ?? const [])
        .map((note) => BibleFootnote(text: note))
        .toList();
  }

  List<BibleCrossReference> _structuredReferences(BibleVerse verse) {
    if (verse.crossReferences.isNotEmpty) {
      return verse.crossReferences;
    }
    return (verse.references ?? const [])
        .map((reference) => BibleCrossReference(label: reference))
        .toList();
  }

  /// Returns true when the verse has parser-originated footnotes or
  /// cross-references. This is entirely separate from personal user annotations
  /// ([_annotationsForVerse]) and drives the source-content details sheet only.
  bool _hasParserNotes(BibleVerse verse) {
    final hasFootnotes =
        verse.footnotes.isNotEmpty ||
        (verse.notes != null && verse.notes!.isNotEmpty);
    final hasReferences =
        verse.crossReferences.isNotEmpty ||
        (verse.references != null && verse.references!.isNotEmpty);
    return hasFootnotes || hasReferences;
  }

  List<_VerseAnnotationEntry> _annotationEntries({
    required List<BibleFootnote> footnotes,
    required List<BibleCrossReference> references,
  }) {
    final entries = <_VerseAnnotationEntry>[];
    var markerIndex = 0;

    String nextMarker() {
      final value = String.fromCharCode('a'.codeUnitAt(0) + markerIndex);
      markerIndex++;
      return value;
    }

    // The current shared model stores notes and references in separate lists,
    // so this sheet uses a stable generated marker order instead of pretending
    // we still know the original exact source ordering for every format.
    for (final footnote in footnotes) {
      final labelIsRef =
          footnote.label != null && footnote.label!.trim().length > 1;
      entries.add(
        _VerseAnnotationEntry(
          marker: _annotationMarker(footnote, fallback: nextMarker()),
          body: _footnoteBody(footnote),
          originRef: labelIsRef ? footnote.label!.trim() : null,
          bodyText: footnote.bodyText,
          quotedText: footnote.quotedText,
          reference: footnote.references.isNotEmpty
              ? footnote.references.first
              : null,
          relatedReferences: footnote.references,
        ),
      );
    }

    for (final reference in references) {
      final refOrigin = reference.originRef?.trim().isNotEmpty == true
          ? reference.originRef!.trim()
          : null;
      entries.add(
        _VerseAnnotationEntry(
          marker: reference.marker?.trim().isNotEmpty == true
              ? reference.marker!.trim().toLowerCase()
              : nextMarker(),
          body: reference.label,
          originRef: refOrigin,
          bodyText: refOrigin != null ? reference.label : null,
          reference: reference,
        ),
      );
    }

    return entries;
  }

  String _annotationMarker(BibleFootnote footnote, {required String fallback}) {
    final candidates = [footnote.marker?.trim(), footnote.label?.trim()];

    for (final candidate in candidates) {
      if (candidate == null || candidate.isEmpty) continue;
      // Accept any single printable character — covers letters, digits, and
      // common footnote symbols such as * + † ‡ § that USFX uses as callers.
      if (candidate.length == 1) {
        return candidate;
      }
    }

    return fallback;
  }

  // Build the display body for a footnote annotation row.
  // The label field holds the origin-verse reference from <fr> (e.g. "Gen 1:1 — ").
  // Show it as a readable prefix when it is a real reference string rather than
  // a single-character marker, which would already be shown as the marker itself.
  String _footnoteBody(BibleFootnote footnote) {
    final label = footnote.label?.trim();
    final text = footnote.text.trim();
    if (label != null && label.isNotEmpty && label.length > 1) {
      return '$label $text'.trim();
    }
    return text;
  }

  List<InlineSpan> _buildVerseContentSpans(
    BuildContext context,
    BibleVerse verse, {
    Color? bodyColor,
    bool isSelectedVerse = false,
    Color? backgroundColor,
    bool applySelectionTint = true,
    TapGestureRecognizer? recognizer,
  }) {
    final spans = _displaySpans(verse);
    final effectiveBackgroundColor = applySelectionTint
        ? _selectionAwareBackground(
            context,
            isSelected: isSelectedVerse,
            baseBackground: backgroundColor,
          )
        : backgroundColor;
    if (spans.isEmpty) {
      return [
        TextSpan(
          text: verse.text,
          recognizer: recognizer,
          style: TextStyle(
            color: bodyColor,
            backgroundColor: effectiveBackgroundColor,
          ),
        ),
      ];
    }

    final baseColor = bodyColor ?? Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final boldDivineName = ref.watch(boldDivineNameProvider);
    final underlineProperNames = ref.watch(underlineProperNamesProvider);
    final underlineWordMetadata = ref.watch(underlineWordMetadataProvider);
    final bracketTranslatorAdditions = ref.watch(
      bracketTranslatorAdditionsProvider,
    );
    final useSourceBoldStyling = ref.watch(useSourceBoldStylingProvider);

    final inlineSpans = <InlineSpan>[];

    for (final span in spans) {
      inlineSpans.add(
        TextSpan(
          text: _spanText(
            span,
            bracketTranslatorAdditions: bracketTranslatorAdditions,
          ),
          recognizer: recognizer,
          style: TextStyle(
            color: _spanColor(span.kind, baseColor, secondaryColor),
            fontStyle: _spanFontStyle(span.kind),
            fontWeight: _spanFontWeight(
              span.kind,
              boldDivineName: boldDivineName,
              useSourceBoldStyling: useSourceBoldStyling,
            ),
            decoration: _spanDecoration(
              span.kind,
              underlineProperNames: underlineProperNames,
              underlineWordMetadata: underlineWordMetadata,
            ),
            backgroundColor: effectiveBackgroundColor,
          ),
        ),
      );
      inlineSpans.addAll(_buildInlineAnnotationMarkers(context, span));
    }

    return inlineSpans;
  }

  List<BibleVerseSpan> _displaySpans(BibleVerse verse) {
    if (verse.spans.isEmpty) return const [];

    final displaySpans = <BibleVerseSpan>[];
    var previousText = '';

    for (final span in verse.spans) {
      var text = span.text.trim();
      if (text.isEmpty) continue;

      final startsNewLine = span.metadata['lineStart'] == 'true';

      // Some source formats split every word into separate rich spans.
      // Reinsert display spacing here so tag-heavy sources like KJV do not
      // collapse into "wordstucktogether" when rendered span-by-span.
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

  String _spanText(
    BibleVerseSpan span, {
    bool bracketTranslatorAdditions = true,
  }) {
    if (span.metadata case {'quoteLevel': final levelText}) {
      final level = int.tryParse(levelText) ?? 0;
      if (level > 1) {
        return '${' ' * ((level - 1) * 2)}${span.text}';
      }
    }
    // Translator additions are words supplied by the translator that are not in
    // the original manuscripts. Wrapping them in brackets is the standard
    // convention used by most printed Bibles (e.g. KJV uses italics, ESV uses
    // brackets).
    if (bracketTranslatorAdditions &&
        span.kind == BibleVerseSpanKind.translatorAddition) {
      return '[${span.text}]';
    }
    return span.text;
  }

  List<InlineSpan> _buildInlineAnnotationMarkers(
    BuildContext context,
    BibleVerseSpan span,
  ) {
    final markers = <String>[
      ..._splitAnnotationMarkers(span.metadata['footnoteMarkers']),
      ..._splitAnnotationMarkers(span.metadata['referenceMarkers']),
    ];

    if (markers.isEmpty) return const [];

    final color = Theme.of(context).colorScheme.onSurfaceVariant;

    return [
      for (final marker in markers)
        WidgetSpan(
          alignment: PlaceholderAlignment.top,
          child: Padding(
            padding: const EdgeInsets.only(left: 1),
            child: Text(
              marker,
              style: TextStyle(
                fontSize: widget.fontSize * 0.58,
                height: 1,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ),
    ];
  }

  List<String> _splitAnnotationMarkers(String? rawValue) {
    if (rawValue == null || rawValue.isEmpty) return const [];
    return rawValue
        .split('|')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
  }

  Color? _spanColor(
    BibleVerseSpanKind kind,
    Color? baseColor,
    Color secondaryColor,
  ) {
    // Carry the dimming alpha from baseColor so verse-focus fading applies
    // uniformly to all span kinds, including red-letter and word spans.
    final alpha = baseColor?.a ?? 1.0;
    switch (kind) {
      case BibleVerseSpanKind.wordsOfJesus:
        return Colors.red.shade700.withValues(alpha: alpha);
      case BibleVerseSpanKind.word:
        return secondaryColor.withValues(alpha: alpha);
      default:
        return baseColor;
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
    bool useSourceBoldStyling = true,
  }) {
    switch (kind) {
      case BibleVerseSpanKind.wordsOfJesus:
        return FontWeight.w600;
      case BibleVerseSpanKind.divineNameTag:
        return boldDivineName ? FontWeight.w700 : FontWeight.normal;
      case BibleVerseSpanKind.acrosticHeading:
      case BibleVerseSpanKind.bold:
      case BibleVerseSpanKind.keyword:
        return useSourceBoldStyling ? FontWeight.w700 : FontWeight.normal;
      case BibleVerseSpanKind.word:
        return FontWeight.w500;
      default:
        return FontWeight.normal;
    }
  }

  TextDecoration? _spanDecoration(
    BibleVerseSpanKind kind, {
    bool underlineProperNames = true,
    bool underlineWordMetadata = false,
  }) {
    switch (kind) {
      case BibleVerseSpanKind.word:
        return underlineWordMetadata ? TextDecoration.underline : null;
      case BibleVerseSpanKind.properName:
        return underlineProperNames ? TextDecoration.underline : null;
      default:
        return null;
    }
  }
}
