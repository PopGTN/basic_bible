import 'package:basic_bible/src/features/annotations/application/view_models/annotation_preferences_view_models.dart';
import 'package:basic_bible/src/features/annotations/data/user_annotation_repository.dart';
import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';
import 'package:basic_bible/src/features/reader/application/view_models/bible_library_view_models.dart';
import 'package:basic_bible/src/features/reader/application/view_models/reader_session_view_models.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/services/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userAnnotationRepositoryProvider = Provider<UserAnnotationRepository>((
  ref,
) {
  return UserAnnotationRepository(ref.watch(appDatabaseProvider));
});

final userAnnotationsProvider = StreamProvider<List<UserAnnotation>>((ref) {
  return ref.watch(userAnnotationRepositoryProvider).watchAnnotations();
});

/// The translation id annotation lookups should be restricted to, or `null`
/// when [showNotesAcrossTranslationsProvider] is enabled and matches should
/// ignore translation entirely (book/chapter/verse only).
final annotationTranslationFilterProvider = Provider<String?>((ref) {
  final showAcrossTranslations = ref.watch(
    showNotesAcrossTranslationsProvider,
  );
  if (showAcrossTranslations) return null;
  return ref.watch(currentTranslationProvider);
});

/// Exposes only the annotations relevant to the chapter currently visible
/// in the reader so presentation code can stay chapter-focused.
final visibleChapterAnnotationsProvider = Provider<List<UserAnnotation>>((ref) {
  final annotations = ref.watch(userAnnotationsProvider).value ?? const [];
  final currentReference = ref.watch(currentReferenceProvider);
  final translationFilter = ref.watch(annotationTranslationFilterProvider);

  return annotations.where((annotation) {
    final primaryMatches =
        (translationFilter == null ||
            annotation.primaryVerse.translationId == translationFilter) &&
        annotation.primaryVerse.bookId == currentReference.bookId &&
        annotation.primaryVerse.chapter == currentReference.chapter;
    final linkedMatches = annotation.linkedVerses.any(
      (link) =>
          (translationFilter == null ||
              link.translationId == translationFilter) &&
          link.bookId == currentReference.bookId &&
          link.chapter == currentReference.chapter,
    );
    return primaryMatches || linkedMatches;
  }).toList();
});

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
