import 'package:equatable/equatable.dart';

class BibleCrossReference extends Equatable {
  final String label;
  final String? target;
  final String? marker;
  final String? originRef;
  final int? spanIndex;
  final int? charOffset;

  const BibleCrossReference({
    required this.label,
    this.target,
    this.marker,
    this.originRef,
    this.spanIndex,
    this.charOffset,
  });

  factory BibleCrossReference.fromJson(Map<String, dynamic> json) {
    return BibleCrossReference(
      label: json['label'] as String,
      target: json['target'] as String?,
      marker: json['marker'] as String?,
      originRef: json['originRef'] as String?,
      spanIndex: json['spanIndex'] as int?,
      charOffset: json['charOffset'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'target': target,
      'marker': marker,
      'originRef': originRef,
      'spanIndex': spanIndex,
      'charOffset': charOffset,
    };
  }

  @override
  List<Object?> get props =>
      [label, target, marker, originRef, spanIndex, charOffset];
}
