import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/view_models/hymnal_view_models.dart';
import '../models/hymn.dart';
import '../models/hymnal.dart';

/// The search/browse results. Fixed-height rows built lazily, so even the
/// 1,200-hymn books scroll smoothly on low-end phones.
class HymnListView extends ConsumerWidget {
  const HymnListView({super.key, required this.hymnal, required this.selected});

  final Hymnal hymnal;

  /// Highlighted row in the two-pane layout.
  final int? selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final results = ref.watch(hymnResultsProvider) ?? const <Hymn>[];
    final favorites = ref.watch(hymnFavoritesProvider(hymnal.info.id));
    final favoritesOnly = ref.watch(hymnFavoritesOnlyProvider);
    final query = ref.watch(hymnQueryProvider).trim();
    final theme = Theme.of(context);

    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            favoritesOnly && query.isEmpty
                ? t.hymnNoFavorites
                : t.hymnNoResults,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ),
      );
    }

    final rowHeight = MediaQuery.textScalerOf(context).scale(60);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 4),
          child: Text(
            t.hymnCount(results.length),
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ),
        Expanded(
          child: Scrollbar(
            child: ListView.builder(
              // One scroll position per book, kept across tab switches.
              key: PageStorageKey('hymn-list-${hymnal.info.id}'),
              itemExtent: rowHeight,
              itemCount: results.length,
              itemBuilder: (context, i) {
                final hymn = results[i];
                return _HymnRow(
                  hymn: hymn,
                  bookId: hymnal.info.id,
                  isFavorite: favorites.contains(hymn.number),
                  isSelected: hymn.number == selected,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _HymnRow extends ConsumerWidget {
  const _HymnRow({
    required this.hymn,
    required this.bookId,
    required this.isFavorite,
    required this.isSelected,
  });

  final Hymn hymn;
  final String bookId;
  final bool isFavorite;
  final bool isSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final firstLine = hymn.firstLine.replaceAll(RegExp(r'[,;:.]+$'), '');
    final subtitle = firstLine.isNotEmpty && firstLine != hymn.title
        ? firstLine
        : hymn.author;
    return Material(
      color: isSelected
          ? theme.colorScheme.secondaryContainer
          : Colors.transparent,
      child: InkWell(
        onTap: () =>
            ref.read(openHymnNumberProvider.notifier).open(hymn.number),
        child: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Row(
            children: [
              SizedBox(
                width: 48,
                child: Text(
                  '${hymn.number}',
                  textAlign: TextAlign.end,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hymn.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge,
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                tooltip: isFavorite ? t.hymnRemoveFavorite : t.hymnAddFavorite,
                icon: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  color: isFavorite ? Colors.amber.shade700 : null,
                ),
                onPressed: () => ref
                    .read(hymnFavoritesProvider(bookId).notifier)
                    .toggle(hymn.number),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
