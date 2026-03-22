import 'package:flutter/material.dart';
import '../../../../../models/bible_models.dart';

class ChapterBar extends StatelessWidget {
  const ChapterBar({
    super.key,
    required double barHeight,
    required this.reference,
    required this.books,
    required this.onReferenceChanged,
    required this.onPreviousChapter,
    required this.onNextChapter,
  }) : _barHeight = barHeight;

  final double _barHeight;
  final BibleReference reference;
  final List<BibleBook> books;
  final Function(BibleReference) onReferenceChanged;
  final VoidCallback onPreviousChapter;
  final VoidCallback onNextChapter;

  @override
  Widget build(BuildContext context) {
    final currentBook = books.firstWhere(
          (book) => book.id == reference.bookId,
      orElse: () => BibleBook(id: '', name: 'Unknown', shortName: '', bookNumber: 0),
    );

    return Container(
      height: _barHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onPreviousChapter,
            tooltip: 'Previous chapter',
          ),
          Expanded(
            child: InkWell(
              onTap: () => _showReferencePicker(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currentBook.name,
                      style: Theme.of(context).textTheme.titleSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Chapter ${reference.chapter}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
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

class _ReferencePickerState extends State<ReferencePicker> with TickerProviderStateMixin {
  late String selectedBookId;
  late int selectedChapter;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<BibleBook> filteredBooks = [];

  @override
  void initState() {
    super.initState();
    selectedBookId = widget.currentReference.bookId;
    selectedChapter = widget.currentReference.chapter;
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
            .where((book) =>
        book.name.toLowerCase().contains(query.toLowerCase()) ||
            book.shortName.toLowerCase().contains(query.toLowerCase()) ||
            book.id.toLowerCase().contains(query.toLowerCase()))
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
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 6,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 1.2,
                            ),
                            itemCount: selectedBook.chapters.length,
                            itemBuilder: (context, index) {
                              final chapter = selectedBook.chapters[index];
                              final isSelected = chapter.number == selectedChapter;

                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedChapter = chapter.number;
                                  });
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(8),
                                    border: isSelected ? Border.all(
                                      color: Theme.of(context).colorScheme.primary,
                                      width: 2,
                                    ) : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${chapter.number}',
                                      style: TextStyle(
                                        color: isSelected
                                            ? Theme.of(context).colorScheme.onPrimary
                                            : Theme.of(context).colorScheme.onSurfaceVariant,
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
                        ),
                      );
                    },
                    child: const Text('Go to Chapter'),
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
    if (books.isEmpty) {
      return const Center(
        child: Text('No books found'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        final isSelected = book.id == selectedBookId;

        return Card(
          margin: const EdgeInsets.only(bottom: 4),
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : null,
          child: ListTile(
            dense: true,
            selected: isSelected,
            title: Text(
              book.name,
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
