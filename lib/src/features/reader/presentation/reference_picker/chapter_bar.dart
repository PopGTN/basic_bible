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
    required this.showVerseSelector,
    required this.onReferenceChanged,
    required this.onPreviousChapter,
    required this.onNextChapter,
  }) : _barHeight = barHeight;

  final double _barHeight;
  final bool isFloating;
  final BibleReference reference;
  final List<BibleBook> books;
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
    final referenceLabel = '$referenceBookName ${reference.chapter}';

    if (isFloating) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Material(
          color: colors.surfaceContainerHighest,
          elevation: 6,
          shadowColor: Colors.black.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(28),
          clipBehavior: Clip.antiAlias,
          child: Container(
            height: _barHeight,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.7),
              ),
            ),
            child: Row(
              children: [
                _BarActionButton(
                  icon: Icons.arrow_back_ios_new,
                  onPressed: onPreviousChapter,
                  tooltip: 'Previous chapter',
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => _showReferencePicker(context),
                    borderRadius: BorderRadius.circular(28),
                    child: Center(
                      child: Text(
                        referenceLabel,
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
            ),
          ),
        ),
      );
    }

    return Container(
      height: _barHeight,
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _BarActionButton(
            icon: Icons.arrow_back_ios_new,
            onPressed: onPreviousChapter,
            tooltip: 'Previous chapter',
          ),
          Expanded(
            child: InkWell(
              onTap: () => _showReferencePicker(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      referenceBookName,
                      style: Theme.of(context).textTheme.titleSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${reference.chapter}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
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
      ),
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
