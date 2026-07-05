import 'package:basic_bible/src/features/annotations/application/view_models/annotation_data_view_models.dart';
import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';
import 'package:basic_bible/src/features/annotations/presentation/linked_verses_section.dart';
import 'package:basic_bible/src/features/annotations/presentation/annotation_theme.dart';
import 'package:basic_bible/src/features/annotations/presentation/annotation_detail_screen.dart';
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

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _selectedTags = {};
  final Set<String> _selectedTranslationIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedTags.clear();
      _selectedTranslationIds.clear();
    });
  }

  Future<void> _openReferenceInReader(
    BuildContext context, {
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
    BuildContext context, {
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
  Widget build(BuildContext context) {
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
          final tagOptions = _collectSortedTags(annotations);
          final translationOptions = _collectSortedTranslations(annotations);
          final hasActiveFilters =
              _searchQuery.isNotEmpty ||
              _selectedTags.isNotEmpty ||
              _selectedTranslationIds.isNotEmpty;

          final filteredAnnotations = annotations.where((annotation) {
            final matchesQuery =
                _searchQuery.isEmpty ||
                _annotationMatchesQuery(annotation, books, _searchQuery);
            final matchesTags =
                _selectedTags.isEmpty ||
                annotation.labels.any(_selectedTags.contains);
            final matchesTranslation =
                _selectedTranslationIds.isEmpty ||
                _selectedTranslationIds.contains(
                  annotation.primaryVerse.translationId,
                );
            return matchesQuery && matchesTags && matchesTranslation;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _NotesSearchField(
                  controller: _searchController,
                  onChanged: (value) =>
                      setState(() => _searchQuery = value.trim()),
                  onClear: () =>
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      }),
                ),
              ),
              if (translationOptions.length > 1 || tagOptions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: _NotesFilterBar(
                    translationOptions: translationOptions,
                    selectedTranslationIds: _selectedTranslationIds,
                    onTranslationToggled: (id, selected) => setState(() {
                      if (selected) {
                        _selectedTranslationIds.add(id);
                      } else {
                        _selectedTranslationIds.remove(id);
                      }
                    }),
                    tagOptions: tagOptions,
                    selectedTags: _selectedTags,
                    onTagToggled: (tag, selected) => setState(() {
                      if (selected) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
                      }
                    }),
                    onClearAll: hasActiveFilters ? _clearAllFilters : null,
                  ),
                ),
              Expanded(
                child: filteredAnnotations.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'No notes match your search or filters.',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: _clearAllFilters,
                                child: const Text('Clear filters'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredAnnotations.length,
                        separatorBuilder: (_, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final annotation = filteredAnnotations[index];
                          Future<void> openDetails() =>
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => AnnotationDetailScreen(
                                    annotation: annotation,
                                    books: books,
                                    onPreviewLinkedVerse: (link) =>
                                        _showLinkedVersePreview(
                                          context,
                                          link: link,
                                          books: books,
                                        ),
                                    onOpenReference: () async {
                                      await _openReferenceInReader(
                                        context,
                                        reference:
                                            annotation.primaryVerse.reference,
                                        preferredTranslationId: annotation
                                            .primaryVerse
                                            .translationId,
                                        preferredTranslationName: annotation
                                            .primaryVerse
                                            .translationName,
                                      );
                                    },
                                    onEdit: () async {
                                      Navigator.of(context).pop();
                                      await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              NoteEditorScreen(
                                                primaryVerse:
                                                    annotation.primaryVerse,
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
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(true),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirmed != true) return;
                                      try {
                                        await ref
                                            .read(
                                              userAnnotationRepositoryProvider,
                                            )
                                            .deleteAnnotation(id);
                                        if (context.mounted) {
                                          Navigator.of(context).pop();
                                        }
                                      } catch (_) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Failed to delete note.',
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ),
                              );
                          return _AnnotationListCard(
                            annotation: annotation,
                            books: books,
                            onViewDetails: openDetails,
                            onOpenReference: () async {
                              await _openReferenceInReader(
                                context,
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
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(true),
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
                            onPreviewLinkedVerse: (link) =>
                                _showLinkedVersePreview(
                                  context,
                                  link: link,
                                  books: books,
                                ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Failed to load notes: $error')),
      ),
    );
  }
}

/// Distinct labels used across all notes, sorted case-insensitively for the
/// tag filter chips.
List<String> _collectSortedTags(List<UserAnnotation> annotations) {
  final tags = <String>{};
  for (final annotation in annotations) {
    tags.addAll(annotation.labels);
  }
  final sorted = tags.toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return sorted;
}

/// Distinct translations used as a primary verse across all notes, sorted by
/// display name for the translation filter chips.
List<MapEntry<String, String>> _collectSortedTranslations(
  List<UserAnnotation> annotations,
) {
  final translations = <String, String>{};
  for (final annotation in annotations) {
    translations[annotation.primaryVerse.translationId] =
        annotation.primaryVerse.translationName;
  }
  final entries = translations.entries.toList()
    ..sort((a, b) => a.value.toLowerCase().compareTo(b.value.toLowerCase()));
  return entries;
}

/// Matches free text against note content, tags, translation names, and
/// verse references (e.g. "John 3:16", "3:16", or a book name/id) across the
/// primary verse and any linked verses.
bool _annotationMatchesQuery(
  UserAnnotation annotation,
  List<BibleBook> books,
  String query,
) {
  final buffer = StringBuffer()
    ..writeln(annotation.noteText ?? '')
    ..writeln(annotation.labels.join(' '));
  for (final verse in annotation.allVerses) {
    final bookName = displayBookNameForReference(books, verse.bookId);
    buffer
      ..writeln(verse.translationName)
      ..writeln(bookName)
      ..writeln(verse.bookId)
      ..writeln('$bookName ${verse.chapter}:${verse.verse}');
  }
  return buffer.toString().toLowerCase().contains(query.toLowerCase());
}

class _NotesSearchField extends StatelessWidget {
  const _NotesSearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Search notes, tags, or a verse like John 3:16',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: colors.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(icon: const Icon(Icons.clear), onPressed: onClear)
            : null,
      ),
      onChanged: onChanged,
    );
  }
}

class _NotesFilterBar extends StatelessWidget {
  const _NotesFilterBar({
    required this.translationOptions,
    required this.selectedTranslationIds,
    required this.onTranslationToggled,
    required this.tagOptions,
    required this.selectedTags,
    required this.onTagToggled,
    this.onClearAll,
  });

  final List<MapEntry<String, String>> translationOptions;
  final Set<String> selectedTranslationIds;
  final void Function(String id, bool selected) onTranslationToggled;
  final List<String> tagOptions;
  final Set<String> selectedTags;
  final void Function(String tag, bool selected) onTagToggled;
  final VoidCallback? onClearAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (translationOptions.length > 1) ...[
          Text('Translation', style: theme.textTheme.labelMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entry in translationOptions)
                _FilterChoiceChip(
                  label: entry.value,
                  isSelected: selectedTranslationIds.contains(entry.key),
                  onSelected: (selected) =>
                      onTranslationToggled(entry.key, selected),
                ),
            ],
          ),
          if (tagOptions.isNotEmpty) const SizedBox(height: 12),
        ],
        if (tagOptions.isNotEmpty) ...[
          Text('Tags', style: theme.textTheme.labelMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in tagOptions)
                _FilterChoiceChip(
                  label: tag,
                  isSelected: selectedTags.contains(tag),
                  onSelected: (selected) => onTagToggled(tag, selected),
                ),
            ],
          ),
        ],
        if (onClearAll != null)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onClearAll,
              child: const Text('Clear filters'),
            ),
          ),
      ],
    );
  }
}

class _FilterChoiceChip extends StatelessWidget {
  const _FilterChoiceChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      showCheckmark: false,
      selectedColor: colors.surfaceContainerHighest,
      backgroundColor: colors.surfaceContainerLow,
      side: BorderSide(
        color: isSelected ? colors.onSurface : colors.outlineVariant,
      ),
      labelStyle: TextStyle(
        color: isSelected ? colors.onSurface : colors.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
    );
  }
}

class _AnnotationListCard extends StatelessWidget {
  const _AnnotationListCard({
    required this.annotation,
    required this.books,
    required this.onViewDetails,
    required this.onOpenReference,
    required this.onEdit,
    required this.onDelete,
    required this.onPreviewLinkedVerse,
  });

  final UserAnnotation annotation;
  final List<BibleBook> books;
  final Future<void> Function() onViewDetails;
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

    return InkWell(
      onTap: onViewDetails,
      borderRadius: BorderRadius.circular(18),
      child: Container(
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
          InkWell(
            onTap: annotation.hasNoteText ? () async => onViewDetails() : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: annotation.hasNoteText
                    ? theme.colorScheme.surfaceContainerHighest
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                annotation.noteText?.trim().isNotEmpty == true
                    ? annotation.noteText!.trim()
                    : 'Saved highlight',
                style: theme.textTheme.bodyLarge,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
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
