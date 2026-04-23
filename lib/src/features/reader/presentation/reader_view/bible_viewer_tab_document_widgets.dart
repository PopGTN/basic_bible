part of 'bible_viewer_tab.dart';

class _DocumentBlockView extends StatelessWidget {
  const _DocumentBlockView({
    required this.block,
    required this.fontSize,
    this.isEmphasized = false,
  });

  final BibleDocumentBlock block;
  final double fontSize;
  final bool isEmphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHeading = block.kind == BibleDocumentBlockKind.heading;
    final isIntro = block.kind == BibleDocumentBlockKind.introduction;

    // Level 1 = major section heading (ms), 2 = standard section (s),
    // 3+ = sub-section (s2, s3). The parser library owns heading hierarchy.
    final headingLevel = isHeading ? (block.level ?? 2) : 0;

    final style = switch (block.kind) {
      BibleDocumentBlockKind.heading => switch (headingLevel) {
        1 => theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
        ),
        3 => theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          fontStyle: FontStyle.italic,
        ),
        _ => theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      },
      BibleDocumentBlockKind.preface => theme.textTheme.bodyLarge,
      BibleDocumentBlockKind.introduction =>
        theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      BibleDocumentBlockKind.poetry => theme.textTheme.bodyLarge?.copyWith(
        fontStyle: FontStyle.italic,
      ),
      _ => theme.textTheme.bodyMedium,
    };

    final bottomPadding = isHeading
        ? (headingLevel == 1
              ? 16.0
              : headingLevel >= 3
              ? 8.0
              : 12.0)
        : 10.0;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding, left: isIntro ? 12 : 0),
      child: Text(
        block.text,
        style: style?.copyWith(
          fontSize: (style.fontSize ?? fontSize) + (isEmphasized ? 1 : 0),
          color: isEmphasized ? theme.colorScheme.secondary : style.color,
          height: 1.5,
        ),
        textAlign: isHeading ? TextAlign.center : TextAlign.start,
      ),
    );
  }
}

class _DocumentBlockSection extends StatelessWidget {
  const _DocumentBlockSection({
    required this.blocks,
    required this.fontSize,
    this.eyebrow,
  });

  final String? eyebrow;
  final List<BibleDocumentBlock> blocks;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (eyebrow != null) ...[
            if (eyebrow != null)
              Text(
                eyebrow!,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.secondary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            const SizedBox(height: 10),
          ],
          for (final block in blocks)
            _DocumentBlockView(block: block, fontSize: fontSize),
        ],
      ),
    );
  }
}

class _TableBlockSection extends StatelessWidget {
  const _TableBlockSection({required this.rows, required this.fontSize});

  final List<BibleDocumentBlock> rows;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final dataRows = rows
        .where((b) => b.kind == BibleDocumentBlockKind.tableRow)
        .toList();
    if (dataRows.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < dataRows.length; i++)
            _buildRow(context, dataRows[i], i, colors),
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    BibleDocumentBlock row,
    int index,
    ColorScheme colors,
  ) {
    final isHeader = row.metadata['role'] == 'label';
    final cellsRaw = row.metadata['cells'] ?? row.text;
    final cells = cellsRaw.split('\t');

    return Container(
      color: isHeader
          ? colors.surfaceContainerHighest.withValues(alpha: 0.6)
          : index.isOdd
          ? colors.surfaceContainerLow.withValues(alpha: 0.3)
          : null,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          for (var c = 0; c < cells.length; c++) ...[
            if (c > 0) const SizedBox(width: 12),
            Expanded(
              child: Text(
                cells[c],
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: isHeader ? FontWeight.w700 : FontWeight.normal,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final shimmerBase = colors.surfaceContainerHigh;
    final shimmerHighlight = colors.surfaceContainerHighest;

    return Shimmer.fromColors(
      baseColor: shimmerBase,
      highlightColor: shimmerHighlight,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: 12,
        itemBuilder: (context, index) => _SkeletonVerseRow(index: index),
      ),
    );
  }
}

class _SkeletonVerseRow extends StatelessWidget {
  const _SkeletonVerseRow({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    final lineCount = 1 + (index % 3);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 16,
            margin: const EdgeInsets.only(top: 2, right: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < lineCount; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Container(
                      height: 14,
                      width: i == lineCount - 1
                          ? MediaQuery.of(context).size.width * 0.55
                          : double.infinity,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            SelectableText(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, child) {
                return ElevatedButton(
                  onPressed: () {
                    ref.invalidate(bibleBooksProvider);
                  },
                  child: const Text('Retry'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
