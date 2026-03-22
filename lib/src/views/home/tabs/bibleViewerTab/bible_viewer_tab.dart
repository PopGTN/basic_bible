import 'reference_screen.dart';
import 'package:basic_bible/src/utils/reference_utils.dart';
import 'package:basic_bible/src/views/home/tabs/bibleViewerTab/widgets/reference_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:basic_bible/src/services/font_size_service.dart';

import '../../../../models/bible_models.dart';
import '../../../../providers/bible_provider.dart';
import '../../../../providers/current_chapter_provider.dart';

class BibleViewerTab extends ConsumerStatefulWidget {
  final VoidCallback showBottomNav;
  final VoidCallback hideBottomNav;
  final VoidCallback showAppBar;
  final VoidCallback hideAppBar;
  final bool isSmallDevice;

  const BibleViewerTab({
    super.key,
    required this.showBottomNav,
    required this.hideBottomNav,
    required this.showAppBar,
    required this.hideAppBar,
    required this.isSmallDevice,
  });

  @override
  ConsumerState<BibleViewerTab> createState() => _BibleViewerTabState();
}

class _BibleViewerTabState extends ConsumerState<BibleViewerTab> {
  final ScrollController _scrollController = ScrollController();
  // Removed local constants; layout spacing is handled by widgets directly.
  //TODO: Make The Text Size Changeable through Settings
  // Font size is now provided by FontSizeService; listen to changes in build

  double? _lastScroll;
  bool _isHiding = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    final current = _scrollController.position.pixels;
    final max = _scrollController.position.maxScrollExtent;
    final delta = current - (_lastScroll ?? current);
    _lastScroll = current;

    if (delta.abs() < 1) return;

    // Always show bars when at the bottom
    if (current >= max) {
      if (_isHiding) _toggleBars(show: true);
      return;
    }

    if (delta > 0 && !_isHiding) {
      _toggleBars(show: false); // scrolling down → hide
    } else if (delta < 0 && _isHiding) {
      _toggleBars(show: true); // scrolling up → show
    }
  }

  void _toggleBars({required bool show}) {
    if (show) {
      widget.showBottomNav();
      if (widget.isSmallDevice) widget.showAppBar();
    } else {
      widget.hideBottomNav();
      if (widget.isSmallDevice) widget.hideAppBar();
    }
    _isHiding = !show;
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Example: if you want to read a provider in here:
    // final someValue = ref.watch(someProvider);
    final booksAsync = ref.watch(bibleBooksProvider);
    final currentReference = ref.watch(currentReferenceProvider);
    final chapterAsync = ref.watch(currentChapterProvider);
    final layoutMode = ref.watch(readerLayoutModeProvider);
    final isSmall = widget.isSmallDevice;

    return Stack(
      children: [
        /*        ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.fromLTRB(
            16,
            isSmall ? 16 : _chapterBarHeight + 16,
            16,
            bottomPadding,
          ),
          itemCount: 100,
          itemBuilder: (_, i) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "Verse line ${i + 1} — sample Bible text.",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),*/
        // Bible content is provided below and listens to global font-size

        // Chapter navigation bar
        Align(
          alignment: isSmall ? Alignment.bottomCenter : Alignment.topCenter,
          child: SafeArea(
            top: !isSmall,
            bottom: isSmall,
            child: ChapterBar(
              barHeight: 56,
              reference: currentReference,
              books: booksAsync.value ?? const [],
              onReferenceChanged: (reference) {
                ref
                    .read(currentReferenceProvider.notifier)
                    .setReference(reference);
              },
              onPreviousChapter: () {
                if (booksAsync.value != null) {
                  ref
                      .read(currentReferenceProvider.notifier)
                      .goToPreviousChapter(booksAsync.value!);
                }
              },
              onNextChapter: () {
                if (booksAsync.value != null) {
                  ref
                      .read(currentReferenceProvider.notifier)
                      .goToNextChapter(booksAsync.value!);
                }
              },
            ),
          ),
        ),

        // Bible content and font-size are driven by the shared FontSizeService.
        // Wrap the content in a ValueListenableBuilder so updates to the
        // global font size (from HomeScreen AppBar) rebuild the viewer.
        ValueListenableBuilder<double>(
          valueListenable: FontSizeService.instance.notifier,
          builder: (context, size, child) {
            return booksAsync.when(
              data: (books) => chapterAsync.when(
                data: (chapter) => chapter != null
                    ? _BibleTextView(
                        controller: _scrollController,
                        book: books.firstWhere(
                          (book) => book.id == currentReference.bookId,
                        ),
                        chapter: chapter,
                        reference: currentReference,
                        fontSize: size,
                        layoutMode: layoutMode,
                        isSmallDevice: isSmall,
                      )
                    : const _ErrorView(message: 'Chapter not found'),
                loading: () => const _LoadingView(),
                error: (error, stack) => _ErrorView(message: 'Error: $error'),
              ),
              loading: () => const _LoadingView(),
              error: (error, stack) =>
                  _ErrorView(message: 'Failed to load Bible: $error'),
            );
          },
        ),

        // Translation selector removed — translations are selected from HomeScreen
      ],
    );
  }
}

/// Bible text display widget
class _BibleTextView extends StatefulWidget {
  const _BibleTextView({
    required this.controller,
    required this.book,
    required this.chapter,
    required this.reference,
    required this.fontSize,
    required this.layoutMode,
    required this.isSmallDevice,
  });

  final ScrollController controller;
  final BibleBook book;
  final BibleChapter chapter;
  final BibleReference reference;
  final double fontSize;
  final ReaderLayoutMode layoutMode;
  final bool isSmallDevice;

  @override
  State<_BibleTextView> createState() => _BibleTextViewState();
}

class _BibleTextViewState extends State<_BibleTextView> {
  final Map<int, GlobalKey> _verseKeys = <int, GlobalKey>{};

  @override
  void initState() {
    super.initState();
    _scheduleVerseFocus();
  }

  @override
  void didUpdateWidget(covariant _BibleTextView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reference != widget.reference ||
        oldWidget.chapter != widget.chapter) {
      _scheduleVerseFocus();
    }
  }

  void _scheduleVerseFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final verseNumber = widget.reference.verse;
      if (verseNumber == null) return;
      final targetContext = _verseKeys[verseNumber]?.currentContext;
      if (targetContext != null) {
        Scrollable.ensureVisible(
          targetContext,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          alignment: 0.18,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final contentWidgets = <Widget>[
      _buildChapterHeader(context),
      ..._buildBookIntroductionBlocks(context),
      ..._buildChapterBlocks(context),
      if (widget.layoutMode == ReaderLayoutMode.verseList)
        ...widget.chapter.verses.map((verse) => _buildVerse(context, verse))
      else
        _buildParagraphReadingView(context),
    ];

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: widget.isSmallDevice
            ? 16
            : 80, // keep larger top space on tablet/desktop
        bottom: 72, // Space for chapter bar
      ),
      child: ListView.builder(
        controller: widget.controller,
        itemCount: contentWidgets.length,
        itemBuilder: (context, index) => contentWidgets[index],
      ),
    );
  }

  Widget _buildChapterHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        children: [
          Text(
            widget.book.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
              letterSpacing: 0.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '${bookIdToName(widget.reference.bookId)} ${widget.reference.chapter}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: widget.fontSize + 4,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBookIntroductionBlocks(BuildContext context) {
    if (widget.reference.chapter != 1 ||
        widget.book.introductionBlocks.isEmpty) {
      return const [];
    }

    // Book introductions are only shown at the start of the book to avoid
    // repeating long front-matter blocks on every chapter view.
    return [
      for (final block in widget.book.introductionBlocks)
        _DocumentBlockView(
          block: block,
          fontSize: widget.fontSize,
          isEmphasized: true,
        ),
    ];
  }

  List<Widget> _buildChapterBlocks(BuildContext context) {
    final visibleBlocks = widget.chapter.blocks
        .where((block) => block.kind != BibleDocumentBlockKind.paragraph)
        .toList();
    if (visibleBlocks.isEmpty) return const [];

    return [
      for (final block in visibleBlocks)
        _DocumentBlockView(block: block, fontSize: widget.fontSize),
    ];
  }

  Widget _buildVerse(BuildContext context, BibleVerse verse) {
    final verseKey = _verseKeys.putIfAbsent(verse.number, GlobalKey.new);
    final hasFootnotes =
        verse.footnotes.isNotEmpty ||
        (verse.notes != null && verse.notes!.isNotEmpty);
    final hasReferences =
        verse.crossReferences.isNotEmpty ||
        (verse.references != null && verse.references!.isNotEmpty);

    return Padding(
      key: verseKey,
      padding: const EdgeInsets.only(bottom: 8.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: widget.reference.verse == verse.number
              ? Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.35)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: GestureDetector(
          onTap: () {
            if (hasFootnotes || hasReferences) {
              _showVerseDetailsSheet(context, verse);
            }
          },
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: widget.fontSize,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                height: 1.5,
              ),
              children: [
                TextSpan(
                  text: '${verse.number} ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: widget.fontSize - 2,
                  ),
                ),
                ..._buildVerseContentSpans(context, verse),
                if (hasFootnotes)
                  WidgetSpan(
                    child: Icon(
                      Icons.info_outline,
                      size: widget.fontSize,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                if (hasReferences)
                  WidgetSpan(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Icon(
                        Icons.link,
                        size: widget.fontSize,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParagraphReadingView(BuildContext context) {
    final sections = _buildParagraphSections();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final section in sections)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final block in section.leadingBlocks)
                    if (block.text.trim().isNotEmpty)
                      _DocumentBlockView(
                        block: block,
                        fontSize: widget.fontSize,
                      ),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: widget.fontSize,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        height: 1.7,
                      ),
                      children: [
                        for (final verse in section.verses) ...[
                          WidgetSpan(
                            child: SizedBox(
                              key: _verseKeys.putIfAbsent(
                                verse.number,
                                GlobalKey.new,
                              ),
                              width: 0,
                              height: 0,
                            ),
                          ),
                          TextSpan(
                            text: '${verse.number} ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: widget.fontSize - 2,
                              backgroundColor:
                                  widget.reference.verse == verse.number
                                  ? Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                        .withValues(alpha: 0.45)
                                  : null,
                            ),
                          ),
                          ..._buildVerseContentSpans(context, verse),
                          const TextSpan(text: ' '),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<_ParagraphSection> _buildParagraphSections() {
    if (widget.chapter.verses.isEmpty) return const [];

    final paragraphBlocksByVerse = <int, List<BibleDocumentBlock>>{};
    for (final block in widget.chapter.blocks) {
      if (block.kind != BibleDocumentBlockKind.paragraph) continue;
      final beforeVerse = int.tryParse(block.metadata['beforeVerse'] ?? '');
      if (beforeVerse == null) continue;
      paragraphBlocksByVerse
          .putIfAbsent(beforeVerse, () => <BibleDocumentBlock>[])
          .add(block);
    }

    if (paragraphBlocksByVerse.isEmpty) {
      return [
        _ParagraphSection(
          leadingBlocks: const [],
          verses: widget.chapter.verses,
        ),
      ];
    }

    final sections = <_ParagraphSection>[];
    final firstVerseNumber = widget.chapter.verses.first.number;
    var currentLeadingBlocks = List<BibleDocumentBlock>.from(
      paragraphBlocksByVerse[firstVerseNumber] ?? const [],
    );
    var currentVerses = <BibleVerse>[];

    for (final verse in widget.chapter.verses) {
      final paragraphStartBlocks = paragraphBlocksByVerse[verse.number];
      if (paragraphStartBlocks != null && currentVerses.isNotEmpty) {
        // Start a new rendered paragraph only when the source says the next
        // verse begins a new paragraph. This keeps paragraph mode tied to the
        // imported document structure instead of a UI-only guess.
        sections.add(
          _ParagraphSection(
            leadingBlocks: currentLeadingBlocks,
            verses: currentVerses,
          ),
        );
        currentLeadingBlocks = List<BibleDocumentBlock>.from(
          paragraphStartBlocks,
        );
        currentVerses = <BibleVerse>[];
      }
      currentVerses.add(verse);
    }

    if (currentVerses.isNotEmpty) {
      sections.add(
        _ParagraphSection(
          leadingBlocks: currentLeadingBlocks,
          verses: currentVerses,
        ),
      );
    }

    return sections;
  }

  void _showVerseDetailsSheet(BuildContext context, BibleVerse verse) {
    final footnotes = _footnoteLines(verse);
    final references = _structuredReferences(verse);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Verse ${verse.number}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (footnotes.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Footnotes',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    for (final note in footnotes)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          note,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                  ],
                  if (references.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Cross-References',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    for (final referenceEntry in references)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(referenceEntry.label),
                        subtitle: referenceEntry.target != null
                            ? Text(referenceEntry.target!)
                            : null,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ReferenceScreen(
                                references: [referenceEntry.label],
                                currentReference: widget.reference,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<String> _footnoteLines(BibleVerse verse) {
    if (verse.footnotes.isNotEmpty) {
      return verse.footnotes.map((footnote) {
        final label = [
          if (footnote.marker != null && footnote.marker!.isNotEmpty)
            footnote.marker,
          if (footnote.label != null && footnote.label!.isNotEmpty)
            footnote.label,
        ].join(' ');

        final referenceSuffix = footnote.references.isEmpty
            ? ''
            : ' (${footnote.references.map((ref) => ref.label).join(', ')})';

        return label.isEmpty
            ? '${footnote.text}$referenceSuffix'
            : '$label ${footnote.text}$referenceSuffix';
      }).toList();
    }

    return verse.notes ?? const [];
  }

  List<BibleCrossReference> _structuredReferences(BibleVerse verse) {
    if (verse.crossReferences.isNotEmpty) {
      return verse.crossReferences;
    }
    return (verse.references ?? const [])
        .map((reference) => BibleCrossReference(label: reference))
        .toList();
  }

  List<InlineSpan> _buildVerseContentSpans(
    BuildContext context,
    BibleVerse verse,
  ) {
    final spans = _displaySpans(verse);
    if (spans.isEmpty) {
      return [TextSpan(text: verse.text)];
    }

    final baseColor = Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    return spans.map((span) {
      return TextSpan(
        text: _spanText(span),
        style: TextStyle(
          color: _spanColor(span.kind, baseColor, secondaryColor),
          fontStyle: _spanFontStyle(span.kind),
          fontWeight: _spanFontWeight(span.kind),
          decoration: _spanDecoration(span.kind),
        ),
      );
    }).toList();
  }

  List<BibleVerseSpan> _displaySpans(BibleVerse verse) {
    if (verse.spans.isEmpty) return const [];

    final displaySpans = <BibleVerseSpan>[];
    var previousText = '';

    for (final span in verse.spans) {
      var text = span.text.trim();
      if (text.isEmpty) continue;

      // Some source formats split every word into separate rich spans.
      // Reinsert display spacing here so tag-heavy sources like KJV do not
      // collapse into "wordstucktogether" when rendered span-by-span.
      if (_shouldInsertSpace(previousText, text)) {
        text = ' $text';
      }

      displaySpans.add(
        BibleVerseSpan(text: text, kind: span.kind, metadata: span.metadata),
      );
      previousText = text;
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

  Color? _spanColor(
    BibleVerseSpanKind kind,
    Color? baseColor,
    Color secondaryColor,
  ) {
    switch (kind) {
      case BibleVerseSpanKind.wordsOfJesus:
        return Colors.red.shade700;
      case BibleVerseSpanKind.word:
        return secondaryColor;
      default:
        return baseColor;
    }
  }

  FontStyle _spanFontStyle(BibleVerseSpanKind kind) {
    switch (kind) {
      case BibleVerseSpanKind.translatorAddition:
      case BibleVerseSpanKind.quote:
      case BibleVerseSpanKind.poetry:
        return FontStyle.italic;
      default:
        return FontStyle.normal;
    }
  }

  FontWeight _spanFontWeight(BibleVerseSpanKind kind) {
    switch (kind) {
      case BibleVerseSpanKind.wordsOfJesus:
        return FontWeight.w600;
      case BibleVerseSpanKind.word:
        return FontWeight.w500;
      default:
        return FontWeight.normal;
    }
  }

  TextDecoration? _spanDecoration(BibleVerseSpanKind kind) {
    switch (kind) {
      case BibleVerseSpanKind.word:
        return TextDecoration.underline;
      default:
        return null;
    }
  }
}

class _ParagraphSection {
  const _ParagraphSection({required this.leadingBlocks, required this.verses});

  final List<BibleDocumentBlock> leadingBlocks;
  final List<BibleVerse> verses;
}

class _DocumentBlockView extends StatelessWidget {
  const _DocumentBlockView({
    required this.block,
    required this.fontSize,
    this.isEmphasized = false,
  });

  final BibleDocumentBlock block;
  final double fontSize;
  final bool isEmphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = switch (block.kind) {
      BibleDocumentBlockKind.heading => theme.textTheme.titleLarge,
      BibleDocumentBlockKind.preface ||
      BibleDocumentBlockKind.introduction => theme.textTheme.bodyLarge,
      BibleDocumentBlockKind.poetry => theme.textTheme.bodyLarge?.copyWith(
        fontStyle: FontStyle.italic,
      ),
      _ => theme.textTheme.bodyMedium,
    };

    return Padding(
      padding: EdgeInsets.only(
        bottom: block.kind == BibleDocumentBlockKind.heading ? 12 : 10,
      ),
      child: Text(
        block.text,
        style: style?.copyWith(
          fontSize: (style.fontSize ?? fontSize) + (isEmphasized ? 1 : 0),
          color: isEmphasized ? theme.colorScheme.secondary : style.color,
          height: 1.5,
        ),
      ),
    );
  }
}

/// Loading state widget
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading Bible...'),
        ],
      ),
    );
  }
}

/// Error state widget
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            SelectableText(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, child) {
                return ElevatedButton(
                  onPressed: () {
                    ref.invalidate(bibleBooksProvider);
                  },
                  child: const Text('Retry'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
