import 'package:basic_bible/src/features/library/data/app_bible_repository.dart';
import 'package:basic_bible/src/features/reader/application/view_models/bible_library_view_models.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/utils/reference_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResolvedReferencePreview {
  const ResolvedReferencePreview({
    required this.reference,
    required this.translationId,
    required this.translationName,
    required this.verses,
    this.range,
  });

  /// Where "Open in Bible" navigates: the first verse of the passage.
  final BibleReference reference;
  final String translationId;
  final String translationName;

  /// Every verse shown, in order. One entry for a single-verse preview.
  final List<({int chapter, BibleVerse verse})> verses;
  final BibleReferenceRange? range;

  bool get isPassage => verses.length > 1;
}

class ReferencePreviewSheet extends ConsumerStatefulWidget {
  const ReferencePreviewSheet({
    super.key,
    required this.referenceLabel,
    required this.reference,
    required this.preferredTranslationId,
    required this.preferredTranslationName,
    required this.books,
    required this.returnLabel,
    required this.onOpenInBible,
    this.fallbackTranslationId,
    this.fallbackTranslationName,
    this.range,
  });

  final String referenceLabel;

  /// Single verse to preview. Ignored when [range] is given.
  final BibleReference? reference;

  /// Passage to preview (several verses, possibly across chapters, or a whole
  /// chapter). Takes precedence over [reference].
  final BibleReferenceRange? range;
  final String preferredTranslationId;
  final String preferredTranslationName;
  final String? fallbackTranslationId;
  final String? fallbackTranslationName;
  final List<BibleBook> books;
  final String returnLabel;
  final Future<void> Function(
    BuildContext context,
    ResolvedReferencePreview preview,
  )
  onOpenInBible;

  @override
  ConsumerState<ReferencePreviewSheet> createState() =>
      _ReferencePreviewSheetState();
}

class _ReferencePreviewSheetState extends ConsumerState<ReferencePreviewSheet> {
  late final Future<ResolvedReferencePreview?> _previewFuture;

  @override
  void initState() {
    super.initState();
    _previewFuture = _loadPreview();
  }

  /// Upper bound on verses shown for one passage, so a whole-chapter or
  /// multi-chapter reference can't build an unbounded sheet.
  static const _maxPreviewVerses = 60;

  Future<ResolvedReferencePreview?> _loadPreview() async {
    final range =
        widget.range ??
        (widget.reference?.verse == null
            ? null
            : BibleReferenceRange.single(widget.reference!));
    if (range == null) return null;

    final repository = ref.read(bibleRepositoryProvider);
    final attempts = <({String id, String name})>[
      (
        id: widget.preferredTranslationId,
        name: widget.preferredTranslationName,
      ),
      if (widget.fallbackTranslationId != null &&
          widget.fallbackTranslationName != null &&
          widget.fallbackTranslationId != widget.preferredTranslationId)
        (
          id: widget.fallbackTranslationId!,
          name: widget.fallbackTranslationName!,
        ),
    ];

    for (final attempt in attempts) {
      try {
        await repository.loadLocalBibleShell(attempt.id);
        final verses = <({int chapter, BibleVerse verse})>[];
        for (
          var chapterNumber = range.start.chapter;
          chapterNumber <= range.endChapter &&
              verses.length < _maxPreviewVerses;
          chapterNumber++
        ) {
          final chapter = await repository.loadChapterVerses(
            attempt.id,
            range.bookId,
            chapterNumber,
          );
          if (chapter == null) continue;
          for (final verse in chapter.verses) {
            if (!range.contains(chapterNumber, verse.number)) continue;
            verses.add((chapter: chapterNumber, verse: verse));
            if (verses.length >= _maxPreviewVerses) break;
          }
        }
        if (verses.isEmpty) continue;

        final first = verses.first;
        return ResolvedReferencePreview(
          reference: BibleReference(
            bookId: range.bookId,
            chapter: first.chapter,
            verse: first.verse.number,
          ),
          translationId: attempt.id,
          translationName: attempt.name,
          verses: verses,
          range: range.isSingleVerse ? null : range,
        );
      } catch (_) {
        continue;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.46,
        minChildSize: 0.2,
        maxChildSize: 0.92,
        snap: true,
        snapSizes: const [0.46, 0.92],
        shouldCloseOnMinExtent: true,
        builder: (context, controller) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: ListView(
              controller: controller,
              children: [
                Text(
                  widget.referenceLabel,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                FutureBuilder<ResolvedReferencePreview?>(
                  future: _previewFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    }

                    final preview = snapshot.data;
                    if (preview == null) {
                      return Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: colors.outlineVariant),
                        ),
                        child: Text(
                          'Preview unavailable for this reference.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      );
                    }

                    final bookName = displayBookNameForReference(
                      widget.books,
                      preview.reference.bookId,
                    );
                    final displayLabel =
                        preview.range?.label(bookName) ??
                        '$bookName ${preview.reference.chapter}:'
                            '${preview.reference.verse}';

                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: colors.outlineVariant.withValues(alpha: 0.45),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayLabel,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            preview.translationName,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _PassageText(
                            preview: preview,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              height: 1.55,
                            ),
                            numberStyle: theme.textTheme.labelSmall?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),
                FutureBuilder<ResolvedReferencePreview?>(
                  future: _previewFuture,
                  builder: (context, snapshot) {
                    final preview = snapshot.data;
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_outlined),
                          label: Text(widget.returnLabel),
                        ),
                        FilledButton.icon(
                          onPressed: preview == null
                              ? null
                              : () => widget.onOpenInBible(context, preview),
                          icon: const Icon(Icons.menu_book_outlined),
                          label: const Text('Open in Bible'),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Verse text for a preview. A single verse renders as plain text; a passage
/// prefixes each verse with its number (and `chapter:verse` when the passage
/// crosses a chapter boundary) so the reader can tell where verses start.
class _PassageText extends StatelessWidget {
  const _PassageText({
    required this.preview,
    required this.style,
    required this.numberStyle,
  });

  final ResolvedReferencePreview preview;
  final TextStyle? style;
  final TextStyle? numberStyle;

  @override
  Widget build(BuildContext context) {
    if (!preview.isPassage) {
      return Text(preview.verses.single.verse.text, style: style);
    }

    final crossesChapters =
        preview.verses.first.chapter != preview.verses.last.chapter;
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          for (final (index, entry) in preview.verses.indexed) ...[
            TextSpan(
              text:
                  '${index == 0 ? '' : ' '}'
                  '${crossesChapters ? '${entry.chapter}:' : ''}'
                  '${entry.verse.number}\u00a0',
              style: numberStyle,
            ),
            TextSpan(text: entry.verse.text),
          ],
        ],
      ),
    );
  }
}
