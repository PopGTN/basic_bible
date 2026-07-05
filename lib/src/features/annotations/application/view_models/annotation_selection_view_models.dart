import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';
import 'package:basic_bible/src/features/annotations/application/view_models/annotation_data_view_models.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class SelectedVersesNotifier extends StateNotifier<List<BibleReference>> {
  SelectedVersesNotifier() : super(const []);

  void clear() => state = const [];

  void setSingle(BibleReference reference) => state = [reference];

  void replaceAll(List<BibleReference> references) => state = references;

  void toggle(BibleReference reference) {
    final index = state.indexWhere(
      (item) =>
          item.bookId == reference.bookId &&
          item.chapter == reference.chapter &&
          item.verse == reference.verse,
    );

    if (index >= 0) {
      final next = [...state]..removeAt(index);
      state = next;
      return;
    }

    state = [...state, reference];
  }
}

final selectedVersesProvider =
    StateNotifierProvider.autoDispose<
      SelectedVersesNotifier,
      List<BibleReference>
    >((ref) => SelectedVersesNotifier());

final selectedVerseProvider = Provider.autoDispose<BibleReference?>((ref) {
  final selected = ref.watch(selectedVersesProvider);
  if (selected.isEmpty) return null;
  return selected.first;
});

final highlightPaletteExpandedProvider = StateProvider.autoDispose<bool>(
  (ref) => false,
);

/// Advanced Mode > Partial Highlights: the in-progress drag selection for a
/// single verse, live-updated while the user holds and drags across the
/// verse's text. Null when no drag is in progress. Reader UI (span coloring)
/// watches this for a live preview; committing on release goes through the
/// same selection+palette flow as a whole-verse highlight (see
/// _handleHighlightColorSelected), which reads this to know it should save a
/// partial range instead of a whole-verse highlight.
class PartialHighlightDraft extends Equatable {
  const PartialHighlightDraft({
    required this.bookId,
    required this.chapterNumber,
    required this.verseNumber,
    required this.translationId,
    required this.anchorSpanIndex,
    required this.currentSpanIndex,
    this.anchorText,
  });

  final String bookId;
  final int chapterNumber;
  final int verseNumber;
  final String translationId;
  final int anchorSpanIndex;
  final int currentSpanIndex;
  // Canonical text of [rangeStart]..[rangeEnd], computed once the drag ends
  // (bible_viewer_tab_state_partial_highlight.dart, which has access to the
  // verse's display spans). Null while the drag is still live; the palette
  // only opens for confirmation after this is set, so by the time a color is
  // picked it's always present.
  final String? anchorText;

  int get rangeStart =>
      anchorSpanIndex <= currentSpanIndex ? anchorSpanIndex : currentSpanIndex;
  int get rangeEnd =>
      anchorSpanIndex <= currentSpanIndex ? currentSpanIndex : anchorSpanIndex;

  bool matchesVerse(String bookId, int chapterNumber, int verseNumber) =>
      this.bookId == bookId &&
      this.chapterNumber == chapterNumber &&
      this.verseNumber == verseNumber;

  PartialHighlightDraft copyWith({int? currentSpanIndex, String? anchorText}) {
    return PartialHighlightDraft(
      bookId: bookId,
      chapterNumber: chapterNumber,
      verseNumber: verseNumber,
      translationId: translationId,
      anchorSpanIndex: anchorSpanIndex,
      currentSpanIndex: currentSpanIndex ?? this.currentSpanIndex,
      anchorText: anchorText ?? this.anchorText,
    );
  }

  @override
  List<Object?> get props => [
    bookId,
    chapterNumber,
    verseNumber,
    translationId,
    anchorSpanIndex,
    currentSpanIndex,
    anchorText,
  ];
}

final partialHighlightDraftProvider =
    StateProvider.autoDispose<PartialHighlightDraft?>((ref) => null);

final selectedVerseAnnotationsProvider = Provider<List<UserAnnotation>>((ref) {
  final selectedVerses = ref.watch(selectedVersesProvider);
  if (selectedVerses.isEmpty) return const [];
  final translationFilter = ref.watch(annotationTranslationFilterProvider);
  // Use the full annotation stream instead of the chapter-filtered one.
  // visibleChapterAnnotationsProvider is filtered by currentReferenceProvider,
  // which does not update when the user scrolls in continuous mode — only when
  // they explicitly navigate. Selected verses can live in any visible chapter,
  // so the tray would otherwise show no annotations for scrolled-to chapters.
  final annotations = ref.watch(userAnnotationsProvider).value ?? const [];
  return annotations.where((annotation) {
    return selectedVerses.any(
      (reference) => annotation.touchesReference(
        reference,
        translationId: translationFilter,
      ),
    );
  }).toList();
});
