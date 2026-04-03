import 'package:basic_bible/src/features/annotations/data/user_annotation_repository.dart';
import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';
import 'package:basic_bible/src/features/reader/application/bible_provider.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/services/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final userAnnotationRepositoryProvider = Provider<UserAnnotationRepository>((
  ref,
) {
  return UserAnnotationRepository(ref.watch(appDatabaseProvider));
});

final selectedVerseProvider = StateProvider.autoDispose<BibleReference?>(
  (ref) => null,
);

final highlightPaletteExpandedProvider = StateProvider.autoDispose<bool>(
  (ref) => false,
);

final userAnnotationsProvider = StreamProvider<List<UserAnnotation>>((ref) {
  return ref.watch(userAnnotationRepositoryProvider).watchAnnotations();
});

final visibleChapterAnnotationsProvider = Provider<List<UserAnnotation>>((ref) {
  final annotations = ref.watch(userAnnotationsProvider).value ?? const [];
  final currentReference = ref.watch(currentReferenceProvider);
  final translationId = ref.watch(currentTranslationProvider);

  return annotations.where((annotation) {
    final primaryMatches =
        annotation.primaryVerse.translationId == translationId &&
        annotation.primaryVerse.bookId == currentReference.bookId &&
        annotation.primaryVerse.chapter == currentReference.chapter;
    final linkedMatches = annotation.linkedVerses.any(
      (link) =>
          link.translationId == translationId &&
          link.bookId == currentReference.bookId &&
          link.chapter == currentReference.chapter,
    );
    return primaryMatches || linkedMatches;
  }).toList();
});

final selectedVerseAnnotationsProvider = Provider<List<UserAnnotation>>((ref) {
  final selectedVerse = ref.watch(selectedVerseProvider);
  if (selectedVerse == null) return const [];
  final translationId = ref.watch(currentTranslationProvider);
  final annotations = ref.watch(visibleChapterAnnotationsProvider);
  return annotations
      .where(
        (annotation) => annotation.touchesReference(
          selectedVerse,
          translationId: translationId,
        ),
      )
      .toList();
});

final annotationEditorDraftProvider =
    StateNotifierProvider<AnnotationEditorDraftNotifier, AnnotationEditorDraft?>(
      (ref) => AnnotationEditorDraftNotifier(),
    );

class AnnotationEditorDraftNotifier
    extends StateNotifier<AnnotationEditorDraft?> {
  AnnotationEditorDraftNotifier() : super(null);

  void startNew({
    required AnnotationVerseLink primaryVerse,
    UserAnnotationType type = UserAnnotationType.note,
    int? highlightColorValue,
  }) {
    state = AnnotationEditorDraft(
      type: type,
      primaryVerse: primaryVerse,
      highlightColorValue: highlightColorValue,
    );
  }

  void editExisting(UserAnnotation annotation) {
    state = AnnotationEditorDraft.fromAnnotation(annotation);
  }

  void setNoteText(String value) {
    final current = state;
    if (current == null) return;
    state = current.copyWith(noteText: value);
  }

  void setLabels(List<String> labels) {
    final current = state;
    if (current == null) return;
    state = current.copyWith(labels: labels);
  }

  void setHighlightColor(int? value) {
    final current = state;
    if (current == null) return;
    state = current.copyWith(
      highlightColorValue: value,
      clearHighlightColor: value == null,
    );
  }

  void addLinkedVerse(AnnotationVerseLink verse) {
    final current = state;
    if (current == null) return;
    final exists = current.linkedVerses.any(
      (link) =>
          link.bookId == verse.bookId &&
          link.chapter == verse.chapter &&
          link.verse == verse.verse &&
          link.translationId == verse.translationId,
    );
    if (exists) return;
    final nextLinked = [
      ...current.linkedVerses,
      verse.copyWith(sortOrder: current.linkedVerses.length),
    ];
    state = current.copyWith(linkedVerses: nextLinked);
  }

  void removeLinkedVerse(AnnotationVerseLink verse) {
    final current = state;
    if (current == null) return;
    final nextLinked = current.linkedVerses
        .where(
          (link) =>
              !(link.bookId == verse.bookId &&
                  link.chapter == verse.chapter &&
                  link.verse == verse.verse &&
                  link.translationId == verse.translationId),
        )
        .toList();
    state = current.copyWith(
      linkedVerses: [
        for (var i = 0; i < nextLinked.length; i++)
          nextLinked[i].copyWith(sortOrder: i),
      ],
    );
  }

  void reset() {
    state = null;
  }
}

AnnotationVerseLink buildAnnotationVerseLink({
  required BibleReference reference,
  required BibleTranslation translation,
}) {
  return AnnotationVerseLink(
    bookId: reference.bookId,
    chapter: reference.chapter,
    verse: reference.verse ?? 1,
    translationId: translation.id,
    translationName: translation.name,
  );
}

UserAnnotation draftToAnnotation(AnnotationEditorDraft draft) {
  final now = DateTime.now();
  return UserAnnotation(
    id: draft.editingAnnotationId,
    type: draft.type,
    primaryVerse: draft.primaryVerse,
    noteText: draft.noteText.trim().isEmpty ? null : draft.noteText.trim(),
    highlightColorValue: draft.highlightColorValue,
    labels: draft.labels,
    linkedVerses: draft.linkedVerses,
    createdAt: draft.createdAt ?? now,
    updatedAt: now,
  );
}

/// Returns the [BibleTranslation] currently selected by the user, or `null`
/// if the translation list hasn't loaded or the id is no longer present.
/// Callers must guard against null before saving annotation metadata.
Future<BibleTranslation?> resolveCurrentTranslation(WidgetRef ref) async {
  final currentTranslationId = ref.read(currentTranslationProvider);
  final available = await ref.read(availableTranslationsProvider.future);
  for (final t in available) {
    if (t.id == currentTranslationId) return t;
  }
  return null;
}
