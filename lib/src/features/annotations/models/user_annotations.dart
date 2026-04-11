import 'package:basic_bible/src/models/bible_models.dart';
import 'package:equatable/equatable.dart';

enum UserAnnotationType { note, highlight }

class AnnotationVerseLink extends Equatable {
  const AnnotationVerseLink({
    this.id,
    required this.bookId,
    required this.chapter,
    required this.verse,
    required this.translationId,
    required this.translationName,
    this.sortOrder = 0,
  });

  final int? id;
  final String bookId;
  final int chapter;
  final int verse;
  final String translationId;
  final String translationName;
  final int sortOrder;

  BibleReference get reference =>
      BibleReference(bookId: bookId, chapter: chapter, verse: verse);

  AnnotationVerseLink copyWith({
    int? id,
    String? bookId,
    int? chapter,
    int? verse,
    String? translationId,
    String? translationName,
    int? sortOrder,
  }) {
    return AnnotationVerseLink(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      chapter: chapter ?? this.chapter,
      verse: verse ?? this.verse,
      translationId: translationId ?? this.translationId,
      translationName: translationName ?? this.translationName,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object?> get props => [
    id,
    bookId,
    chapter,
    verse,
    translationId,
    translationName,
    sortOrder,
  ];
}

class UserAnnotation extends Equatable {
  const UserAnnotation({
    this.id,
    required this.type,
    required this.primaryVerse,
    this.noteText,
    this.highlightColorValue,
    this.labels = const [],
    this.linkedVerses = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final UserAnnotationType type;
  final AnnotationVerseLink primaryVerse;
  final String? noteText;
  final int? highlightColorValue;
  final List<String> labels;
  final List<AnnotationVerseLink> linkedVerses;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get hasHighlight => highlightColorValue != null;

  bool get hasNoteText => noteText != null && noteText!.trim().isNotEmpty;

  bool get isHighlightOnly =>
      type == UserAnnotationType.highlight && !hasNoteText;

  List<AnnotationVerseLink> get allVerses => [primaryVerse, ...linkedVerses];

  bool touchesReference(BibleReference reference, {String? translationId}) {
    return allVerses.any(
      (link) =>
          link.bookId == reference.bookId &&
          link.chapter == reference.chapter &&
          link.verse == reference.verse &&
          (translationId == null || link.translationId == translationId),
    );
  }

  UserAnnotation copyWith({
    int? id,
    UserAnnotationType? type,
    AnnotationVerseLink? primaryVerse,
    String? noteText,
    bool clearNoteText = false,
    int? highlightColorValue,
    bool clearHighlightColor = false,
    List<String>? labels,
    List<AnnotationVerseLink>? linkedVerses,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserAnnotation(
      id: id ?? this.id,
      type: type ?? this.type,
      primaryVerse: primaryVerse ?? this.primaryVerse,
      noteText: clearNoteText ? null : (noteText ?? this.noteText),
      highlightColorValue: clearHighlightColor
          ? null
          : (highlightColorValue ?? this.highlightColorValue),
      labels: labels ?? this.labels,
      linkedVerses: linkedVerses ?? this.linkedVerses,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    primaryVerse,
    noteText,
    highlightColorValue,
    labels,
    linkedVerses,
    createdAt,
    updatedAt,
  ];
}

bool annotationVerseLinkMatchesReference(
  AnnotationVerseLink link,
  BibleReference reference, {
  String? translationId,
}) {
  return link.bookId == reference.bookId &&
      link.chapter == reference.chapter &&
      link.verse == reference.verse &&
      (translationId == null || link.translationId == translationId);
}

UserAnnotation? removeReferencesFromStandaloneHighlight(
  UserAnnotation annotation,
  Iterable<BibleReference> references, {
  required String translationId,
}) {
  if (!annotation.isHighlightOnly) return annotation;

  final remainingVerses = annotation.allVerses.where((link) {
    return !references.any(
      (reference) => annotationVerseLinkMatchesReference(
        link,
        reference,
        translationId: translationId,
      ),
    );
  }).toList();

  if (remainingVerses.isEmpty) return null;

  return annotation.copyWith(
    primaryVerse: remainingVerses.first.copyWith(sortOrder: 0),
    linkedVerses: [
      for (var i = 1; i < remainingVerses.length; i++)
        remainingVerses[i].copyWith(sortOrder: i - 1),
    ],
  );
}

class AnnotationEditorDraft extends Equatable {
  const AnnotationEditorDraft({
    required this.type,
    required this.primaryVerse,
    this.noteText = '',
    this.highlightColorValue,
    this.labels = const [],
    this.linkedVerses = const [],
    this.editingAnnotationId,
    this.createdAt,
  });

  final UserAnnotationType type;
  final AnnotationVerseLink primaryVerse;
  final String noteText;
  final int? highlightColorValue;
  final List<String> labels;
  final List<AnnotationVerseLink> linkedVerses;
  final int? editingAnnotationId;
  final DateTime? createdAt;

  List<AnnotationVerseLink> get allVerses => [primaryVerse, ...linkedVerses];

  bool get hasHighlight => highlightColorValue != null;

  bool get hasNoteText => noteText.trim().isNotEmpty;

  AnnotationEditorDraft copyWith({
    UserAnnotationType? type,
    AnnotationVerseLink? primaryVerse,
    String? noteText,
    int? highlightColorValue,
    bool clearHighlightColor = false,
    List<String>? labels,
    List<AnnotationVerseLink>? linkedVerses,
    int? editingAnnotationId,
    DateTime? createdAt,
  }) {
    return AnnotationEditorDraft(
      type: type ?? this.type,
      primaryVerse: primaryVerse ?? this.primaryVerse,
      noteText: noteText ?? this.noteText,
      highlightColorValue: clearHighlightColor
          ? null
          : (highlightColorValue ?? this.highlightColorValue),
      labels: labels ?? this.labels,
      linkedVerses: linkedVerses ?? this.linkedVerses,
      editingAnnotationId: editingAnnotationId ?? this.editingAnnotationId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory AnnotationEditorDraft.fromAnnotation(UserAnnotation annotation) {
    return AnnotationEditorDraft(
      type: annotation.type,
      primaryVerse: annotation.primaryVerse,
      noteText: annotation.noteText ?? '',
      highlightColorValue: annotation.highlightColorValue,
      labels: annotation.labels,
      linkedVerses: annotation.linkedVerses,
      editingAnnotationId: annotation.id,
      createdAt: annotation.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    type,
    primaryVerse,
    noteText,
    highlightColorValue,
    labels,
    linkedVerses,
    editingAnnotationId,
    createdAt,
  ];
}
