import 'package:equatable/equatable.dart';

enum BibleFormat { usfx, usfm, osis, auto }

enum BibleBookType { oldTestament, newTestament }

enum BibleSourceType { asset, download, import }

enum BibleVerseSpanKind {
  normal,
  wordsOfJesus,
  translatorAddition,
  quote,
  poetry,
  word,
}

enum BibleDocumentBlockKind {
  paragraph,
  preface,
  introduction,
  heading,
  tocLabel,
  poetry,
}

class BibleVerseSpan extends Equatable {
  final String text;
  final BibleVerseSpanKind kind;
  final Map<String, String> metadata;

  const BibleVerseSpan({
    required this.text,
    this.kind = BibleVerseSpanKind.normal,
    this.metadata = const {},
  });

  factory BibleVerseSpan.fromJson(Map<String, dynamic> json) {
    final rawMetadata = json['metadata'] as Map<String, dynamic>? ?? const {};
    return BibleVerseSpan(
      text: json['text'] as String,
      kind: BibleVerseSpanKind.values[json['kind'] as int? ?? 0],
      metadata: rawMetadata.map((key, value) => MapEntry(key, value.toString())),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'kind': kind.index,
      'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [text, kind, metadata];
}

class BibleCrossReference extends Equatable {
  final String label;
  final String? target;

  const BibleCrossReference({
    required this.label,
    this.target,
  });

  factory BibleCrossReference.fromJson(Map<String, dynamic> json) {
    return BibleCrossReference(
      label: json['label'] as String,
      target: json['target'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'target': target,
    };
  }

  @override
  List<Object?> get props => [label, target];
}

class BibleFootnote extends Equatable {
  final String text;
  final String? marker;
  final String? label;
  final List<BibleCrossReference> references;

  const BibleFootnote({
    required this.text,
    this.marker,
    this.label,
    this.references = const [],
  });

  factory BibleFootnote.fromJson(Map<String, dynamic> json) {
    return BibleFootnote(
      text: json['text'] as String,
      marker: json['marker'] as String?,
      label: json['label'] as String?,
      references: (json['references'] as List<dynamic>? ?? const [])
          .map((e) => BibleCrossReference.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'marker': marker,
      'label': label,
      'references': references.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [text, marker, label, references];
}

class BibleDocumentBlock extends Equatable {
  final BibleDocumentBlockKind kind;
  final String text;
  final int? level;
  final Map<String, String> metadata;

  const BibleDocumentBlock({
    required this.kind,
    required this.text,
    this.level,
    this.metadata = const {},
  });

  factory BibleDocumentBlock.fromJson(Map<String, dynamic> json) {
    final rawMetadata = json['metadata'] as Map<String, dynamic>? ?? const {};
    return BibleDocumentBlock(
      kind: BibleDocumentBlockKind.values[json['kind'] as int? ?? 0],
      text: json['text'] as String,
      level: json['level'] as int?,
      metadata: rawMetadata.map((key, value) => MapEntry(key, value.toString())),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kind': kind.index,
      'text': text,
      'level': level,
      'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [kind, text, level, metadata];
}

class BibleTocLabel extends Equatable {
  final String text;
  final int level;

  const BibleTocLabel({
    required this.text,
    required this.level,
  });

  factory BibleTocLabel.fromJson(Map<String, dynamic> json) {
    return BibleTocLabel(
      text: json['text'] as String,
      level: json['level'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'level': level,
    };
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
      id: json['id'],
      name: json['name'],
      shortName: json['shortName'],
      bookNumber: json['bookNumber'],
      chapters: (json['chapters'] as List)
          .map((e) => BibleChapter.fromJson(e))
          .toList(),
      bookType: BibleBookType.values[json['bookType'] ?? 0],
      tocLabels: (json['tocLabels'] as List<dynamic>? ?? const [])
          .map((e) => BibleTocLabel.fromJson(e as Map<String, dynamic>))
          .toList(),
      introductionBlocks: (json['introductionBlocks'] as List<dynamic>? ?? const [])
          .map((e) => BibleDocumentBlock.fromJson(e as Map<String, dynamic>))
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
      number: json['number'],
      verses:
          (json['verses'] as List).map((e) => BibleVerse.fromJson(e)).toList(),
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
      number: json['number'],
      text: json['text'],
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
  final BibleSourceType sourceType;

  const BibleTranslation({
    required this.id,
    required this.name,
    required this.language,
    required this.description,
    this.isLocal = false,
    this.filePath,
    this.githubUrl,
    this.format = BibleFormat.auto,
    this.sourceType = BibleSourceType.asset,
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
        format,
        sourceType,
      ];
}
