/*
// lib/src/models/bible_models.dart
class BibleBook {
  final String id;
  final String name;
  final String shortName;
  final int bookNumber;
  final List<BibleChapter> chapters;

  BibleBook({
    required this.id,
    required this.name,
    required this.shortName,
    required this.bookNumber,
    this.chapters = const [],
  });

  BibleBook copyWith({
    String? id,
    String? name,
    String? shortName,
    int? bookNumber,
    List<BibleChapter>? chapters,
  }) {
    return BibleBook(
      id: id ?? this.id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      bookNumber: bookNumber ?? this.bookNumber,
      chapters: chapters ?? this.chapters,
    );
  }
}

class BibleChapter {
  final int number;
  final List<BibleVerse> verses;

  BibleChapter({
    required this.number,
    this.verses = const [],
  });

  BibleChapter copyWith({
    int? number,
    List<BibleVerse>? verses,
  }) {
    return BibleChapter(
      number: number ?? this.number,
      verses: verses ?? this.verses,
    );
  }
}

class BibleVerse {
  final int number;
  final String text;
  final List<BibleNote>? notes;

  BibleVerse({
    required this.number,
    required this.text,
    this.notes,
  });

  BibleVerse copyWith({
    int? number,
    String? text,
    List<BibleNote>? notes,
  }) {
    return BibleVerse(
      number: number ?? this.number,
      text: text ?? this.text,
      notes: notes ?? this.notes,
    );
  }
}

class BibleNote {
  final String id;
  final String text;
  final String type; // 'f' for footnote, 'x' for cross-reference, etc.

  BibleNote({
    required this.id,
    required this.text,
    required this.type,
  });
}

class BibleReference {
  final String bookId;
  final int chapter;
  final int? verse;

  BibleReference({
    required this.bookId,
    required this.chapter,
    this.verse,
  });

  @override
  String toString() {
    if (verse != null) {
      return '$bookId $chapter:$verse';
    }
    return '$bookId $chapter';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BibleReference &&
        other.bookId == bookId &&
        other.chapter == chapter &&
        other.verse == verse;
  }

  @override
  int get hashCode => bookId.hashCode ^ chapter.hashCode ^ verse.hashCode;
}

class BibleTranslation {
  final String id;
  final String name;
  final String language;
  final String description;
  final bool isLocal;
  final String? filePath;
  final String? githubUrl;

  BibleTranslation({
    required this.id,
    required this.name,
    required this.language,
    required this.description,
    this.isLocal = false,
    this.filePath,
    this.githubUrl,
  });
}
*/
