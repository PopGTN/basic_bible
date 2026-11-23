import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:basic_bible/src/features/annotations/models/note_filters.dart';
import 'package:basic_bible/src/features/reader/application/view_models/bible_search_view_models.dart';

// Display names for filter/scope enums in the app's current language. The
// enums' own `label` stays as the English name for logs and tests.

extension NoteDateFieldL10n on NoteDateField {
  String localizedLabel(AppLocalizations t) => switch (this) {
    NoteDateField.modified => t.noteDateFieldModified,
    NoteDateField.created => t.noteDateFieldCreated,
  };
}

extension NoteDateRangeL10n on NoteDateRange {
  String localizedLabel(AppLocalizations t) => switch (this) {
    NoteDateRange.any => t.noteDateRangeAny,
    NoteDateRange.today => t.noteDateRangeToday,
    NoteDateRange.pastWeek => t.noteDateRangePastWeek,
    NoteDateRange.pastMonth => t.noteDateRangePastMonth,
    NoteDateRange.pastYear => t.noteDateRangePastYear,
  };
}

extension NoteTypeFilterL10n on NoteTypeFilter {
  String localizedLabel(AppLocalizations t) => switch (this) {
    NoteTypeFilter.note => t.noteTypeNote,
    NoteTypeFilter.highlight => t.noteTypeHighlightOnly,
  };
}

extension BibleSearchScopeL10n on BibleSearchScope {
  String localizedLabel(AppLocalizations t) => switch (this) {
    BibleSearchScope.all => t.searchScopeAll,
    BibleSearchScope.oldTestament => t.searchScopeOldTestament,
    BibleSearchScope.newTestament => t.searchScopeNewTestament,
    BibleSearchScope.currentBook => t.searchScopeCurrentBook,
    BibleSearchScope.currentChapter => t.searchScopeCurrentChapter,
  };
}
