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

/// Annotations matching [annotationTranslationFilterProvider] indexed by
/// `"bookId:chapter"`.
///
/// Rebuilt once per annotation change. The reader renders hundreds of verses
/// per frame in continuous mode; looking each verse up in its chapter bucket
/// is O(annotations-in-chapter) instead of scanning the entire annotation
/// list per verse.
final annotationsByChapterProvider = Provider<Map<String, List<UserAnnotation>>>(
  (ref) {
    final annotations = ref.watch(userAnnotationsProvider).value ?? const [];
    final translationFilter = ref.watch(annotationTranslationFilterProvider);
    final index = <String, List<UserAnnotation>>{};
    for (final annotation in annotations) {
      // A multi-verse annotation can span chapters; register it in each
      // chapter bucket exactly once.
      final seenChapters = <String>{};
      for (final link in annotation.allVerses) {
        if (translationFilter != null && link.translationId != translationFilter) {
          continue;
        }
        final key = annotationChapterKey(link.bookId, link.chapter);
        if (seenChapters.add(key)) {
          index.putIfAbsent(key, () => []).add(annotation);
        }
      }
    }
    return index;
  },
);

/// Key format used by [annotationsByChapterProvider].
String annotationChapterKey(String bookId, int chapter) => '$bookId:$chapter';

/// Exposes only the annotations relevant to the chapter currently visible
/// in the reader so presentation code can stay chapter-focused.
final visibleChapterAnnotationsProvider = Provider<List<UserAnnotation>>((ref) {
  final currentReference = ref.watch(currentReferenceProvider);
  final byChapter = ref.watch(annotationsByChapterProvider);
  return byChapter[annotationChapterKey(
        currentReference.bookId,
        currentReference.chapter,
      )] ??
      const [];
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
