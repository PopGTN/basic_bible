import 'package:flutter/material.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/utils/reference_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChapterBar extends StatelessWidget {
  const ChapterBar({
    super.key,
    required double barHeight,
    required this.isFloating,
    required this.reference,
    required this.books,
    required this.showVerseSelector,
    required this.onReferenceChanged,
    required this.onPreviousChapter,
    required this.onNextChapter,
  }) : _barHeight = barHeight;

  final double _barHeight;
  final bool isFloating;
  final BibleReference reference;
  final List<BibleBook> books;
  final bool showVerseSelector;
  final Function(BibleReference) onReferenceChanged;
  final VoidCallback onPreviousChapter;
  final VoidCallback onNextChapter;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final referenceBookName = displayBookNameForReference(
      books,
      reference.bookId,
    );
    final referenceLabel = '$referenceBookName ${reference.chapter}';

    if (isFloating) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Material(
          color: colors.surfaceContainerHighest,
          elevation: 6,
          shadowColor: Colors.black.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(28),
          clipBehavior: Clip.antiAlias,
          child: Container(
            height: _barHeight,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.7),
              ),
            ),
            child: Row(
              children: [
                _BarActionButton(
                  icon: Icons.arrow_back_ios_new,
                  onPressed: onPreviousChapter,
                  tooltip: 'Previous chapter',
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => _showReferencePicker(context),
                    borderRadius: BorderRadius.circular(28),
                    child: Center(
                      child: Text(
                        referenceLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                _BarActionButton(
                  icon: Icons.arrow_forward_ios,
                  onPressed: onNextChapter,
                  tooltip: 'Next chapter',
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      height: _barHeight,
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _BarActionButton(
            icon: Icons.arrow_back_ios_new,
            onPressed: onPreviousChapter,
            tooltip: 'Previous chapter',
          ),
          Expanded(
            child: InkWell(
              onTap: () => _showReferencePicker(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      referenceBookName,
                      style: Theme.of(context).textTheme.titleSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${reference.chapter}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _BarActionButton(
            icon: Icons.arrow_forward_ios,
            onPressed: onNextChapter,
            tooltip: 'Next chapter',
          ),
        ],
      ),
    );
  }

  void _showReferencePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ReferencePicker(
        books: books,
        currentReference: reference,
        showVerseSelector: showVerseSelector,
        onReferenceSelected: (newReference) {
          onReferenceChanged(newReference);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

class _BarActionButton extends StatelessWidget {
  const _BarActionButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return IconButton(
      icon: Icon(icon, size: 18),
      onPressed: onPressed,
      tooltip: tooltip,
      color: colors.onSurface,
      splashRadius: 22,
    );
  }
}

class ReferencePicker extends StatefulWidget {
  const ReferencePicker({
    super.key,
    required this.books,
    required this.currentReference,
    required this.showVerseSelector,
    required this.onReferenceSelected,
  });

  final List<BibleBook> books;
  final BibleReference currentReference;
  final bool showVerseSelector;
  final Function(BibleReference) onReferenceSelected;

  @override
  State<ReferencePicker> createState() => _ReferencePickerState();
}

class _ReferencePickerState extends State<ReferencePicker> {
  late String selectedBookId;
  late int selectedChapter;
  int? selectedVerse;
  final TextEditingController _searchController = TextEditingController();
  List<BibleBook> filteredBooks = [];
  bool _alphabeticalOrder = false;
  List<BibleReference> _history = const [];

  @override
  void initState() {
    super.initState();
    selectedBookId = widget.currentReference.bookId;
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
    widget.onReferenceSelected(reference);
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
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const ListTile(title: Text('Recent References')),
              for (final reference in _history)
                ListTile(
                  title: Text(_referenceLabel(reference)),
                  onTap: () {
                    Navigator.of(context).pop();
                    widget.onReferenceSelected(reference);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  String _referenceLabel(BibleReference reference) {
    final book = resolveBookFromReference(widget.books, reference.bookId);
    final bookName = book != null
        ? preferredBookName(book)
        : bookIdToName(reference.bookId);
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

  @override
  Widget build(BuildContext context) {
    if (widget.books.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final selectedBook = widget.books.firstWhere(
      (book) => book.id == selectedBookId,
      orElse: () => widget.books.first,
    );
    final selectedChapterModel = selectedBook.chapters.firstWhere(
      (chapter) => chapter.number == selectedChapter,
      orElse: () => selectedBook.chapters.isNotEmpty
          ? selectedBook.chapters.first
          : const BibleChapter(number: 1),
    );
    final visibleBooks = _visibleBooks;
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    Expanded(
                      child: Text(
                        'References',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
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
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      tooltip: 'History',
                      onPressed: _openHistorySheet,
                      icon: const Icon(Icons.history),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: colors.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterBooks('');
                            },
                          )
                        : null,
                  ),
                  onChanged: _filterBooks,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              children: [
                for (final book in visibleBooks) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 12),
                    child: Text(
                      preferredBookName(book),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                    itemCount: book.chapters.length,
                    itemBuilder: (context, index) {
                      final chapter = book.chapters[index];
                      final isSelected =
                          book.id == selectedBookId &&
                          chapter.number == selectedChapter;

                      return InkWell(
                        onTap: () {
                          if (!widget.showVerseSelector) {
                            _selectReference(
                              BibleReference(
                                bookId: book.id,
                                chapter: chapter.number,
                              ),
                            );
                            return;
                          }
                          setState(() {
                            selectedBookId = book.id;
                            selectedChapter = chapter.number;
                            selectedVerse = null;
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colors.primary
                                : colors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              '${chapter.number}',
                              style: TextStyle(
                                color: isSelected
                                    ? colors.onPrimary
                                    : colors.onSurfaceVariant,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  if (widget.showVerseSelector &&
                      book.id == selectedBookId &&
                      selectedChapterModel.verses.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => _selectReference(
                            BibleReference(
                              bookId: book.id,
                              chapter: selectedChapter,
                            ),
                          ),
                          child: Text(
                            'Go to ${preferredBookName(book)} $selectedChapter',
                          ),
                        ),
                      ],
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 1.1,
                          ),
                      itemCount: selectedChapterModel.verses.length,
                      itemBuilder: (context, index) {
                        final verse = selectedChapterModel.verses[index];
                        final isSelected = verse.number == selectedVerse;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedVerse = verse.number;
                            });
                            _selectReference(
                              BibleReference(
                                bookId: book.id,
                                chapter: selectedChapter,
                                verse: verse.number,
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colors.secondary
                                  : colors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                '${verse.number}',
                                style: TextStyle(
                                  color: isSelected
                                      ? colors.onSecondary
                                      : colors.onSurfaceVariant,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
