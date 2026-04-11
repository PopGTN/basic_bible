import 'package:equatable/equatable.dart';

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
