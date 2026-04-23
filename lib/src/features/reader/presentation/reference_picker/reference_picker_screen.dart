import 'package:basic_bible/src/features/library/data/app_bible_repository.dart';
import 'package:basic_bible/src/features/reader/application/view_models/bible_library_view_models.dart';
import 'package:basic_bible/src/features/reader/application/view_models/reader_session_view_models.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/utils/reference_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReferencePickerScreen extends ConsumerStatefulWidget {
  const ReferencePickerScreen({
    super.key,
    required this.books,
    required this.currentReference,
    required this.showVerseSelector,
  });

  final List<BibleBook> books;
  final BibleReference currentReference;
  final bool showVerseSelector;

  @override
  ConsumerState<ReferencePickerScreen> createState() =>
      _ReferencePickerScreenState();
}

class _ReferencePickerScreenState extends ConsumerState<ReferencePickerScreen> {
  late String expandedBookId;
  late int selectedChapter;
  int? selectedVerse;
  final TextEditingController _searchController = TextEditingController();
  List<BibleBook> filteredBooks = [];
  bool _alphabeticalOrder = false;
  List<BibleReference> _history = const [];
  final Map<String, BibleChapter> _hydratedChapters = {};

  @override
  void initState() {
    super.initState();
    expandedBookId = widget.currentReference.bookId;
    selectedChapter = widget.currentReference.chapter;
    selectedVerse = widget.currentReference.verse;
    filteredBooks = widget.books;
    _loadReferenceHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadReferenceHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList('reference_history') ?? const [];
    final history = <BibleReference>[];
    for (final item in items) {
      final parsed = _decodeReference(item);
      if (parsed != null) {
        history.add(parsed);
      }
    }
    if (!mounted) return;
    setState(() {
      _history = history;
    });
  }

  Future<void> _storeReferenceInHistory(BibleReference reference) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _encodeReference(reference);
    final existing = prefs.getStringList('reference_history') ?? const [];
    final next = [
      encoded,
      ...existing.where((entry) => entry != encoded),
    ].take(20).toList();
    await prefs.setStringList('reference_history', next);
    if (!mounted) return;
    setState(() {
      _history = next
          .map(_decodeReference)
          .whereType<BibleReference>()
          .toList();
    });
  }

  void _filterBooks(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredBooks = widget.books;
      } else {
        filteredBooks = widget.books
            .where(
              (book) =>
                  preferredBookName(
                    book,
                  ).toLowerCase().contains(query.toLowerCase()) ||
                  book.shortName.toLowerCase().contains(query.toLowerCase()) ||
                  book.id.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  List<BibleBook> get _visibleBooks {
    final books = filteredBooks
        .where((book) => preferredBookName(book).trim().isNotEmpty)
        .toList();
    if (_alphabeticalOrder) {
      books.sort(
        (a, b) => preferredBookName(
          a,
        ).toLowerCase().compareTo(preferredBookName(b).toLowerCase()),
      );
    }
    return books;
  }

  Future<void> _selectReference(BibleReference reference) async {
    await _storeReferenceInHistory(reference);
    if (!mounted) return;
    Navigator.of(context).pop(reference);
  }

  Future<void> _clearReferenceHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('reference_history');
    if (!mounted) return;
    setState(() {
      _history = const [];
    });
  }

  Future<void> _openHistorySheet() async {
    if (_history.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No reference history yet.')),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 8, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Recent References',
                            style: Theme.of(sheetContext).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            await _clearReferenceHistory();
                            if (sheetContext.mounted) {
                              Navigator.of(sheetContext).pop();
                            }
                          },
                          icon: const Icon(Icons.delete_sweep_outlined,
                              size: 18),
                          label: const Text('Clear'),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        for (final reference in _history)
                          ListTile(
                            title: Text(_referenceLabel(reference)),
                            onTap: () {
                              Navigator.of(sheetContext).pop();
                              _selectReference(reference);
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _referenceLabel(BibleReference reference) {
    final book = resolveBookFromReference(widget.books, reference.bookId);
    final bookName = book != null
        ? preferredBookName(book)
        : humanizeBookId(reference.bookId);
    final verseSuffix = reference.verse != null ? ':${reference.verse}' : '';
    return '$bookName ${reference.chapter}$verseSuffix';
  }

  String _encodeReference(BibleReference reference) {
    return '${reference.bookId}|${reference.chapter}|${reference.verse ?? ''}';
  }

  BibleReference? _decodeReference(String rawValue) {
    final parts = rawValue.split('|');
    if (parts.length < 2) return null;
    final chapter = int.tryParse(parts[1]);
    if (chapter == null) return null;
    final verse = parts.length > 2 && parts[2].isNotEmpty
        ? int.tryParse(parts[2])
        : null;
    return BibleReference(bookId: parts[0], chapter: chapter, verse: verse);
  }

  Future<void> _hydrateChapter(String bookId, int chapterNumber) async {
    final key = '$bookId:$chapterNumber';
    if (_hydratedChapters.containsKey(key)) return;
    final translation = ref.read(currentTranslationProvider);
    final repository = ref.read(bibleRepositoryProvider);
    final chapter = await repository.loadChapterVerses(
      translation,
      bookId,
      chapterNumber,
    );
    if (!mounted || chapter == null) return;
    setState(() {
      _hydratedChapters[key] = chapter;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.books.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final expandedBook = widget.books.firstWhere(
      (book) => book.id == expandedBookId,
      orElse: () => widget.books.first,
    );
    final shellChapter = expandedBook.chapters.firstWhere(
      (chapter) => chapter.number == selectedChapter,
      orElse: () => expandedBook.chapters.isNotEmpty
          ? expandedBook.chapters.first
          : const BibleChapter(number: 1),
    );
    final hydratedKey = '${expandedBook.id}:$selectedChapter';
    final selectedChapterModel = _hydratedChapters[hydratedKey] ?? shellChapter;
    final visibleBooks = _visibleBooks;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('References'),
        actions: [
          IconButton(
            tooltip: _alphabeticalOrder
                ? 'Show canonical order'
                : 'Sort alphabetically',
            onPressed: () {
              setState(() {
                _alphabeticalOrder = !_alphabeticalOrder;
              });
            },
            icon: Text(
              'AZ',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            tooltip: 'History',
            onPressed: _openHistorySheet,
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 980;
          final isTablet = constraints.maxWidth >= 680;

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  isDesktop ? 24 : 16,
                  16,
                  isDesktop ? 24 : 16,
                  12,
                ),
                child: _ReferencePickerHeader(
                  controller: _searchController,
                  onChanged: _filterBooks,
                  onClear: () {
                    _searchController.clear();
                    _filterBooks('');
                  },
                  selectedLabel:
                      '${preferredBookName(expandedBook)} $selectedChapter',
                ),
              ),
              Expanded(
                child: isDesktop
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              width: 320,
                              child: _ReferenceBookList(
                                books: visibleBooks,
                                expandedBookId: expandedBookId,
                                selectedChapter: selectedChapter,
                                onBookTap: (book) => _handleBookTap(book),
                                dense: false,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _ReferenceSelectionPanel(
                                book: expandedBook,
                                colors: colors,
                                selectedChapter: selectedChapter,
                                selectedVerse: selectedVerse,
                                showVerseSelector: widget.showVerseSelector,
                                selectedChapterModel: selectedChapterModel,
                                compact: false,
                                onChapterTap: (chapterNumber) {
                                  if (!widget.showVerseSelector) {
                                    _selectReference(
                                      BibleReference(
                                        bookId: expandedBook.id,
                                        chapter: chapterNumber,
                                      ),
                                    );
                                    return;
                                  }
                                  setState(() {
                                    expandedBookId = expandedBook.id;
                                    selectedChapter = chapterNumber;
                                    selectedVerse = null;
                                  });
                                  _hydrateChapter(
                                    expandedBook.id,
                                    chapterNumber,
                                  );
                                },
                                onChapterSelect: () => _selectReference(
                                  BibleReference(
                                    bookId: expandedBook.id,
                                    chapter: selectedChapter,
                                  ),
                                ),
                                onVerseTap: (verseNumber) {
                                  setState(() {
                                    selectedVerse = verseNumber;
                                  });
                                  _selectReference(
                                    BibleReference(
                                      bookId: expandedBook.id,
                                      chapter: selectedChapter,
                                      verse: verseNumber,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.fromLTRB(
                          isTablet ? 20 : 16,
                          0,
                          isTablet ? 20 : 16,
                          20,
                        ),
                        itemCount: visibleBooks.length,
                        itemBuilder: (context, index) {
                          final book = visibleBooks[index];
                          final isExpanded = book.id == expandedBookId;
                          final chapterForBook = book.id == expandedBook.id
                              ? selectedChapterModel
                              : (book.chapters.isNotEmpty
                                    ? book.chapters.first
                                    : const BibleChapter(number: 1));
                          return _ReferenceBookCard(
                            book: book,
                            isExpanded: isExpanded,
                            selectedChapter: selectedChapter,
                            onBookTap: () => _handleBookTap(book),
                            child: isExpanded
                                ? _ReferenceSelectionPanel(
                                    book: book,
                                    colors: colors,
                                    selectedChapter: selectedChapter,
                                    selectedVerse: selectedVerse,
                                    showVerseSelector: widget.showVerseSelector,
                                    selectedChapterModel: chapterForBook,
                                    compact: true,
                                    onChapterTap: (chapterNumber) {
                                      if (!widget.showVerseSelector) {
                                        _selectReference(
                                          BibleReference(
                                            bookId: book.id,
                                            chapter: chapterNumber,
                                          ),
                                        );
                                        return;
                                      }
                                      setState(() {
                                        expandedBookId = book.id;
                                        selectedChapter = chapterNumber;
                                        selectedVerse = null;
                                      });
                                      _hydrateChapter(book.id, chapterNumber);
                                    },
                                    onChapterSelect: () => _selectReference(
                                      BibleReference(
                                        bookId: book.id,
                                        chapter: selectedChapter,
                                      ),
                                    ),
                                    onVerseTap: (verseNumber) {
                                      setState(() {
                                        selectedVerse = verseNumber;
                                      });
                                      _selectReference(
                                        BibleReference(
                                          bookId: book.id,
                                          chapter: selectedChapter,
                                          verse: verseNumber,
                                        ),
                                      );
                                    },
                                  )
                                : null,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleBookTap(BibleBook book) {
    setState(() {
      final isClosing = expandedBookId == book.id;
      expandedBookId = isClosing ? '' : book.id;
      if (!isClosing) {
        selectedChapter = book.chapters.isNotEmpty
            ? book.chapters.first.number
            : 1;
        selectedVerse = null;
      }
    });
  }
}

class _ReferencePickerHeader extends StatelessWidget {
  const _ReferencePickerHeader({
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.selectedLabel,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String selectedLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Search books',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: colors.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(icon: const Icon(Icons.clear), onPressed: onClear)
                : null,
          ),
          onChanged: onChanged,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.menu_book_outlined, size: 18, color: colors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                selectedLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReferenceBookList extends StatelessWidget {
  const _ReferenceBookList({
    required this.books,
    required this.expandedBookId,
    required this.selectedChapter,
    required this.onBookTap,
    required this.dense,
  });

  final List<BibleBook> books;
  final String expandedBookId;
  final int selectedChapter;
  final ValueChanged<BibleBook> onBookTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: books.length,
        separatorBuilder: (_, _) => const SizedBox(height: 6),
        itemBuilder: (context, index) {
          final book = books[index];
          final isSelected = book.id == expandedBookId;
          return Material(
            color: isSelected
                ? colors.secondaryContainer
                : colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onBookTap(book),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: dense ? 12 : 14,
                  vertical: dense ? 10 : 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        preferredBookName(book),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                            ),
                      ),
                    ),
                    if (isSelected)
                      Text(
                        '$selectedChapter',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: colors.onSecondaryContainer,
                          fontWeight: FontWeight.w700,
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
}

class _ReferenceBookCard extends StatelessWidget {
  const _ReferenceBookCard({
    required this.book,
    required this.isExpanded,
    required this.selectedChapter,
    required this.onBookTap,
    this.child,
  });

  final BibleBook book;
  final bool isExpanded;
  final int selectedChapter;
  final VoidCallback onBookTap;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isExpanded
            ? colors.surfaceContainerLow
            : colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isExpanded
              ? colors.primary.withValues(alpha: 0.3)
              : colors.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onBookTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      preferredBookName(book),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (isExpanded)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Text(
                        '$selectedChapter',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: child == null ? const SizedBox.shrink() : child!,
          ),
        ],
      ),
    );
  }
}

class _ReferenceSelectionPanel extends StatelessWidget {
  const _ReferenceSelectionPanel({
    required this.book,
    required this.colors,
    required this.selectedChapter,
    required this.selectedVerse,
    required this.showVerseSelector,
    required this.selectedChapterModel,
    required this.onChapterTap,
    required this.onChapterSelect,
    required this.onVerseTap,
    required this.compact,
  });

  final BibleBook book;
  final ColorScheme colors;
  final int selectedChapter;
  final int? selectedVerse;
  final bool showVerseSelector;
  final BibleChapter selectedChapterModel;
  final ValueChanged<int> onChapterTap;
  final VoidCallback onChapterSelect;
  final ValueChanged<int> onVerseTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!compact) ...[
          Text(
            preferredBookName(book),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pick a chapter${showVerseSelector ? ' and optionally a verse' : ''}.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
        ],
        _ReferenceSectionLabel(label: 'Chapters', compact: compact),
        const SizedBox(height: 10),
        _ReferenceNumberGrid(
          itemCount: book.chapters.length,
          compact: compact,
          itemBuilder: (context, index) {
            final chapter = book.chapters[index];
            final isSelected = chapter.number == selectedChapter;
            return _ReferenceNumberTile(
              label: '${chapter.number}',
              isSelected: isSelected,
              colors: colors,
              compact: compact,
              onTap: () => onChapterTap(chapter.number),
            );
          },
        ),
        if (showVerseSelector) ...[
          SizedBox(height: compact ? 14 : 18),
          TextButton.icon(
            onPressed: onChapterSelect,
            icon: const Icon(Icons.arrow_forward, size: 18),
            label: Text('Go to ${preferredBookName(book)} $selectedChapter'),
          ),
          if (selectedChapterModel.verses.isNotEmpty) ...[
            SizedBox(height: compact ? 10 : 14),
            _ReferenceSectionLabel(
              label: 'Verses in $selectedChapter',
              compact: compact,
            ),
            const SizedBox(height: 10),
            _ReferenceNumberGrid(
              itemCount: selectedChapterModel.verses.length,
              compact: compact,
              verseGrid: true,
              itemBuilder: (context, index) {
                final verse = selectedChapterModel.verses[index];
                final isSelected = verse.number == selectedVerse;
                return _ReferenceNumberTile(
                  label: '${verse.number}',
                  isSelected: isSelected,
                  colors: colors,
                  compact: compact,
                  onTap: () => onVerseTap(verse.number),
                );
              },
            ),
          ],
        ],
      ],
    );

    if (compact) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: content,
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(child: content),
      ),
    );
  }
}

class _ReferenceSectionLabel extends StatelessWidget {
  const _ReferenceSectionLabel({required this.label, required this.compact});

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: compact ? 0.1 : 0.2,
      ),
    );
  }
}

class _ReferenceNumberGrid extends StatelessWidget {
  const _ReferenceNumberGrid({
    required this.itemCount,
    required this.itemBuilder,
    required this.compact,
    this.verseGrid = false,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final bool compact;
  final bool verseGrid;

  @override
  Widget build(BuildContext context) {
    final maxExtent = switch ((compact, verseGrid)) {
      (true, true) => 54.0,
      (true, false) => 60.0,
      (false, true) => 64.0,
      (false, false) => 72.0,
    };

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxExtent,
        mainAxisSpacing: compact ? 8 : 10,
        crossAxisSpacing: compact ? 8 : 10,
        childAspectRatio: 1,
      ),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}

class _ReferenceNumberTile extends StatelessWidget {
  const _ReferenceNumberTile({
    required this.label,
    required this.isSelected,
    required this.colors,
    required this.onTap,
    required this.compact,
  });

  final String label;
  final bool isSelected;
  final ColorScheme colors;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(compact ? 14 : 16),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? colors.secondary : colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(compact ? 14 : 16),
          border: Border.all(
            color: isSelected
                ? colors.secondary.withValues(alpha: 0.2)
                : colors.outlineVariant.withValues(alpha: 0.7),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? colors.onSecondary : colors.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              fontSize: compact ? 14 : 15,
            ),
          ),
        ),
      ),
    );
  }
}
