import 'package:equatable/equatable.dart';

import 'cross_reference.dart';

class BibleFootnote extends Equatable {
  final String text;
  final String? marker;
  final String? label;
  final String? bodyText;
  final String? quotedText;
  final List<BibleCrossReference> references;
  final int? spanIndex;
  final int? charOffset;

  const BibleFootnote({
    required this.text,
    this.marker,
    this.label,
    this.bodyText,
    this.quotedText,
    this.references = const [],
    this.spanIndex,
    this.charOffset,
  });

  factory BibleFootnote.fromJson(Map<String, dynamic> json) {
    return BibleFootnote(
      text: json['text'] as String,
      marker: json['marker'] as String?,
      label: json['label'] as String?,
      bodyText: json['bodyText'] as String?,
      quotedText: json['quotedText'] as String?,
      references: (json['references'] as List<dynamic>? ?? const [])
          .map((e) => BibleCrossReference.fromJson(e as Map<String, dynamic>))
          .toList(),
      spanIndex: json['spanIndex'] as int?,
      charOffset: json['charOffset'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'marker': marker,
      'label': label,
      'bodyText': bodyText,
      'quotedText': quotedText,
      'references': references.map((e) => e.toJson()).toList(),
      'spanIndex': spanIndex,
      'charOffset': charOffset,
    };
  }

  @override
  List<Object?> get props =>
      [text, marker, label, bodyText, quotedText, references, spanIndex, charOffset];
}
