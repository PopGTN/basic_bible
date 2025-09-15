import 'package:flutter/material.dart';

class ReferenceScreen extends StatefulWidget {
  const ReferenceScreen({super.key});

  @override
  State<ReferenceScreen> createState() => _ReferenceScreenState();
}

class _ReferenceScreenState extends State<ReferenceScreen>
    with TickerProviderStateMixin {
  String? expandedBook; // only one book is expanded at a time

  // Bible books + number of chapters
  final Map<String, int> books = {
    // Old Testament
    "Genesis": 50,
    "Exodus": 40,
    "Leviticus": 27,
    "Numbers": 36,
    "Deuteronomy": 34,
    "Joshua": 24,
    "Judges": 21,
    "Ruth": 4,
    "1 Samuel": 31,
    "2 Samuel": 24,
    "1 Kings": 22,
    "2 Kings": 25,
    "1 Chronicles": 29,
    "2 Chronicles": 36,
    "Ezra": 10,
    "Nehemiah": 13,
    "Esther": 10,
    "Job": 42,
    "Psalms": 150,
    "Proverbs": 31,
    "Ecclesiastes": 12,
    "Song of Solomon": 8,
    "Isaiah": 66,
    "Jeremiah": 52,
    "Lamentations": 5,
    "Ezekiel": 48,
    "Daniel": 12,
    "Hosea": 14,
    "Joel": 3,
    "Amos": 9,
    "Obadiah": 1,
    "Jonah": 4,
    "Micah": 7,
    "Nahum": 3,
    "Habakkuk": 3,
    "Zephaniah": 3,
    "Haggai": 2,
    "Zechariah": 14,
    "Malachi": 4,

    // New Testament
    "Matthew": 28,
    "Mark": 16,
    "Luke": 24,
    "John": 21,
    "Acts": 28,
    "Romans": 16,
    "1 Corinthians": 16,
    "2 Corinthians": 13,
    "Galatians": 6,
    "Ephesians": 6,
    "Philippians": 4,
    "Colossians": 4,
    "1 Thessalonians": 5,
    "2 Thessalonians": 3,
    "1 Timothy": 6,
    "2 Timothy": 4,
    "Titus": 3,
    "Philemon": 1,
    "Hebrews": 13,
    "James": 5,
    "1 Peter": 5,
    "2 Peter": 3,
    "1 John": 5,
    "2 John": 1,
    "3 John": 1,
    "Jude": 1,
    "Revelation": 22,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color chipColor() => isDark ? Colors.grey[850]! : Colors.grey[300]!;
    Color chipTextColor() => theme.colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: const Text('References'),
        actions: const [
          Icon(Icons.sort_by_alpha),
          SizedBox(width: 12),
          Icon(Icons.history),
          SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          // Search bar (UI-only here)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: theme.hintColor),
                prefixIcon: Icon(Icons.search, color: theme.iconTheme.color),
                filled: true,
                fillColor: theme.inputDecorationTheme.fillColor ??
                    (isDark ? Colors.grey[900] : Colors.grey[200]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Books list
          Expanded(
            child: ListView.builder(
              itemCount: books.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (context, idx) {
                final entry = books.entries.elementAt(idx);
                final book = entry.key;
                final chapterCount = entry.value;
                final isOpen = expandedBook == book;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header row (book name + speaker + chevron)
                    InkWell(
                      onTap: () {
                        setState(() {
                          expandedBook = isOpen ? null : book;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            // horizontal: 16.0, vertical: 14.0
                            horizontal: 16, vertical: 12
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                book,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            // speaker icon
                            IconButton(
                              icon: Icon(Icons.volume_up,
                                  color: theme.iconTheme.color),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Play audio: $book')),
                                );
                              },
                            ),

                            // expand/collapse indicator
                            /*Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: Icon(
                                isOpen ? Icons.expand_less : Icons.expand_more,
                                color: theme.iconTheme.color,
                              ),
                            ),*/
                          ],
                        ),
                      ),
                    ),

                    // Animated drop-down of chapters
                    AnimatedSize(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      child: isOpen
                          ? Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children:
                              List.generate(chapterCount, (i) {
                                final chap = i + 1;
                                return InkWell(
                                  onTap: () {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                        content: Text(
                                            'Open $book $chap')));
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: 64,
                                    height: 64,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: chipColor(),
                                      borderRadius:
                                      BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '$chap',
                                      style: TextStyle(
                                        color: chipTextColor(),
                                        // fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      )
                          : const SizedBox.shrink(),
                    ),

                    // divider
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Divider(height: 1),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
