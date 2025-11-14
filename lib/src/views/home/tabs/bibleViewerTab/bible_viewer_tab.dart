import 'reference_screen.dart';
import 'package:basic_bible/src/views/home/tabs/bibleViewerTab/widgets/ReferenceBar.dart';
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
                ref.read(currentReferenceProvider.notifier).setReference(reference);
              },
              onPreviousChapter: () {
                if (booksAsync.value != null) {
                  ref.read(currentReferenceProvider.notifier)
                      .goToPreviousChapter(booksAsync.value!);
                }
              },
              onNextChapter: () {
                if (booksAsync.value != null) {
                  ref.read(currentReferenceProvider.notifier)
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
                        chapter: chapter,
                        reference: currentReference,
                        fontSize: size,
                        isSmallDevice: isSmall,
                      )
                    : const _ErrorView(message: 'Chapter not found'),
                loading: () => const _LoadingView(),
                error: (error, stack) => _ErrorView(message: 'Error: $error'),
              ),
              loading: () => const _LoadingView(),
              error: (error, stack) => _ErrorView(message: 'Failed to load Bible: $error'),
            );
          },
        ),

        // Translation selector removed — translations are selected from HomeScreen


      ],
    );
  }
}



/// Bible text display widget
class _BibleTextView extends StatelessWidget {
  const _BibleTextView({
    required this.controller,
    required this.chapter,
    required this.reference,
    required this.fontSize,
    required this.isSmallDevice,
  });

  final ScrollController controller;
  final BibleChapter chapter;
  final BibleReference reference;
  final double fontSize;
  final bool isSmallDevice;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: isSmallDevice ? 16 : 80, // keep larger top space on tablet/desktop
        bottom: 72, // Space for chapter bar
      ),
      child: ListView.builder(
        controller: controller,
        itemCount: chapter.verses.length + 1, // +1 for chapter title
        itemBuilder: (context, index) {
          if (index == 0) {
            // Chapter title
            final bookName = _getBookName(reference.bookId);
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                '$bookName ${reference.chapter}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: fontSize + 4,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }

          final verse = chapter.verses[index - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: GestureDetector(
              onTap: () {
                if (verse.notes != null && verse.notes!.isNotEmpty) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Footnotes for Verse ${verse.number}'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: verse.notes!
                              .map((note) => Text(note))
                              .toList(),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                } else if (verse.references != null && verse.references!.isNotEmpty) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ReferenceScreen(
                        references: verse.references!,
                        currentReference: reference,
                      ),
                    ),
                  );
                }
              },
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: fontSize,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(
                      text: '${verse.number} ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: fontSize - 2,
                      ),
                    ),
                    TextSpan(text: verse.text),
                    if (verse.notes != null && verse.notes!.isNotEmpty)
                      WidgetSpan(
                        child: Icon(
                          Icons.info_outline,
                          size: fontSize,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    if (verse.references != null && verse.references!.isNotEmpty)
                      WidgetSpan(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Icon(
                            Icons.link, // Or another appropriate icon for references
                            size: fontSize,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getBookName(String bookId) {
    const bookNames = {
      'GEN': 'Genesis',
      'EXO': 'Exodus',
      'LEV': 'Leviticus',
      'NUM': 'Numbers',
      'DEU': 'Deuteronomy',
      'JOS': 'Joshua',
      'JDG': 'Judges',
      'RUT': 'Ruth',
      '1SA': '1 Samuel',
      '2SA': '2 Samuel',
      '1KI': '1 Kings',
      '2KI': '2 Kings',
      '1CH': '1 Chronicles',
      '2CH': '2 Chronicles',
      'EZR': 'Ezra',
      'NEH': 'Nehemiah',
      'EST': 'Esther',
      'JOB': 'Job',
      'PSA': 'Psalms',
      'PRO': 'Proverbs',
      'ECC': 'Ecclesiastes',
      'SNG': 'Song of Songs',
      'ISA': 'Isaiah',
      'JER': 'Jeremiah',
      'LAM': 'Lamentations',
      'EZK': 'Ezekiel',
      'DAN': 'Daniel',
      'HOS': 'Hosea',
      'JOL': 'Joel',
      'AMO': 'Amos',
      'OBA': 'Obadiah',
      'JON': 'Jonah',
      'MIC': 'Micah',
      'NAM': 'Nahum',
      'HAB': 'Habakkuk',
      'ZEP': 'Zephaniah',
      'HAG': 'Haggai',
      'ZEC': 'Zechariah',
      'MAL': 'Malachi',
      'MAT': 'Matthew',
      'MRK': 'Mark',
      'LUK': 'Luke',
      'JHN': 'John',
      'ACT': 'Acts',
      'ROM': 'Romans',
      '1CO': '1 Corinthians',
      '2CO': '2 Corinthians',
      'GAL': 'Galatians',
      'EPH': 'Ephesians',
      'PHP': 'Philippians',
      'COL': 'Colossians',
      '1TH': '1 Thessalonians',
      '2TH': '2 Thessalonians',
      '1TI': '1 Timothy',
      '2TI': '2 Timothy',
      'TIT': 'Titus',
      'PHM': 'Philemon',
      'HEB': 'Hebrews',
      'JAS': 'James',
      '1PE': '1 Peter',
      '2PE': '2 Peter',
      '1JN': '1 John',
      '2JN': '2 John',
      '3JN': '3 John',
      'JUD': 'Jude',
      'REV': 'Revelation',
    };
    return bookNames[bookId] ?? bookId;
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