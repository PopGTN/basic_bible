import 'package:equatable/equatable.dart';

import 'bible_translation.dart';
import 'cross_reference.dart';
import 'document_block.dart';
import 'footnote.dart';
import 'verse_span.dart';

enum BibleBookType { oldTestament, newTestament }

class BibleTocLabel extends Equatable {
  final String text;
  final int level;

  const BibleTocLabel({required this.text, required this.level});

  factory BibleTocLabel.fromJson(Map<String, dynamic> json) {
    return BibleTocLabel(
      text: json['text'] as String,
      level: json['level'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'text': text, 'level': level};
  }

  @override
  List<Object?> get props => [text, level];
}

class BibleDocument extends Equatable {
  final BibleTranslation translation;
  final List<BibleDocumentBlock> introductionBlocks;
  final List<BibleBook> books;

  const BibleDocument({
    required this.translation,
    this.introductionBlocks = const [],
    this.books = const [],
  });

  @override
  List<Object?> get props => [translation, introductionBlocks, books];
}

class BibleBook extends Equatable {
  final String id;
  final String name;
  final String shortName;
  final int bookNumber;
  final List<BibleChapter> chapters;
  final BibleBookType bookType;
  final List<BibleTocLabel> tocLabels;
  final List<BibleDocumentBlock> introductionBlocks;

  const BibleBook({
    required this.id,
    required this.name,
    required this.shortName,
    required this.bookNumber,
    this.chapters = const [],
    this.bookType = BibleBookType.oldTestament,
    this.tocLabels = const [],
    this.introductionBlocks = const [],
  });

  BibleBook copyWith({
    String? id,
    String? name,
    String? shortName,
    int? bookNumber,
    List<BibleChapter>? chapters,
    BibleBookType? bookType,
    List<BibleTocLabel>? tocLabels,
    List<BibleDocumentBlock>? introductionBlocks,
  }) {
    return BibleBook(
      id: id ?? this.id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      bookNumber: bookNumber ?? this.bookNumber,
      chapters: chapters ?? this.chapters,
      bookType: bookType ?? this.bookType,
      tocLabels: tocLabels ?? this.tocLabels,
      introductionBlocks: introductionBlocks ?? this.introductionBlocks,
    );
  }

  factory BibleBook.fromJson(Map<String, dynamic> json) {
    return BibleBook(
      id: json['id'] as String,
      name: json['name'] as String,
      shortName: json['shortName'] as String,
      bookNumber: json['bookNumber'] as int,
      chapters: (json['chapters'] as List)
          .map((e) => BibleChapter.fromJson(e as Map<String, dynamic>))
          .toList(),
      bookType: BibleBookType.values[json['bookType'] as int? ?? 0],
      tocLabels: (json['tocLabels'] as List<dynamic>? ?? const [])
          .map((e) => BibleTocLabel.fromJson(e as Map<String, dynamic>))
          .toList(),
      introductionBlocks:
          (json['introductionBlocks'] as List<dynamic>? ?? const [])
              .map(
                (e) => BibleDocumentBlock.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
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
      'tocLabels': tocLabels.map((e) => e.toJson()).toList(),
      'introductionBlocks': introductionBlocks.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    shortName,
    bookNumber,
    chapters,
    bookType,
    tocLabels,
    introductionBlocks,
  ];
}

class BibleChapter extends Equatable {
  final int number;
  final List<BibleVerse> verses;
  final List<BibleDocumentBlock> blocks;

  const BibleChapter({
    required this.number,
    this.verses = const [],
    this.blocks = const [],
  });

  BibleChapter copyWith({
    int? number,
    List<BibleVerse>? verses,
    List<BibleDocumentBlock>? blocks,
  }) {
    return BibleChapter(
      number: number ?? this.number,
      verses: verses ?? this.verses,
      blocks: blocks ?? this.blocks,
    );
  }

  factory BibleChapter.fromJson(Map<String, dynamic> json) {
    return BibleChapter(
      number: json['number'] as int,
      verses: (json['verses'] as List)
          .map((e) => BibleVerse.fromJson(e as Map<String, dynamic>))
          .toList(),
      blocks: (json['blocks'] as List<dynamic>? ?? const [])
          .map((e) => BibleDocumentBlock.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'verses': verses.map((e) => e.toJson()).toList(),
      'blocks': blocks.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [number, verses, blocks];
}

class BibleVerse extends Equatable {
  final int number;
  final String text;
  final List<String>? notes;
  final List<String>? references;
  final List<BibleVerseSpan> spans;
  final List<BibleFootnote> footnotes;
  final List<BibleCrossReference> crossReferences;

  const BibleVerse({
    required this.number,
    required this.text,
    this.notes,
    this.references,
    this.spans = const [],
    this.footnotes = const [],
    this.crossReferences = const [],
  });

  BibleVerse copyWith({
    int? number,
    String? text,
    List<String>? notes,
    List<String>? references,
    List<BibleVerseSpan>? spans,
    List<BibleFootnote>? footnotes,
    List<BibleCrossReference>? crossReferences,
  }) {
    return BibleVerse(
      number: number ?? this.number,
      text: text ?? this.text,
      notes: notes ?? this.notes,
      references: references ?? this.references,
      spans: spans ?? this.spans,
      footnotes: footnotes ?? this.footnotes,
      crossReferences: crossReferences ?? this.crossReferences,
    );
  }

  factory BibleVerse.fromJson(Map<String, dynamic> json) {
    return BibleVerse(
      number: json['number'] as int,
      text: json['text'] as String,
      notes: (json['notes'] as List?)?.cast<String>(),
      references: (json['references'] as List?)?.cast<String>(),
      spans: (json['spans'] as List<dynamic>? ?? const [])
          .map((e) => BibleVerseSpan.fromJson(e as Map<String, dynamic>))
          .toList(),
      footnotes: (json['footnotes'] as List<dynamic>? ?? const [])
          .map((e) => BibleFootnote.fromJson(e as Map<String, dynamic>))
          .toList(),
      crossReferences: (json['crossReferences'] as List<dynamic>? ?? const [])
          .map((e) => BibleCrossReference.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'text': text,
      'notes': notes,
      'references': references,
      'spans': spans.map((e) => e.toJson()).toList(),
      'footnotes': footnotes.map((e) => e.toJson()).toList(),
      'crossReferences': crossReferences.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    number,
    text,
    notes,
    references,
    spans,
    footnotes,
    crossReferences,
  ];
}
