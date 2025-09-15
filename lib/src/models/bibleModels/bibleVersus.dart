import 'package:basic_bible/src/models/bibleModels/BibleCrossReference.dart';

import 'bibleNote.dart';

class BibleVerse {
  final int number;
  final String text;
  final List<BibleNote>? notes;
  final List<BibleCrossReference>? crossReferences;
  final BibleVerseStyle? style;

  BibleVerse({
    required this.number,
    required this.text,
    this.notes,
    this.crossReferences,
    this.style,
  });

  BibleVerse copyWith({
    int? number,
    String? text,
    List<BibleNote>? notes,
    List<BibleCrossReference>? crossReferences,
    BibleVerseStyle? style,
  }) {
    return BibleVerse(
      number: number ?? this.number,
      text: text ?? this.text,
      notes: notes ?? this.notes,
      crossReferences: crossReferences ?? this.crossReferences,
      style: style ?? this.style,
    );
  }
}

class BibleVerseStyle {
  final bool isPoetry;
  final bool isIndented;
  final bool isWordsOfJesus;
  final int indentLevel;

  BibleVerseStyle({
    this.isPoetry = false,
    this.isIndented = false,
    this.isWordsOfJesus = false,
    this.indentLevel = 0,
  });
}