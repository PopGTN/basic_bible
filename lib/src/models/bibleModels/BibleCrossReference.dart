import 'package:basic_bible/src/models/bibleModels/bibleReference.dart';

class BibleCrossReference {
  final String reference;
  final String? text;
  final BibleReference? parsedReference;

  BibleCrossReference({
    required this.reference,
    this.text,
    this.parsedReference,
  });
}