import 'package:basic_bible/src/features/reader/application/view_models/bible_library_view_models.dart';
import 'package:basic_bible/src/features/reader/application/view_models/split_view_view_models.dart';
import 'package:basic_bible/src/features/reader/presentation/reference_picker/chapter_bar.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/services/font_size_service.dart';
import 'package:basic_bible/src/utils/reference_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The second reading pane of split view (#84). Independent of the main
/// reader: its own translation, chapter and scroll position, with the same
/// chapter bar (previous/next + book picker). Reading only — selecting,
/// highlighting and notes stay in the main pane.
class SecondaryReaderPane extends ConsumerStatefulWidget {
  const SecondaryReaderPane({super.key});

  @override
  ConsumerState<SecondaryReaderPane> createState() =>
      _SecondaryReaderPaneState();
}

class _SecondaryReaderPaneState extends ConsumerState<SecondaryReaderPane> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _resetScroll() {
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final pane = ref.watch(secondaryPaneProvider);
    final books =
        ref.watch(secondaryPaneBooksProvider).asData?.value ??
        const <BibleBook>[];
    final content = ref.watch(secondaryPaneContentProvider);
    final notifier = ref.read(secondaryPaneProvider.notifier);

    // A new chapter starts at the top, like the main reader.
    ref.listen(secondaryPaneProvider, (previous, next) {
      if (previous?.reference != next.reference ||
          previous?.translationId != next.translationId) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _resetScroll());
      }
    });

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          _PaneHeader(translationId: pane.translationId),
          Expanded(
            child: content.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Could not load this translation: $error'),
                ),
              ),
              data: (content) => content == null
                  ? const Center(child: Text('Chapter not found'))
                  : ValueListenableBuilder<double>(
                      // Follow the reader's text size setting live.
                      valueListenable: FontSizeService.instance.notifier,
                      builder: (context, fontSize, _) => _PaneText(
                        content: content,
                        controller: _scrollController,
                        fontSize: fontSize,
                      ),
                    ),
            ),
          ),
          SafeArea(
            top: false,
            child: ChapterBar(
              barHeight: 56,
              isFloating: true,
              reference: pane.reference,
              books: books,
              canOpenReferencePicker: books.isNotEmpty,
              showVerseSelector: false,
              onReferenceChanged: notifier.setReference,
              onPreviousChapter: () => notifier.step(books, -1),
              onNextChapter: () => notifier.step(books, 1),
            ),
          ),
        ],
      ),
    );
  }
}

/// Translation chooser for the pane.
class _PaneHeader extends ConsumerWidget {
  const _PaneHeader({required this.translationId});

  final String translationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translations =
        ref
            .watch(availableTranslationsProvider)
            .asData
            ?.value
            .where((t) => t.isReadableNow)
            .toList() ??
        const <BibleTranslation>[];
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Align(
        alignment: Alignment.centerRight,
        child: MenuAnchor(
          builder: (context, controller, _) => ActionChip(
            avatar: const Icon(Icons.language, size: 18),
            label: Text(translationId.toUpperCase()),
            tooltip: 'Translation for this pane',
            onPressed: () =>
                controller.isOpen ? controller.close() : controller.open(),
          ),
          menuChildren: [
            for (final t in translations)
              MenuItemButton(
                leadingIcon: Icon(
                  t.id == translationId
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                ),
                onPressed: () => ref
                    .read(secondaryPaneProvider.notifier)
                    .setTranslation(t.id),
                child: Text('${t.id.toUpperCase()} · ${t.name}'),
              ),
          ],
        ),
      ),
    );
  }
}

class _PaneText extends StatelessWidget {
  const _PaneText({
    required this.content,
    required this.controller,
    required this.fontSize,
  });

  final SecondaryPaneContent content;
  final ScrollController controller;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final bodyStyle = theme.textTheme.bodyLarge?.copyWith(
      fontSize: fontSize,
      height: 1.55,
    );
    final chapter = content.chapter;
    final frontMatter = isFrontMatterChapter(chapter.number);
    final introBlocks = frontMatter
        ? content.book.introductionBlocks
              .where((b) => b.text.trim().isNotEmpty)
              .toList()
        : const <BibleDocumentBlock>[];

    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        Center(
          child: Text(
            chapterReferenceLabel(
              preferredBookName(content.book),
              chapter.number,
            ),
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.secondary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final block in introBlocks)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(block.text.trim(), style: bodyStyle),
          ),
        for (final verse in chapter.verses)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text.rich(
              TextSpan(
                style: bodyStyle,
                children: [
                  TextSpan(
                    text: '${verse.number} ',
                    style: TextStyle(
                      fontSize: fontSize * 0.7,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  ..._verseSpans(verse, colors),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// Red letters and translator additions, like the main reader; plain text
  /// when the source has no rich spans.
  List<InlineSpan> _verseSpans(BibleVerse verse, ColorScheme colors) {
    if (verse.spans.isEmpty) return [TextSpan(text: verse.text)];
    final spans = <InlineSpan>[];
    var previous = '';
    for (final span in verse.spans) {
      var text = span.text.trim();
      if (text.isEmpty) continue;
      if (previous.isNotEmpty &&
          !RegExp(r"^[.,;:!?)}\]”’]").hasMatch(text) &&
          !RegExp(r"[(\[{“‘/]$").hasMatch(previous)) {
        text = ' $text';
      }
      previous = text;
      spans.add(
        TextSpan(
          text: text,
          style: switch (span.kind) {
            BibleVerseSpanKind.wordsOfJesus => TextStyle(
              color: Colors.red.shade700,
            ),
            BibleVerseSpanKind.translatorAddition => const TextStyle(
              fontStyle: FontStyle.italic,
            ),
            _ => null,
          },
        ),
      );
    }
    return spans;
  }
}
