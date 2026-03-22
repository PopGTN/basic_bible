import 'package:flutter/material.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/utils/reference_utils.dart';

class ChapterBar extends StatelessWidget {
  const ChapterBar({
    super.key,
    required double barHeight,
    required this.isFloating,
    required this.reference,
    required this.books,
    required this.onReferenceChanged,
    required this.onPreviousChapter,
    required this.onNextChapter,
  }) : _barHeight = barHeight;

  final double _barHeight;
  final bool isFloating;
  final BibleReference reference;
  final List<BibleBook> books;
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
    required this.onReferenceSelected,
  });

  final List<BibleBook> books;
  final BibleReference currentReference;
  final Function(BibleReference) onReferenceSelected;

  @override
  State<ReferencePicker> createState() => _ReferencePickerState();
}

class _ReferencePickerState extends State<ReferencePicker>
    with TickerProviderStateMixin {
  late String selectedBookId;
  late int selectedChapter;
  int? selectedVerse;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<BibleBook> filteredBooks = [];

  @override
  void initState() {
    super.initState();
    selectedBookId = widget.currentReference.bookId;
    selectedChapter = widget.currentReference.chapter;
    selectedVerse = widget.currentReference.verse;
    filteredBooks = widget.books;
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _filterBooks(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredBooks = widget.books;
      } else {
        filteredBooks = widget.books
            .where(
              (book) =>
                  book.name.toLowerCase().contains(query.toLowerCase()) ||
                  book.shortName.toLowerCase().contains(query.toLowerCase()) ||
                  book.id.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  List<BibleBook> _getBooksByTestament(BibleBookType testament) {
    return filteredBooks.where((book) => book.bookType == testament).toList();
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
                Text(
                  'Select Bible Reference',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),

                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search books...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
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

          // Tab bar for Old/New Testament
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Old Testament'),
              Tab(text: 'New Testament'),
              Tab(text: 'All Books'),
            ],
          ),

          // Content area
          Expanded(
            child: Row(
              children: [
                // Books list
                Expanded(
                  flex: 2,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _BooksList(
                        books: _getBooksByTestament(BibleBookType.oldTestament),
                        selectedBookId: selectedBookId,
                        onBookSelected: (bookId) {
                          setState(() {
                            selectedBookId = bookId;
                            selectedChapter = 1;
                            selectedVerse = null;
                          });
                        },
                      ),
                      _BooksList(
                        books: _getBooksByTestament(BibleBookType.newTestament),
                        selectedBookId: selectedBookId,
                        onBookSelected: (bookId) {
                          setState(() {
                            selectedBookId = bookId;
                            selectedChapter = 1;
                            selectedVerse = null;
                          });
                        },
                      ),
                      _BooksList(
                        books: filteredBooks,
                        selectedBookId: selectedBookId,
                        onBookSelected: (bookId) {
                          setState(() {
                            selectedBookId = bookId;
                            selectedChapter = 1;
                            selectedVerse = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const VerticalDivider(width: 1),

                // Chapters grid
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedBook.name,
                              style: Theme.of(context).textTheme.titleMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${selectedBook.chapters.length} chapters',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chapters',
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 6,
                                        mainAxisSpacing: 8,
                                        crossAxisSpacing: 8,
                                        childAspectRatio: 1.2,
                                      ),
                                  itemCount: selectedBook.chapters.length,
                                  itemBuilder: (context, index) {
                                    final chapter =
                                        selectedBook.chapters[index];
                                    final isSelected =
                                        chapter.number == selectedChapter;

                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          selectedChapter = chapter.number;
                                          selectedVerse = null;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                              : Theme.of(context)
                                                    .colorScheme
                                                    .surfaceContainerHighest,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: isSelected
                                              ? Border.all(
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                  width: 2,
                                                )
                                              : null,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${chapter.number}',
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Theme.of(
                                                      context,
                                                    ).colorScheme.onPrimary
                                                  : Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Verses',
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 160,
                                child: GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 8,
                                        mainAxisSpacing: 8,
                                        crossAxisSpacing: 8,
                                        childAspectRatio: 1.15,
                                      ),
                                  itemCount: selectedChapterModel.verses.length,
                                  itemBuilder: (context, index) {
                                    final verse =
                                        selectedChapterModel.verses[index];
                                    final isSelected =
                                        verse.number == selectedVerse;

                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          selectedVerse = verse.number;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.secondary
                                              : Theme.of(context)
                                                    .colorScheme
                                                    .surfaceContainerHighest,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${verse.number}',
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Theme.of(
                                                      context,
                                                    ).colorScheme.onSecondary
                                                  : Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onReferenceSelected(
                        BibleReference(
                          bookId: selectedBookId,
                          chapter: selectedChapter,
                          verse: selectedVerse,
                        ),
                      );
                    },
                    child: Text(
                      selectedVerse == null ? 'Go to Chapter' : 'Go to Verse',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BooksList extends StatelessWidget {
  const _BooksList({
    required this.books,
    required this.selectedBookId,
    required this.onBookSelected,
  });

  final List<BibleBook> books;
  final String selectedBookId;
  final Function(String) onBookSelected;

  @override
  Widget build(BuildContext context) {
    final visibleBooks = books
        .where((book) => preferredBookName(book).trim().isNotEmpty)
        .toList();

    if (visibleBooks.isEmpty) {
      return const Center(child: Text('No books found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: visibleBooks.length,
      itemBuilder: (context, index) {
        final book = visibleBooks[index];
        final isSelected = book.id == selectedBookId;
        final displayName = preferredBookName(book).trim();

        return Card(
          margin: const EdgeInsets.only(bottom: 4),
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : null,
          child: ListTile(
            dense: true,
            selected: isSelected,
            title: Text(
              displayName,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text('${book.chapters.length} chapters'),
            trailing: isSelected
                ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
            onTap: () => onBookSelected(book.id),
          ),
        );
      },
    );
  }
}
