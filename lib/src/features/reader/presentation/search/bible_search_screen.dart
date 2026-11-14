import 'dart:async';

import 'package:basic_bible/src/features/reader/application/view_models/bible_library_view_models.dart';
import 'package:basic_bible/src/features/reader/application/view_models/bible_search_view_models.dart';
import 'package:basic_bible/src/features/reader/application/view_models/reader_session_view_models.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/utils/reference_utils.dart';
import 'package:basic_bible/src/widgets/horizontal_mouse_scroll_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Full-text search of the current translation (#69), opened from the Bible
/// tab's search button. Tapping a result opens that verse in the reader.
class BibleSearchScreen extends ConsumerStatefulWidget {
  const BibleSearchScreen({super.key});

  @override
  ConsumerState<BibleSearchScreen> createState() => _BibleSearchScreenState();
}

class _BibleSearchScreenState extends ConsumerState<BibleSearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';
  BibleSearchScope _scope = BibleSearchScope.all;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    // Don't query the database on every keystroke.
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _query = value.trim());
    });
  }

  void _submit(String value) {
    _debounce?.cancel();
    setState(() => _query = value.trim());
  }

  Future<void> _open(BibleSearchHit hit) async {
    await ref
        .read(currentReferenceProvider.notifier)
        .setReference(hit.reference);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final books =
        ref.watch(readableBibleBooksProvider).asData?.value ??
        const <BibleBook>[];
    final currentReference = ref.watch(searchContextReferenceProvider);
    final currentBookName = displayBookNameForReference(
      books,
      currentReference.bookId,
    );
    // Chip labels name the actual book/chapter being read, e.g. "John 3".
    String scopeLabel(BibleSearchScope scope) => switch (scope) {
      BibleSearchScope.currentBook => currentBookName,
      BibleSearchScope.currentChapter => chapterReferenceLabel(
        currentBookName,
        currentReference.chapter,
      ),
      _ => scope.label,
    };
    final terms = bibleSearchTerms(_query);
    final results = terms.isEmpty
        ? null
        : ref.watch(
            bibleSearchResultsProvider(
              BibleSearchRequest(query: _query, scope: _scope),
            ),
          );

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search the Bible',
            border: InputBorder.none,
            suffixIcon: _controller.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear',
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      _submit('');
                    },
                  ),
          ),
          onChanged: (value) {
            setState(() {}); // refresh the clear button
            _onChanged(value);
          },
          onSubmitted: _submit,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 0, 8),
            child: SizedBox(
              height: 36,
              // Mouse-wheel scrollable too, so chips past the edge ("John 3")
              // are reachable on web/desktop where a mouse can't drag a list.
              child: HorizontalMouseScrollList(
                children: [
                  for (final scope in BibleSearchScope.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(scopeLabel(scope)),
                        selected: _scope == scope,
                        onSelected: (_) => setState(() => _scope = scope),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: results == null
                ? const _Message('Type a word or phrase to search.')
                : results.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => _Message('Search failed: $error'),
                    data: (hits) {
                      if (hits.isEmpty) {
                        return const _Message('No verses found.');
                      }
                      final capped = hits.length >= kBibleSearchLimit;
                      return ListView.separated(
                        itemCount: hits.length + 1,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                              child: Text(
                                capped
                                    ? 'Showing the first $kBibleSearchLimit '
                                          'verses. Add words to narrow it down.'
                                    : '${hits.length} '
                                          '${hits.length == 1 ? 'verse' : 'verses'}',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            );
                          }
                          final hit = hits[index - 1];
                          return ListTile(
                            title: Text(
                              '${displayBookNameForReference(books, hit.bookId)} '
                              '${hit.chapter}:${hit.verse}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text.rich(
                              highlightSearchTerms(
                                hit.text,
                                terms,
                                highlight: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            onTap: () => _open(hit),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// [text] with every occurrence of each term (case-insensitive) in
/// [highlight] style.
TextSpan highlightSearchTerms(
  String text,
  List<String> terms, {
  required TextStyle highlight,
}) {
  final pattern = terms.isEmpty
      ? null
      : RegExp(terms.map(RegExp.escape).join('|'), caseSensitive: false);
  if (pattern == null) return TextSpan(text: text);

  final spans = <TextSpan>[];
  var cursor = 0;
  for (final match in pattern.allMatches(text)) {
    if (match.start > cursor) {
      spans.add(TextSpan(text: text.substring(cursor, match.start)));
    }
    spans.add(TextSpan(text: match.group(0), style: highlight));
    cursor = match.end;
  }
  if (cursor < text.length) spans.add(TextSpan(text: text.substring(cursor)));
  return TextSpan(children: spans);
}

class _Message extends StatelessWidget {
  const _Message(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(text, textAlign: TextAlign.center),
    ),
  );
}
