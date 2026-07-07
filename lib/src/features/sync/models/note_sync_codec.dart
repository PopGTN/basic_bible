import 'dart:convert';

import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';

/// Wire format for one synced note, shared by Drive App Data files and the
/// notes export/import path. Local autoincrement ids never appear here —
/// notes are identified by uuid only, so the same note keeps its identity
/// across devices.
///
/// Bump [noteSyncSchemaVersion] when the shape changes; readers must keep
/// accepting older versions.
const int noteSyncSchemaVersion = 1;

Map<String, dynamic> _verseLinkToJson(AnnotationVerseLink link) => {
  'bookId': link.bookId,
  'chapter': link.chapter,
  'verse': link.verse,
  'translationId': link.translationId,
  'translationName': link.translationName,
};

AnnotationVerseLink _verseLinkFromJson(Map<String, dynamic> json, int order) {
  return AnnotationVerseLink(
    bookId: json['bookId'] as String,
    chapter: json['chapter'] as int,
    verse: json['verse'] as int,
    translationId: json['translationId'] as String,
    translationName: json['translationName'] as String,
    sortOrder: order,
  );
}

/// Serializes [annotation] to the sync wire shape. Requires a non-null uuid.
/// Key order is fixed so the encoded string doubles as a canonical form for
/// content comparison in the merge engine.
Map<String, dynamic> annotationToSyncJson(UserAnnotation annotation) {
  final uuid = annotation.uuid;
  if (uuid == null) {
    throw ArgumentError('cannot serialize an annotation without a uuid');
  }
  return {
    'schema': noteSyncSchemaVersion,
    'uuid': uuid,
    'type': annotation.type.name,
    'noteText': annotation.hasNoteText ? annotation.noteText!.trim() : null,
    'highlightColorValue': annotation.highlightColorValue,
    'labels': annotation.labels,
    'primaryVerse': _verseLinkToJson(annotation.primaryVerse),
    'linkedVerses': [
      for (final link in annotation.linkedVerses) _verseLinkToJson(link),
    ],
    'createdAt': annotation.createdAt.toUtc().millisecondsSinceEpoch,
    'updatedAt': annotation.updatedAt.toUtc().millisecondsSinceEpoch,
    'deletedAt': annotation.deletedAt?.toUtc().millisecondsSinceEpoch,
  };
}

String annotationToSyncJsonString(UserAnnotation annotation) =>
    jsonEncode(annotationToSyncJson(annotation));

DateTime _dateFromMillis(int millis) =>
    DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true).toLocal();

/// Parses the sync wire shape back into a [UserAnnotation] (local [id] is
/// null; the database upsert resolves it by uuid).
UserAnnotation annotationFromSyncJson(Map<String, dynamic> json) {
  final linkedVerses = (json['linkedVerses'] as List<dynamic>? ?? const [])
      .cast<Map<String, dynamic>>();
  final deletedAtMillis = json['deletedAt'] as int?;
  return UserAnnotation(
    uuid: json['uuid'] as String,
    type: UserAnnotationType.values.asNameMap()[json['type'] as String?] ??
        UserAnnotationType.note,
    primaryVerse: _verseLinkFromJson(
      json['primaryVerse'] as Map<String, dynamic>,
      0,
    ),
    noteText: json['noteText'] as String?,
    highlightColorValue: json['highlightColorValue'] as int?,
    labels: (json['labels'] as List<dynamic>? ?? const [])
        .map((label) => label.toString())
        .toList(),
    linkedVerses: [
      for (var i = 0; i < linkedVerses.length; i++)
        _verseLinkFromJson(linkedVerses[i], i),
    ],
    createdAt: _dateFromMillis(json['createdAt'] as int),
    updatedAt: _dateFromMillis(json['updatedAt'] as int),
    deletedAt: deletedAtMillis == null ? null : _dateFromMillis(deletedAtMillis),
  );
}

UserAnnotation annotationFromSyncJsonString(String json) =>
    annotationFromSyncJson(jsonDecode(json) as Map<String, dynamic>);
