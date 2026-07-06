import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';
import 'package:basic_bible/src/features/annotations/application/view_models/annotation_data_view_models.dart';
import 'package:basic_bible/src/models/bible_models.dart';
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
