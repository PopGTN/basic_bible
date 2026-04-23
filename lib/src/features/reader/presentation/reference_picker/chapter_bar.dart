import 'package:basic_bible/src/features/reader/presentation/reference_picker/reference_picker_screen.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/utils/reference_utils.dart';
import 'package:flutter/material.dart';

class ChapterBar extends StatelessWidget {
  const ChapterBar({
    super.key,
    required double barHeight,
    required this.isFloating,
    required this.reference,
    required this.books,
    required this.canOpenReferencePicker,
    required this.showVerseSelector,
    required this.onReferenceChanged,
    required this.onPreviousChapter,
    required this.onNextChapter,
  }) : _barHeight = barHeight;

  final double _barHeight;
  final bool isFloating;
  final BibleReference reference;
  final List<BibleBook> books;
  final bool canOpenReferencePicker;
  final bool showVerseSelector;
  final Function(BibleReference) onReferenceChanged;
  final VoidCallback onPreviousChapter;
  final VoidCallback onNextChapter;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final referenceBookName = displayBookNameForReference(
      books,
      reference.bookId,
    );
    // Shared inner row — middle label intentionally unchanged from non-floating.
    final row = Row(
      children: [
        _BarActionButton(
          icon: Icons.arrow_back_ios_new,
          onPressed: onPreviousChapter,
          tooltip: 'Previous chapter',
        ),
        Expanded(
          child: InkWell(
            onTap: canOpenReferencePicker
                ? () => _showReferencePicker(context)
                : null,
            borderRadius: BorderRadius.circular(20),
            child: Center(
              child: Text(
                '$referenceBookName ${reference.chapter}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        _BarActionButton(
          icon: Icons.arrow_forward_ios,
          onPressed: onNextChapter,
          tooltip: 'Next chapter',
        ),
      ],
    );

    // Both modes use identical styling. Only padding differs based on position:
    // floating sits at the bottom of the Stack, non-floating at the top.
    final container = SizedBox(
      height: _barHeight,
      child: Material(
        color: colors.surfaceContainerHighest,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: row,
        ),
      ),
    );

    if (isFloating) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: container,
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: container,
    );
  }

  Future<void> _showReferencePicker(BuildContext context) async {
    final newReference = await Navigator.of(context).push<BibleReference>(
      MaterialPageRoute(
        builder: (context) => ReferencePickerScreen(
          books: books,
          currentReference: reference,
          showVerseSelector: showVerseSelector,
        ),
      ),
    );
    if (newReference != null && context.mounted) {
      onReferenceChanged(newReference);
    }
  }
}

class _BarActionButton extends StatelessWidget {
  const _BarActionButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return IconButton(
      icon: Icon(icon, size: 18),
      onPressed: onPressed,
      tooltip: tooltip,
      color: colors.onSurface,
      splashRadius: 22,
    );
  }
}
