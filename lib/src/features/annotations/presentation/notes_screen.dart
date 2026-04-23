import 'package:basic_bible/src/features/annotations/application/view_models/annotation_data_view_models.dart';
import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';
import 'package:basic_bible/src/features/annotations/presentation/linked_verses_section.dart';
import 'package:basic_bible/src/features/annotations/presentation/annotation_theme.dart';
import 'package:basic_bible/src/features/annotations/presentation/note_editor_screen.dart';
import 'package:basic_bible/src/features/home/application/view_models/home_navigation_view_model.dart';
import 'package:basic_bible/src/features/reader/application/view_models/bible_library_view_models.dart';
import 'package:basic_bible/src/features/reader/application/view_models/reader_session_view_models.dart';
import 'package:basic_bible/src/features/reader/presentation/reference_picker/reference_preview_sheet.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/utils/reference_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  Future<void> _openReferenceInReader(
    BuildContext context,
    WidgetRef ref, {
    required BibleReference reference,
    required String preferredTranslationId,
    required String preferredTranslationName,
    String? fallbackTranslationId,
    String? fallbackTranslationName,
  }) async {
    try {
      final available = await ref.read(availableTranslationsProvider.future);
      final preferredExists = available.any(
        (translation) => translation.id == preferredTranslationId,
      );
      final fallbackExists =
          fallbackTranslationId != null &&
          available.any(
            (translation) => translation.id == fallbackTranslationId,
          );
      final fallbackId = fallbackTranslationId;

      if (preferredExists) {
        await ref
            .read(currentTranslationProvider.notifier)
            .setTranslation(preferredTranslationId);
      } else if (fallbackExists && fallbackId != null) {
        await ref
            .read(currentTranslationProvider.notifier)
            .setTranslation(fallbackId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '"$preferredTranslationName" is not installed. '
                'Opening in ${fallbackTranslationName ?? 'the current translation'}.',
              ),
            ),
          );
        }
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '"$preferredTranslationName" is not installed. Opening in current translation.',
            ),
          ),
        );
      }

      await ref.read(currentReferenceProvider.notifier).setReference(reference);
      ref.read(homeTabIndexProvider.notifier).state = 1;
      if (context.mounted) context.go('/home');
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to open reference.')),
        );
      }
    }
  }

  Future<void> _showLinkedVersePreview(
    BuildContext context,
    WidgetRef ref, {
    required AnnotationVerseLink link,
    required List<BibleBook> books,
  }) {
    final currentTranslationId = ref.read(currentTranslationProvider);
    final currentTranslationName =
        ref
            .read(availableTranslationsProvider)
            .asData
            ?.value
            .where((translation) => translation.id == currentTranslationId)
            .firstOrNull
            ?.name ??
        'Current translation';

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return ReferencePreviewSheet(
          referenceLabel:
              '${displayBookNameForReference(books, link.bookId)} ${link.chapter}:${link.verse}',
          reference: link.reference,
          preferredTranslationId: link.translationId,
          preferredTranslationName: link.translationName,
          fallbackTranslationId: currentTranslationId,
          fallbackTranslationName: currentTranslationName,
          books: books,
          returnLabel: 'Back to Note',
          onOpenInBible: (previewContext, preview) async {
            Navigator.of(previewContext).pop();
            await _openReferenceInReader(
              context,
              ref,
              reference: preview.reference,
              preferredTranslationId: preview.translationId,
              preferredTranslationName: preview.translationName,
              fallbackTranslationId: currentTranslationId,
              fallbackTranslationName: currentTranslationName,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final annotationsAsync = ref.watch(userAnnotationsProvider);
    final booksAsync = ref.watch(bibleBooksShellProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: annotationsAsync.when(
        data: (annotations) {
          if (annotations.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No saved notes or highlights yet. Select a verse in the reader to create one.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final books = booksAsync.value ?? const <BibleBook>[];
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: annotations.length,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final annotation = annotations[index];
              return _AnnotationListCard(
                annotation: annotation,
                books: books,
                onOpenReference: () async {
                  await _openReferenceInReader(
                    context,
                    ref,
                    reference: annotation.primaryVerse.reference,
                    preferredTranslationId:
                        annotation.primaryVerse.translationId,
                    preferredTranslationName:
                        annotation.primaryVerse.translationName,
                  );
                },
                onEdit: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => NoteEditorScreen(
                        primaryVerse: annotation.primaryVerse,
                        existingAnnotation: annotation,
                      ),
                    ),
                  );
                },
                onDelete: () async {
                  final id = annotation.id;
                  if (id == null) return;
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete?'),
                      content: const Text(
                        'This note and all its linked verses will be permanently removed.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed != true) return;
                  try {
                    await ref
                        .read(userAnnotationRepositoryProvider)
                        .deleteAnnotation(id);
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to delete note.')),
                      );
                    }
                  }
                },
                onPreviewLinkedVerse: (link) => _showLinkedVersePreview(
                  context,
                  ref,
                  link: link,
                  books: books,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Failed to load notes: $error')),
      ),
    );
  }
}

class _AnnotationListCard extends StatelessWidget {
  const _AnnotationListCard({
    required this.annotation,
    required this.books,
    required this.onOpenReference,
    required this.onEdit,
    required this.onDelete,
    required this.onPreviewLinkedVerse,
  });

  final UserAnnotation annotation;
  final List<BibleBook> books;
  final Future<void> Function() onOpenReference;
  final Future<void> Function() onEdit;
  final Future<void> Function() onDelete;
  final Future<void> Function(AnnotationVerseLink link) onPreviewLinkedVerse;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final highlightColor = annotation.highlightColorValue == null
        ? null
        : annotationColorFromValue(
            annotation.highlightColorValue,
            theme.colorScheme.primary,
          );
    final referenceLabel =
        '${displayBookNameForReference(books, annotation.primaryVerse.bookId)} '
        '${annotation.primaryVerse.chapter}:${annotation.primaryVerse.verse}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _TypePill(
                      label: annotation.hasNoteText ? 'Note' : 'Highlight',
                    ),
                    if (highlightColor != null)
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: highlightColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    Text(
                      annotation.primaryVerse.translationName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  switch (value) {
                    case 'edit':
                      await onEdit();
                    case 'delete':
                      await onDelete();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            referenceLabel,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            annotation.noteText?.trim().isNotEmpty == true
                ? annotation.noteText!.trim()
                : 'Saved highlight',
            style: theme.textTheme.bodyLarge,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (annotation.linkedVerses.isNotEmpty) ...[
            const SizedBox(height: 12),
            LinkedVersesSection(
              books: books,
              links: annotation.linkedVerses,
              onPreviewLinkedVerse: onPreviewLinkedVerse,
            ),
          ],
          if (annotation.labels.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final label in annotation.labels) Chip(label: Text(label)),
              ],
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              TextButton.icon(
                onPressed: onOpenReference,
                icon: const Icon(Icons.menu_book_outlined),
                label: const Text('Open in Reader'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  const _TypePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
