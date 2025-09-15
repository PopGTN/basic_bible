enum BibleNoteType {
  footnote,
  crossReference,
  studyNote,
  textualNote,
  translationNote,
}

class BibleNote {
  final String id;
  final String text;
  final BibleNoteType type;
  final String? caller; // The symbol or number used to reference the note

  BibleNote({
    required this.id,
    required this.text,
    required this.type,
    this.caller,
  });
}

