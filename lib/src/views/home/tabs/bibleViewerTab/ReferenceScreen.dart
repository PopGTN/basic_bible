import 'package:flutter/material.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:basic_bible/src/providers/bible_provider.dart';

class ReferenceScreen extends ConsumerStatefulWidget {
  final List<String> references;
  final BibleReference currentReference;

  const ReferenceScreen({
    super.key,
    required this.references,
    required this.currentReference,
  });

  @override
  ConsumerState<ReferenceScreen> createState() => _ReferenceScreenState();
}

class _ReferenceScreenState extends ConsumerState<ReferenceScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cross-References'),
      ),
      body: widget.references.isEmpty
          ? Center(
              child: Text(
                'No cross-references available for this verse.',
                style: theme.textTheme.bodyLarge,
              ),
            )
          : ListView.builder(
              itemCount: widget.references.length,
              itemBuilder: (context, index) {
                final refString = widget.references[index];
                return ListTile(
                  title: Text(refString),
                  onTap: () {
                    // Parse the reference string (e.g., "John 3:16") into a BibleReference
                    final parsedRef = _parseReferenceString(refString);
                    if (parsedRef != null) {
                      ref.read(currentReferenceProvider.notifier).setReference(parsedRef);
                      Navigator.of(context).pop(); // Go back to BibleViewerTab
                    } else {
                      // Optionally show an error or a snackbar if parsing fails
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Could not parse reference: $refString')),
                      );
                    }
                  },
                );
              },
            ),
    );
  }

  // Helper function to parse a reference string (e.g., "John 3:16")
  BibleReference? _parseReferenceString(String refString) {
    final parts = refString.split(' ');
    if (parts.length < 2) return null;

    String bookId = parts[0]; // e.g., "John"
    int? chapter;
    int? verse;

    // Handle multi-word book names (e.g., "1 John")
    if (parts.length > 2 && (parts[0].startsWith('1') || parts[0].startsWith('2') || parts[0].startsWith('3'))) {
      bookId = '${parts[0]} ${parts[1]}';
      final chapterVerse = parts[2].split(':');
      chapter = int.tryParse(chapterVerse[0]);
      if (chapterVerse.length > 1) {
        verse = int.tryParse(chapterVerse[1]);
      }
    } else {
      final chapterVerse = parts[1].split(':');
      chapter = int.tryParse(chapterVerse[0]);
      if (chapterVerse.length > 1) {
        verse = int.tryParse(chapterVerse[1]);
      }
    }

    // Map common book names to their IDs (e.g., "John" -> "JHN")
    final mappedBookId = _mapBookNameToId(bookId);

    if (mappedBookId != null && chapter != null) {
      return BibleReference(bookId: mappedBookId, chapter: chapter, verse: verse);
    }
    return null;
  }

  String? _mapBookNameToId(String bookName) {
    // This map should ideally come from a shared utility or the BibleBooksProvider
    // For now, a simplified version:
    const bookNameToIdMap = {
      'Genesis': 'GEN', 'Exodus': 'EXO', 'Leviticus': 'LEV', 'Numbers': 'NUM', 'Deuteronomy': 'DEU',
      'Joshua': 'JOS', 'Judges': 'JDG', 'Ruth': 'RUT', '1 Samuel': '1SA', '2 Samuel': '2SA',
      '1 Kings': '1KI', '2 Kings': '2KI', '1 Chronicles': '1CH', '2 Chronicles': '2CH',
      'Ezra': 'EZR', 'Nehemiah': 'NEH', 'Esther': 'EST', 'Job': 'JOB', 'Psalms': 'PSA',
      'Proverbs': 'PRO', 'Ecclesiastes': 'ECC', 'Song of Solomon': 'SNG', 'Isaiah': 'ISA',
      'Jeremiah': 'JER', 'Lamentations': 'LAM', 'Ezekiel': 'EZK', 'Daniel': 'DAN',
      'Hosea': 'HOS', 'Joel': 'JOL', 'Amos': 'AMO', 'Obadiah': 'OBA', 'Jonah': 'JON',
      'Micah': 'MIC', 'Nahum': 'NAM', 'Habakkuk': 'HAB', 'Zephaniah': 'ZEP', 'Haggai': 'HAG',
      'Zechariah': 'ZEC', 'Malachi': 'MAL', 'Matthew': 'MAT', 'Mark': 'MRK', 'Luke': 'LUK',
      'John': 'JHN', 'Acts': 'ACT', 'Romans': 'ROM', '1 Corinthians': '1CO', '2 Corinthians': '2CO',
      'Galatians': 'GAL', 'Ephesians': 'EPH', 'Philippians': 'PHP', 'Colossians': 'COL',
      '1 Thessalonians': '1TH', '2 Thessalonians': '2TH', '1 Timothy': '1TI', '2 Timothy': '2TI',
      'Titus': 'TIT', 'Philemon': 'PHM', 'Hebrews': 'HEB', 'James': 'JAS', '1 Peter': '1PE',
      '2 Peter': '2PE', '1 John': '1JN', '2 John': '2JN', '3 John': '3JN', 'Jude': 'JUD',
      'Revelation': 'REV',
    };
    return bookNameToIdMap[bookName];
  }
}
