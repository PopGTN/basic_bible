import 'dart:async';

import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/view_models/hymn_settings_view_model.dart';
import '../application/view_models/hymnal_view_models.dart';
import '../data/hymn_search.dart';
import '../models/hymnal.dart';
import 'hymn_detail_view.dart';
import 'hymn_list_view.dart';
import 'hymnal_picker_sheet.dart';

/// Width at which list and hymn sit side by side, so the list keeps
/// updating as you type while a hymn stays open.
const kHymnsTwoPaneWidth = 840.0;

/// The Hymns tab body: a search field over either the result list or the
/// open hymn (phones), or both side by side (tablets, desktop, web).
class HymnsTab extends ConsumerWidget {
  const HymnsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final hymnal = ref.watch(currentHymnalProvider);
    return Column(
      children: [
        const _HymnSearchField(),
        Expanded(
          child: switch (hymnal) {
            AsyncData(:final value) => _HymnsBody(hymnal: value),
            AsyncError() => _LoadError(
              message: t.hymnalLoadError,
              onRetry: () => ref.invalidate(currentHymnalProvider),
            ),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
      ],
    );
  }
}

class _HymnsBody extends ConsumerWidget {
  const _HymnsBody({required this.hymnal});

  final Hymnal hymnal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final openNumber = ref.watch(openHymnNumberProvider);
    final openHymn = openNumber == null ? null : hymnal.byNumber(openNumber);
    final twoPane = MediaQuery.sizeOf(context).width >= kHymnsTwoPaneWidth;

    if (twoPane) {
      return Row(
        children: [
          SizedBox(
            width: 380,
            child: HymnListView(hymnal: hymnal, selected: openNumber),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: openHymn == null
                ? const _PickAHymnHint()
                : HymnDetailView(
                    key: ValueKey('${hymnal.info.id}#${openHymn.number}'),
                    hymnal: hymnal,
                    hymn: openHymn,
                    showBackButton: false,
                  ),
          ),
        ],
      );
    }

    // Phones: back (and predictive back) closes the hymn, not the tab.
    return PopScope(
      canPop: openHymn == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) ref.read(openHymnNumberProvider.notifier).close();
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 160),
        child: openHymn == null
            ? HymnListView(
                key: const ValueKey('list'),
                hymnal: hymnal,
                selected: null,
              )
            : HymnDetailView(
                key: ValueKey('${hymnal.info.id}#${openHymn.number}'),
                hymnal: hymnal,
                hymn: openHymn,
                showBackButton: true,
              ),
      ),
    );
  }
}

/// Search box shared by both layouts. Typing on a phone while a hymn is open
/// goes back to the live result list (the hymn stays open in two-pane).
class _HymnSearchField extends ConsumerStatefulWidget {
  const _HymnSearchField();

  @override
  ConsumerState<_HymnSearchField> createState() => _HymnSearchFieldState();
}

class _HymnSearchFieldState extends ConsumerState<_HymnSearchField> {
  late final TextEditingController _controller = TextEditingController(
    text: ref.read(hymnQueryProvider),
  );
  final _focus = FocusNode();
  Timer? _debounce;
  Timer? _autoOpen;

  /// The number a pending or finished auto-open was for, so it doesn't fire
  /// twice for the same text.
  String? _autoOpenedFor;

  /// After the pause that lets a longer number be typed (12 → 122).
  static const _autoOpenPause = Duration(milliseconds: 900);

  @override
  void initState() {
    super.initState();
    _focus.addListener(_selectNumberOnFocus);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _autoOpen?.cancel();
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Tapping back into the box after a number search selects the number, so
  /// the next one can be typed straight over it.
  void _selectNumberOnFocus() {
    if (!_focus.hasFocus) return;
    final text = _controller.text.trim();
    if (!RegExp(r'^#?\d+$').hasMatch(text)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });
  }

  /// "Open a hymn when you type its number": opens the exact match right
  /// away, or after a short pause when longer numbers share its digits.
  void _maybeAutoOpen(String value) {
    _autoOpen?.cancel();
    if (!ref.read(hymnSettingsProvider).openOnNumber) return;
    final hymnal = ref.read(currentHymnalProvider).value;
    if (hymnal == null) return;
    final target = hymnToAutoOpen(hymnal, value);
    if (target == null) {
      _autoOpenedFor = null;
      return;
    }
    if (_autoOpenedFor == value) return;
    void open() {
      if (!mounted || _controller.text != value) return;
      _autoOpenedFor = value;
      ref.read(openHymnNumberProvider.notifier).open(target.number);
      // On phones the hymn replaces the list: put the keyboard away so the
      // hymn can be read. Two-pane keeps typing focus.
      if (MediaQuery.sizeOf(context).width < kHymnsTwoPaneWidth) {
        _focus.unfocus();
      }
    }

    switch (target.when) {
      case HymnAutoOpen.now:
        open();
      case HymnAutoOpen.afterPause:
        _autoOpen = Timer(_autoOpenPause, open);
    }
  }

  void _onChanged(String value) {
    final twoPane = MediaQuery.sizeOf(context).width >= kHymnsTwoPaneWidth;
    if (!twoPane) ref.read(openHymnNumberProvider.notifier).close();
    // Search itself takes a millisecond or two; the short debounce only
    // avoids rebuilding the list for every key of a fast typist.
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 90), () {
      if (!mounted) return;
      ref.read(hymnQueryProvider.notifier).set(value);
      _maybeAutoOpen(value);
    });
  }

  void _clear() {
    _debounce?.cancel();
    _autoOpen?.cancel();
    _autoOpenedFor = null;
    _controller.clear();
    ref.read(hymnQueryProvider.notifier).set('');
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    // Keep the field in sync if something else changes the query.
    ref.listen(hymnQueryProvider, (_, next) {
      if (next != _controller.text && _debounce?.isActive != true) {
        _controller.text = next;
      }
    });
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: TextField(
        controller: _controller,
        focusNode: _focus,
        onChanged: _onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          isDense: true,
          hintText: t.hymnSearchHint,
          prefixIcon: const Icon(Icons.search),
          border: const OutlineInputBorder(),
          suffixIcon: ValueListenableBuilder(
            valueListenable: _controller,
            builder: (context, value, _) => value.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).deleteButtonTooltip,
                    icon: const Icon(Icons.clear),
                    onPressed: _clear,
                  ),
          ),
        ),
      ),
    );
  }
}

/// App bar title for the Hymns tab: the current book, tap to switch.
class HymnalTitleButton extends ConsumerWidget {
  const HymnalTitleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final info = ref.watch(currentHymnalProvider).value?.info;
    final title = info?.displayShortTitle ?? t.hymnsTab;
    final color = DefaultTextStyle.of(context).style.color;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => showHymnalPicker(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: Text(title, overflow: TextOverflow.ellipsis)),
            Icon(Icons.arrow_drop_down, color: color),
          ],
        ),
      ),
    );
  }
}

/// App bar actions for the Hymns tab: favorites filter, sort, library.
List<Widget> hymnsTabActions(BuildContext context) => const [
  _FavoritesFilterButton(),
  _SortButton(),
  _LibraryButton(),
];

class _FavoritesFilterButton extends ConsumerWidget {
  const _FavoritesFilterButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final on = ref.watch(hymnFavoritesOnlyProvider);
    final bookId = ref.watch(selectedHymnalIdProvider);
    final count = ref.watch(hymnFavoritesProvider(bookId)).length;
    return IconButton(
      isSelected: on,
      tooltip: on ? t.hymnShowAll : t.hymnFavoritesOnly,
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text('$count'),
        child: const Icon(Icons.star_border),
      ),
      selectedIcon: Badge(
        isLabelVisible: count > 0,
        label: Text('$count'),
        child: const Icon(Icons.star),
      ),
      onPressed: () => ref.read(hymnFavoritesOnlyProvider.notifier).toggle(),
    );
  }
}

class _SortButton extends ConsumerWidget {
  const _SortButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final sort = ref.watch(hymnSortProvider);
    return PopupMenuButton<HymnSortOrder>(
      tooltip: t.hymnSortTooltip,
      icon: const Icon(Icons.sort),
      initialValue: sort,
      onSelected: (order) => ref.read(hymnSortProvider.notifier).set(order),
      itemBuilder: (_) => [
        CheckedPopupMenuItem(
          value: HymnSortOrder.number,
          checked: sort == HymnSortOrder.number,
          child: Text(t.hymnSortNumber),
        ),
        CheckedPopupMenuItem(
          value: HymnSortOrder.alphabetical,
          checked: sort == HymnSortOrder.alphabetical,
          child: Text(t.hymnSortAlphabetical),
        ),
      ],
    );
  }
}

class _LibraryButton extends StatelessWidget {
  const _LibraryButton();

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: AppLocalizations.of(context)!.hymnalLibraryTitle,
    icon: const Icon(Icons.library_books_outlined),
    onPressed: () => context.push('/home/hymns/library'),
  );
}

class _PickAHymnHint extends StatelessWidget {
  const _PickAHymnHint();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.library_music_outlined,
            size: 48,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.hymnPickHint,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: onRetry,
            child: Text(AppLocalizations.of(context)!.retryAction),
          ),
        ],
      ),
    ),
  );
}
