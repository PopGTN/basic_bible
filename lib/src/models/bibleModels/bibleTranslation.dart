import 'package:basic_bible/src/models/bibleModels/bibleBook.dart';
enum BibleFormat {
  usfm,
  usfx,
  osis,
  auto, // Auto-detect format
}

class BibleTranslation {
  final String id;
  final String name;
  final String language;
  final String description;
  final bool isLocal;
  final String? filePath;
  final String? githubUrl;
  final BibleFormat format;
  final String? copyright;
  final int? year;

  BibleTranslation({
    required this.id,
    required this.name,
    required this.language,
    required this.description,
    this.isLocal = false,
    this.filePath,
    this.githubUrl,
    this.format = BibleFormat.usfx,
    this.copyright,
    this.year,
  });
}


// Helper class for book-related utilities
