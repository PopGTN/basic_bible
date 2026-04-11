import 'package:equatable/equatable.dart';

enum BibleVerseSpanKind {
  normal,
  wordsOfJesus,
  translatorAddition,
  quote,
  poetry,
  word,
  divineNameTag,
  properName,
  selah,
  acrosticHeading,
  emphasis,
  bold,
  italic,
  foreignLanguage,
  keyword,
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
      metadata: rawMetadata.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'text': text, 'kind': kind.index, 'metadata': metadata};
  }

  @override
  List<Object?> get props => [text, kind, metadata];
}
