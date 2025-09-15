import 'package:basic_bible/src/models/bibleModels/bibleSection.dart';
import 'package:basic_bible/src/models/bibleModels/bibleVersus.dart';

class BibleChapter {
  final int number;
  final List<BibleVerse> verses;
  final String? title;
  final List<BibleSection>? sections;

  BibleChapter({
    required this.number,
    this.verses = const [],
    this.title,
    this.sections,
  });

  BibleChapter copyWith({
    int? number,
    List<BibleVerse>? verses,
    String? title,
    List<BibleSection>? sections,
  }) {
    return BibleChapter(
      number: number ?? this.number,
      verses: verses ?? this.verses,
      title: title ?? this.title,
      sections: sections ?? this.sections,
    );
  }
}