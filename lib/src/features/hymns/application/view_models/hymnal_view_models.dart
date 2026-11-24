import 'package:basic_bible/src/services/shared_preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/content_repo_service.dart';
import '../../data/hymn_search.dart';
import '../../data/hymnal_repository.dart';
import '../../data/hymnal_store.dart';
import '../../models/hymn.dart';
import '../../models/hymnal.dart';

// State for the Hymns tab. Everything lives in providers rather than widget
// state because the home shell rebuilds tabs from scratch on every switch:
// coming back to Hymns must show the same book, query and open hymn.

final hymnalStoreProvider = Provider<HymnalStore>((ref) {
  final store = DriftHymnalStore();
  ref.onDispose(store.close);
  return store;
});

final hymnalRepositoryProvider = Provider<HymnalRepository>(
  (ref) => HymnalRepository(store: ref.watch(hymnalStoreProvider)),
);

final contentRepoServiceProvider = Provider<ContentRepoService>(
  (ref) => ContentRepoService(ref.watch(sharedPreferencesProvider)),
);

/// Bundled plus installed books. Invalidate after import/download/delete.
final hymnalListProvider = FutureProvider<List<HymnalInfo>>(
  (ref) => ref.watch(hymnalRepositoryProvider).listHymnals(),
);

final selectedHymnalIdProvider =
    NotifierProvider<SelectedHymnalNotifier, String>(
      SelectedHymnalNotifier.new,
    );

class SelectedHymnalNotifier extends Notifier<String> {
  static const _key = 'hymnal_selected_id';

  @override
  String build() =>
      ref.read(sharedPreferencesProvider).getString(_key) ?? kDefaultHymnalId;

  void select(String id) {
    if (id == state) return;
    state = id;
    ref.read(sharedPreferencesProvider).setString(_key, id);
    ref.read(openHymnNumberProvider.notifier).close();
  }
}

/// The selected book, parsed. Falls back to the default bundled book if the
/// saved selection was deleted or can no longer be read.
final currentHymnalProvider = FutureProvider<Hymnal>((ref) async {
  final repository = ref.watch(hymnalRepositoryProvider);
  final id = ref.watch(selectedHymnalIdProvider);
  try {
    return await repository.load(id);
  } catch (_) {
    // Fall back to the first book this build actually has.
    final available = await repository.listHymnals();
    final fallback = available.where((b) => b.id != id).firstOrNull;
    if (fallback == null) rethrow;
    return repository.load(fallback.id);
  }
});

final hymnQueryProvider = NotifierProvider<HymnQueryNotifier, String>(
  HymnQueryNotifier.new,
);

class HymnQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String query) => state = query;
}

final hymnSortProvider = NotifierProvider<HymnSortNotifier, HymnSortOrder>(
  HymnSortNotifier.new,
);

class HymnSortNotifier extends Notifier<HymnSortOrder> {
  static const _key = 'hymnal_sort';

  @override
  HymnSortOrder build() {
    final saved = ref.read(sharedPreferencesProvider).getString(_key);
    return HymnSortOrder.values.firstWhere(
      (order) => order.name == saved,
      orElse: () => HymnSortOrder.number,
    );
  }

  void set(HymnSortOrder order) {
    state = order;
    ref.read(sharedPreferencesProvider).setString(_key, order.name);
  }
}

final hymnFavoritesOnlyProvider =
    NotifierProvider<HymnFavoritesOnlyNotifier, bool>(
      HymnFavoritesOnlyNotifier.new,
    );

class HymnFavoritesOnlyNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;

  void set(bool value) => state = value;
}

/// Favorite hymn numbers for one book, saved on device per book.
final hymnFavoritesProvider =
    NotifierProvider.family<HymnFavoritesNotifier, Set<int>, String>(
      HymnFavoritesNotifier.new,
    );

class HymnFavoritesNotifier extends Notifier<Set<int>> {
  HymnFavoritesNotifier(this.bookId);

  final String bookId;

  String get _key => 'hymn_favorites_$bookId';

  @override
  Set<int> build() => {
    for (final value
        in ref.read(sharedPreferencesProvider).getStringList(_key) ??
            const <String>[])
      if (int.tryParse(value) case final number?) number,
  };

  void toggle(int number) {
    final next = {...state};
    if (!next.remove(number)) next.add(number);
    state = next;
    ref.read(sharedPreferencesProvider).setStringList(_key, [
      for (final n in next.toList()..sort()) '$n',
    ]);
  }
}

/// The list the user sees: search + sort + favorites filter applied. A sync
/// derived provider, so results change on the same frame as the query —
/// including while a hymn is open in the two-pane layout.
final hymnResultsProvider = Provider<List<Hymn>?>((ref) {
  final hymnal = ref.watch(currentHymnalProvider).value;
  if (hymnal == null) return null;
  final favoritesOnly = ref.watch(hymnFavoritesOnlyProvider);
  return searchHymnal(
    hymnal,
    ref.watch(hymnQueryProvider),
    sort: ref.watch(hymnSortProvider),
    favorites: favoritesOnly
        ? ref.watch(hymnFavoritesProvider(hymnal.info.id))
        : null,
  );
});

/// The hymn open in the detail view, by number; null shows the list.
final openHymnNumberProvider = NotifierProvider<OpenHymnNotifier, int?>(
  OpenHymnNotifier.new,
);

class OpenHymnNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void open(int number) => state = number;

  void close() => state = null;
}
