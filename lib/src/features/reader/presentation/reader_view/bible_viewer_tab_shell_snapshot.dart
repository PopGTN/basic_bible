part of 'bible_viewer_tab.dart';

class _ReaderShellStateSnapshot {
  const _ReaderShellStateSnapshot({
    required this.layoutMode,
    required this.continuousScrolling,
    required this.shellBooksAsync,
    required this.currentReference,
    required this.chapterAsync,
    required this.showBookIntroductions,
    required this.showVerseSelector,
    required this.selectedVerses,
    required this.selectedVerse,
    required this.showHighlightPalette,
    required this.selectedVerseAnnotations,
  });

  final ReaderLayoutMode layoutMode;
  final bool continuousScrolling;
  /// Shell books (metadata only, no verses) — always loads quickly.
  /// Used for both the reference bar/picker and content rendering.
  /// Verse data is loaded lazily per-chapter inside [_BibleTextViewState].
  final AsyncValue<List<BibleBook>> shellBooksAsync;
  final BibleReference currentReference;
  final AsyncValue<BibleChapter?> chapterAsync;
  final bool showBookIntroductions;
  final bool showVerseSelector;
  final List<BibleReference> selectedVerses;
  final BibleReference? selectedVerse;
  final bool showHighlightPalette;
  final List<UserAnnotation> selectedVerseAnnotations;
}
