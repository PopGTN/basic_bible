part of 'bible_viewer_tab.dart';

/// Rich verse-details content shown from the parser footnote/reference sheet.
///
/// This file intentionally groups the data shape, preview rendering, and row
/// rendering together because those pieces evolve in lockstep.
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
    final underlineWordMetadata = ref.watch(underlineWordMetadataProvider);
    final bracketTranslatorAdditions = ref.watch(
      bracketTranslatorAdditionsProvider,
    );
    final useSourceBoldStyling = ref.watch(useSourceBoldStylingProvider);
    final showSourceDetails = ref.watch(showSourceDetailsProvider);
    final versePreview = _VersePreviewText(
      verse: verse,
      annotationEntries: annotationEntries,
    );
    final metadataSummary = _VerseMetadataSummary.fromVerse(verse);

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
                    bracketTranslatorAdditions: bracketTranslatorAdditions,
                    underlineProperNames: underlineProperNames,
                    underlineWordMetadata: underlineWordMetadata,
                    useSourceBoldStyling: useSourceBoldStyling,
                  ),
                ),
              ),
              if (showSourceDetails && metadataSummary.hasContent) ...[
                const SizedBox(height: 14),
                _VerseMetadataSection(summary: metadataSummary),
              ],
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

class _VerseMetadataSummary {
  const _VerseMetadataSummary({
    this.quoteSpeakers = const [],
    this.strongs = const [],
    this.lemmas = const [],
    this.morphologies = const [],
  });

  final List<String> quoteSpeakers;
  final List<String> strongs;
  final List<String> lemmas;
  final List<String> morphologies;

  bool get hasContent =>
      quoteSpeakers.isNotEmpty ||
      strongs.isNotEmpty ||
      lemmas.isNotEmpty ||
      morphologies.isNotEmpty;

  factory _VerseMetadataSummary.fromVerse(BibleVerse verse) {
    final quoteSpeakers = <String>{};
    final strongs = <String>{};
    final lemmas = <String>{};
    final morphologies = <String>{};

    for (final span in verse.spans) {
      final metadata = span.metadata;
      final quoteWho = metadata['quoteWho']?.trim();
      final strong = metadata['strongs']?.trim();
      final lemma = metadata['lemma']?.trim();
      final morph = metadata['morph']?.trim();

      if (quoteWho != null && quoteWho.isNotEmpty) quoteSpeakers.add(quoteWho);
      if (strong != null && strong.isNotEmpty) strongs.add(strong);
      if (lemma != null && lemma.isNotEmpty) lemmas.add(lemma);
      if (morph != null && morph.isNotEmpty) morphologies.add(morph);
    }

    List<String> sorted(Iterable<String> values) => values.toList()..sort();

    return _VerseMetadataSummary(
      quoteSpeakers: sorted(quoteSpeakers),
      strongs: sorted(strongs),
      lemmas: sorted(lemmas),
      morphologies: sorted(morphologies),
    );
  }
}

class _VerseMetadataSection extends StatelessWidget {
  const _VerseMetadataSection({required this.summary});

  final _VerseMetadataSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Source details',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          if (summary.quoteSpeakers.isNotEmpty)
            _VerseMetadataGroup(
              label: 'Quote speaker',
              values: summary.quoteSpeakers,
              icon: Icons.record_voice_over_outlined,
            ),
          if (summary.strongs.isNotEmpty)
            _VerseMetadataGroup(
              label: "Strong's",
              values: summary.strongs,
              icon: Icons.tag_outlined,
            ),
          if (summary.lemmas.isNotEmpty)
            _VerseMetadataGroup(
              label: 'Lemma',
              values: summary.lemmas,
              icon: Icons.translate_outlined,
            ),
          if (summary.morphologies.isNotEmpty)
            _VerseMetadataGroup(
              label: 'Morphology',
              values: summary.morphologies,
              icon: Icons.account_tree_outlined,
            ),
        ],
      ),
    );
  }
}

class _VerseMetadataGroup extends StatelessWidget {
  const _VerseMetadataGroup({
    required this.label,
    required this.values,
    required this.icon,
  });

  final String label;
  final List<String> values;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: colors.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final value in values)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withValues(
                      alpha: 0.7,
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    value,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
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
    bool bracketTranslatorAdditions = true,
    bool underlineProperNames = true,
    bool underlineWordMetadata = false,
    bool useSourceBoldStyling = true,
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
          text: _spanText(
            span,
            bracketTranslatorAdditions: bracketTranslatorAdditions,
          ),
          style: TextStyle(
            color: _spanColor(span.kind, colors),
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
    if (bracketTranslatorAdditions &&
        span.kind == BibleVerseSpanKind.translatorAddition) {
      return '[${span.text}]';
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
