import 'package:basic_bible/src/features/annotations/application/view_models/annotation_data_view_models.dart';
import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';
import 'package:basic_bible/src/features/annotations/presentation/annotation_theme.dart';
import 'package:basic_bible/src/features/annotations/presentation/note_editor_screen.dart';
import 'package:basic_bible/src/features/home/application/view_models/home_navigation_view_model.dart';
import 'package:basic_bible/src/features/reader/application/view_models/bible_library_view_models.dart';
import 'package:basic_bible/src/features/reader/application/view_models/reader_session_view_models.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/utils/reference_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

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
                  final translationId = annotation.primaryVerse.translationId;
                  try {
                    final available =
                        await ref.read(availableTranslationsProvider.future);
                    final exists = available.any((t) => t.id == translationId);
                    if (!exists) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '"${annotation.primaryVerse.translationName}" is not installed. '
                              'Opening in current translation.',
                            ),
                          ),
                        );
                      }
                    } else {
                      await ref
                          .read(currentTranslationProvider.notifier)
                          .setTranslation(translationId);
                    }
                    await ref
                        .read(currentReferenceProvider.notifier)
                        .setReference(annotation.primaryVerse.reference);
                    ref.read(homeTabIndexProvider.notifier).state = 1;
                    if (context.mounted) context.go('/home');
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to open reference.'),
                        ),
                      );
                    }
                  }
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
                        const SnackBar(
                          content: Text('Failed to delete note.'),
                        ),
                      );
                    }
                  }
                },
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
  });

  final UserAnnotation annotation;
  final List<BibleBook> books;
  final Future<void> Function() onOpenReference;
  final Future<void> Function() onEdit;
  final Future<void> Function() onDelete;

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
          ),
          if (annotation.linkedVerses.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final link in annotation.linkedVerses)
                  Chip(
                    label: Text(
                      '${displayBookNameForReference(books, link.bookId)} ${link.chapter}:${link.verse}',
                    ),
                  ),
              ],
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
