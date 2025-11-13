import 'package:equatable/equatable.dart';

enum BibleFormat { usfx, usfm, osis, auto }

enum BibleBookType { oldTestament, newTestament }

class BibleBook extends Equatable {
  final String id;
  final String name;
  final String shortName;
  final int bookNumber;
  final List<BibleChapter> chapters;
  final BibleBookType bookType;

  const BibleBook({
    required this.id,
    required this.name,
    required this.shortName,
    required this.bookNumber,
    this.chapters = const [],
    this.bookType = BibleBookType.oldTestament,
  });

  BibleBook copyWith({
    String? id,
    String? name,
    String? shortName,
    int? bookNumber,
    List<BibleChapter>? chapters,
    BibleBookType? bookType,
  }) {
    return BibleBook(
      id: id ?? this.id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      bookNumber: bookNumber ?? this.bookNumber,
      chapters: chapters ?? this.chapters,
      bookType: bookType ?? this.bookType,
    );
  }

  factory BibleBook.fromJson(Map<String, dynamic> json) {
    return BibleBook(
      id: json['id'],
      name: json['name'],
      shortName: json['shortName'],
      bookNumber: json['bookNumber'],
      chapters: (json['chapters'] as List)
          .map((e) => BibleChapter.fromJson(e))
          .toList(),
      bookType: BibleBookType.values[json['bookType'] ?? 0],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'shortName': shortName,
      'bookNumber': bookNumber,
      'chapters': chapters.map((e) => e.toJson()).toList(),
      'bookType': bookType.index,
    };
  }

  @override
  List<Object?> get props => [id, name, shortName, bookNumber, chapters, bookType];
}

class BibleChapter extends Equatable {
  final int number;
  final List<BibleVerse> verses;

  const BibleChapter({
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

  factory BibleChapter.fromJson(Map<String, dynamic> json) {
    return BibleChapter(
      number: json['number'],
      verses:
          (json['verses'] as List).map((e) => BibleVerse.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'verses': verses.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [number, verses];
}

class BibleVerse extends Equatable {
  final int number;
  final String text;
  final List<String>? notes;
  final List<String>? references;

  const BibleVerse({
    required this.number,
    required this.text,
    this.notes,
    this.references,
  });

  BibleVerse copyWith({
    int? number,
    String? text,
    List<String>? notes,
    List<String>? references,
  }) {
    return BibleVerse(
      number: number ?? this.number,
      text: text ?? this.text,
      notes: notes ?? this.notes,
      references: references ?? this.references,
    );
  }

  factory BibleVerse.fromJson(Map<String, dynamic> json) {
    return BibleVerse(
      number: json['number'],
      text: json['text'],
      notes: (json['notes'] as List?)?.cast<String>(),
      references: (json['references'] as List?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'text': text,
      'notes': notes,
      'references': references,
    };
  }

  @override
  List<Object?> get props => [number, text, notes, references];
}

class BibleReference extends Equatable {
  final String bookId;
  final int chapter;
  final int? verse;

  const BibleReference({
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
  List<Object?> get props => [bookId, chapter, verse];
}

class BibleTranslation extends Equatable {
  final String id;
  final String name;
  final String language;
  final String description;
  final bool isLocal;
  final String? filePath;
  final String? githubUrl;
  final BibleFormat format;

  const BibleTranslation({
    required this.id,
    required this.name,
    required this.language,
    required this.description,
    this.isLocal = false,
    this.filePath,
    this.githubUrl,
    this.format = BibleFormat.auto,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        language,
        description,
        isLocal,
        filePath,
        githubUrl,
        format
      ];
}
