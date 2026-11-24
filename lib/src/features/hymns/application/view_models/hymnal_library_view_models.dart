import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/content_repository.dart';
import '../../models/hymnal.dart';
import 'hymnal_view_models.dart';

/// The user's repositories (official first).
final contentReposProvider =
    NotifierProvider<ContentReposNotifier, List<ContentRepository>>(
      ContentReposNotifier.new,
    );

class ContentReposNotifier extends Notifier<List<ContentRepository>> {
  @override
  List<ContentRepository> build() =>
      ref.read(contentRepoServiceProvider).loadRepositories();

  /// Validates [url] by fetching its index; throws a user-readable error.
  Future<RepoIndex> probe(String url) =>
      ref.read(contentRepoServiceProvider).probe(url);

  Future<void> add(String url, RepoIndex index) async {
    await ref.read(contentRepoServiceProvider).addRepository(url, index);
    _reload();
  }

  /// Removes the repository and every book installed from it.
  Future<void> remove(ContentRepository repo) async {
    await ref.read(contentRepoServiceProvider).removeRepository(repo.id);
    await ref.read(hymnalRepositoryProvider).removeAllFromRepository(repo.id);
    _afterLibraryChange();
    _reload();
  }

  Future<void> setEnabled(ContentRepository repo, bool enabled) async {
    await ref.read(contentRepoServiceProvider).setEnabled(repo.id, enabled);
    _reload();
  }

  void refresh() => ref.invalidate(repoIndexesProvider);

  void _reload() {
    state = ref.read(contentRepoServiceProvider).loadRepositories();
    ref.invalidate(repoIndexesProvider);
  }

  void _afterLibraryChange() {
    ref.invalidate(hymnalListProvider);
    ref.invalidate(currentHymnalProvider);
  }
}

/// One enabled repository's index, or why it couldn't be loaded.
typedef RepoIndexResult = ({
  ContentRepository repo,
  RepoIndex? index,
  String? error,
});

/// Indexes of all enabled repositories. Loading them also applies takedowns:
/// installed books a repository has withdrawn are deleted.
final repoIndexesProvider = FutureProvider<List<RepoIndexResult>>((ref) async {
  final service = ref.watch(contentRepoServiceProvider);
  final repository = ref.watch(hymnalRepositoryProvider);
  final repos = ref.watch(contentReposProvider).where((r) => r.enabled);
  final results = await Future.wait([
    for (final repo in repos)
      service
          .fetchIndex(repo)
          .then<RepoIndexResult>(
            (index) => (repo: repo, index: index, error: null),
          )
          .catchError((Object e) => (repo: repo, index: null, error: '$e')),
  ]);
  var removedAny = false;
  for (final result in results) {
    final index = result.index;
    if (index == null) continue;
    final removed = await repository.removeWithdrawn(
      result.repo.id,
      index.withdrawn,
    );
    removedAny = removedAny || removed.isNotEmpty;
  }
  if (removedAny) {
    ref.invalidate(hymnalListProvider);
    ref.invalidate(currentHymnalProvider);
  }
  return results;
});

/// Downloads in progress, keyed by installed id (`repoId/entryId`), with
/// a 0–1 fraction or null when the size is unknown.
final hymnalInstallsProvider =
    NotifierProvider<HymnalInstallsNotifier, Map<String, double?>>(
      HymnalInstallsNotifier.new,
    );

class HymnalInstallsNotifier extends Notifier<Map<String, double?>> {
  @override
  Map<String, double?> build() => const {};

  Future<HymnalInfo> install(
    ContentRepository repo,
    RepoHymnalEntry entry,
  ) async {
    final key = '${repo.id}/${entry.id}';
    state = {...state, key: null};
    try {
      final info = await ref
          .read(hymnalRepositoryProvider)
          .installFromRepository(
            repo,
            entry,
            onProgress: (received, total) {
              if (total == null || total == 0) return;
              state = {...state, key: received / total};
            },
          );
      ref.invalidate(hymnalListProvider);
      return info;
    } finally {
      state = {...state}..remove(key);
    }
  }

  Future<HymnalInfo> importFile(Uint8List bytes, String fileName) async {
    final info = await ref
        .read(hymnalRepositoryProvider)
        .importBytes(bytes, fileName: fileName);
    ref.invalidate(hymnalListProvider);
    if (ref.read(selectedHymnalIdProvider) == info.id) {
      ref.invalidate(currentHymnalProvider);
    }
    return info;
  }

  Future<void> delete(HymnalInfo info) async {
    await ref.read(hymnalRepositoryProvider).delete(info.id);
    ref.invalidate(hymnalListProvider);
    ref.invalidate(currentHymnalProvider);
  }
}
