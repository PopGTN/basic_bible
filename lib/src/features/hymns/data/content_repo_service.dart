import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/content_repository.dart';

/// Thrown for repository problems; [message] is shown to the user.
class ContentRepoException implements Exception {
  const ContentRepoException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Manages the user's content repositories (stored in SharedPreferences)
/// and fetches their indexes with the same rules as the Bible catalog:
/// https only (http allowed for localhost testing), 20 s timeout, a 30 min
/// in-memory cache, and the last good copy kept for offline use.
class ContentRepoService {
  ContentRepoService(this._prefs, {http.Client? client})
    : _client = client ?? http.Client();

  final SharedPreferences _prefs;
  final http.Client _client;

  static const officialRepoId = 'official';
  static const officialRepoUrl = String.fromEnvironment(
    'HYMNAL_REPO_URL',
    defaultValue:
        'https://raw.githubusercontent.com/PopGTN/bible-data/main/catalog/production/hymnals.json',
  );

  static const _reposKey = 'content_repos_v1';
  static const _cachePrefix = 'content_repo_cache_';
  static const _cacheTtl = Duration(minutes: 30);
  static const _timeout = Duration(seconds: 20);
  static const _maxIndexBytes = 2 * 1024 * 1024;

  final Map<String, ({RepoIndex index, DateTime at})> _memory = {};

  static const ContentRepository officialRepository = ContentRepository(
    id: officialRepoId,
    url: officialRepoUrl,
    name: 'Basic Bible (official)',
    isOfficial: true,
  );

  /// The saved repositories, official first. The official one can be
  /// disabled but never removed.
  List<ContentRepository> loadRepositories() {
    final saved = <ContentRepository>[];
    final raw = _prefs.getString(_reposKey);
    if (raw != null) {
      try {
        for (final item in jsonDecode(raw) as List) {
          final repo = ContentRepository.fromJson(
            Map<String, dynamic>.from(item as Map),
          );
          if (repo.id.isNotEmpty && repo.url.isNotEmpty) saved.add(repo);
        }
      } catch (_) {
        // A corrupt list falls back to just the official repository.
      }
    }
    final official = saved.where((r) => r.isOfficial).firstOrNull;
    return [
      official?.copyWith() ?? officialRepository,
      ...saved.where((r) => !r.isOfficial),
    ];
  }

  Future<void> saveRepositories(List<ContentRepository> repos) =>
      _prefs.setString(
        _reposKey,
        jsonEncode([for (final repo in repos) repo.toJson()]),
      );

  /// Fetches and validates [url] without saving it, for the "Add
  /// repository" flow.
  Future<RepoIndex> probe(String url) async => _download(_validatedUri(url));

  /// Adds a third-party repository from a probed [index].
  Future<ContentRepository> addRepository(String url, RepoIndex index) async {
    final repos = loadRepositories();
    final normalized = _validatedUri(url).toString();
    if (repos.any((r) => r.url == normalized)) {
      throw const ContentRepoException('This repository is already added.');
    }
    var id = _slug(index.repoId ?? index.name);
    if (id.isEmpty || id == officialRepoId) {
      id = sha1.convert(utf8.encode(normalized)).toString().substring(0, 10);
    }
    var unique = id;
    for (var n = 2; repos.any((r) => r.id == unique); n++) {
      unique = '$id-$n';
    }
    final repo = ContentRepository(
      id: unique,
      url: normalized,
      name: index.name,
      description: index.description,
      maintainer: index.maintainer,
      homepage: index.homepage,
      takedownContact: index.takedownContact,
      disclaimer: index.disclaimer,
    );
    await saveRepositories([...repos, repo]);
    _remember(repo, index);
    return repo;
  }

  Future<void> removeRepository(String id) async {
    final repos = loadRepositories();
    final target = repos.where((r) => r.id == id).firstOrNull;
    if (target == null || target.isOfficial) return;
    await saveRepositories(repos.where((r) => r.id != id).toList());
    _memory.remove(target.url);
    await _prefs.remove(_cacheKey(target.url));
  }

  Future<void> setEnabled(String id, bool enabled) async {
    final repos = [
      for (final repo in loadRepositories())
        repo.id == id ? repo.copyWith(enabled: enabled) : repo,
    ];
    await saveRepositories(repos);
  }

  /// The repository's index. Serves the in-memory copy for 30 minutes, then
  /// the network, then the last good copy saved on device (offline).
  Future<RepoIndex> fetchIndex(
    ContentRepository repo, {
    bool forceRefresh = false,
  }) async {
    final cached = _memory[repo.url];
    if (!forceRefresh &&
        cached != null &&
        DateTime.now().difference(cached.at) < _cacheTtl) {
      return cached.index;
    }
    try {
      final index = await _download(_validatedUri(repo.url));
      _remember(repo, index);
      return index;
    } catch (error) {
      final offline = _prefs.getString(_cacheKey(repo.url));
      if (offline != null) {
        try {
          return RepoIndex.fromJson(jsonDecode(offline));
        } catch (_) {}
      }
      if (error is ContentRepoException) rethrow;
      throw ContentRepoException('Could not load "${repo.name}": $error');
    }
  }

  void _remember(ContentRepository repo, RepoIndex index) {
    _memory[repo.url] = (index: index, at: DateTime.now());
  }

  Future<RepoIndex> _download(Uri uri) async {
    final http.Response response;
    try {
      response = await _client.get(uri).timeout(_timeout);
    } on TimeoutException {
      throw const ContentRepoException(
        'The repository took too long to respond.',
      );
    } catch (error) {
      throw ContentRepoException('Could not reach the repository: $error');
    }
    if (response.statusCode != 200) {
      throw ContentRepoException(
        'The repository answered with HTTP ${response.statusCode}.',
      );
    }
    if (response.bodyBytes.length > _maxIndexBytes) {
      throw const ContentRepoException('The repository index is too large.');
    }
    final body = utf8.decode(response.bodyBytes, allowMalformed: true);
    final RepoIndex index;
    try {
      index = RepoIndex.fromJson(jsonDecode(body));
    } on FormatException catch (error) {
      throw ContentRepoException(error.message);
    }
    await _prefs.setString(_cacheKey(uri.toString()), body);
    return index;
  }

  /// https only; plain http only for localhost so a repo can be tested
  /// locally before publishing it.
  static Uri _validatedUri(String url) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || uri.host.isEmpty) {
      throw const ContentRepoException('That is not a valid web address.');
    }
    final local = uri.host == 'localhost' || uri.host == '127.0.0.1';
    if (uri.scheme != 'https' && !(uri.scheme == 'http' && local)) {
      throw const ContentRepoException(
        'Repositories must use a secure https:// address.',
      );
    }
    return uri;
  }

  static String _cacheKey(String url) =>
      '$_cachePrefix${sha1.convert(utf8.encode(url))}';

  static String _slug(String text) => text
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}
