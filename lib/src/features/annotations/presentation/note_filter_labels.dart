import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:basic_bible/src/features/annotations/models/note_filters.dart';

/// Localized names for the note filter enums (their `label` fields stay as
/// English fallbacks).
extension NoteTypeFilterLabels on NoteTypeFilter {
  String localized(AppLocalizations t) => switch (this) {
    NoteTypeFilter.note => t.noteTypeNote,
    NoteTypeFilter.highlight => t.noteTypeHighlightOnly,
  };
}

extension NoteDateFieldLabels on NoteDateField {
  String localized(AppLocalizations t) => switch (this) {
    NoteDateField.modified => t.dateLastModified,
    NoteDateField.created => t.dateCreated,
  };
}

extension NoteDateRangeLabels on NoteDateRange {
  String localized(AppLocalizations t) => switch (this) {
    NoteDateRange.any => t.dateAnyTime,
    NoteDateRange.today => t.dateToday,
    NoteDateRange.pastWeek => t.datePastWeek,
    NoteDateRange.pastMonth => t.datePastMonth,
    NoteDateRange.pastYear => t.datePastYear,
  };
}
