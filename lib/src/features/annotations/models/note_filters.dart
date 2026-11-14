import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';

/// Which timestamp the Notes date filter and sort use (#39).
enum NoteDateField {
  modified('Last modified'),
  created('Created');

  const NoteDateField(this.label);
  final String label;

  DateTime of(UserAnnotation annotation) => switch (this) {
    NoteDateField.modified => annotation.updatedAt,
    NoteDateField.created => annotation.createdAt,
  };
}

/// How far back the Notes date filter reaches.
enum NoteDateRange {
  any('Any time'),
  today('Today'),
  pastWeek('Past week'),
  pastMonth('Past month'),
  pastYear('Past year');

  const NoteDateRange(this.label);
  final String label;

  /// Earliest moment included, or null for [any]. "Today" starts at local
  /// midnight; the others are rolling windows ending [now].
  DateTime? since(DateTime now) => switch (this) {
    NoteDateRange.any => null,
    NoteDateRange.today => DateTime(now.year, now.month, now.day),
    NoteDateRange.pastWeek => now.subtract(const Duration(days: 7)),
    NoteDateRange.pastMonth => now.subtract(const Duration(days: 30)),
    NoteDateRange.pastYear => now.subtract(const Duration(days: 365)),
  };
}

/// Note type filter values. A note can be both (note text + highlight).
enum NoteTypeFilter {
  note('Note'),
  highlight('Highlight only');

  const NoteTypeFilter(this.label);
  final String label;

  bool matches(UserAnnotation annotation) => switch (this) {
    // Any annotation with note text, with or without a highlight colour.
    // (Previously only notes that *also* had a highlight matched "Note".)
    NoteTypeFilter.note => annotation.hasNoteText,
    NoteTypeFilter.highlight => annotation.hasHighlight && !annotation.hasNoteText,
  };
}

bool matchesNoteTypes(UserAnnotation annotation, Set<NoteTypeFilter> types) =>
    types.isEmpty || types.any((type) => type.matches(annotation));

bool matchesNoteDateRange(
  UserAnnotation annotation, {
  required NoteDateField field,
  required NoteDateRange range,
  required DateTime now,
}) {
  final since = range.since(now);
  return since == null || !field.of(annotation).isBefore(since);
}

/// Newest first by [field]; ties keep their incoming order.
List<UserAnnotation> sortNotesByDate(
  List<UserAnnotation> annotations,
  NoteDateField field,
) {
  final indexed = annotations.indexed.toList()
    ..sort((a, b) {
      final byDate = field.of(b.$2).compareTo(field.of(a.$2));
      return byDate != 0 ? byDate : a.$1.compareTo(b.$1);
    });
  return [for (final (_, annotation) in indexed) annotation];
}
