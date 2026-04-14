import 'package:equatable/equatable.dart';

enum BibleDocumentBlockKind {
  paragraph,
  preface,
  introduction,
  heading,
  tocLabel,
  poetry,
  table,
  tableRow,
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
      metadata: rawMetadata.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
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
