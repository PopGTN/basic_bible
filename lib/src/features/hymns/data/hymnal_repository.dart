import 'dart:typed_data';

import 'package:archive/archive.dart' show GZipEncoder;
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:http/http.dart' as http;

import '../../../services/verified_download.dart';
import '../../library/data/in_flight_requests.dart';
import '../models/content_repository.dart';
import '../models/hymnal.dart';
import 'hymnal_json_codec.dart';
import 'hymnal_store.dart';

/// A hymnal shipped inside the app. Listed without parsing; the full
/// metadata (publisher, copyright) comes from the asset when it loads.
class BundledHymnal {
  const BundledHymnal({
    required this.id,
    required this.assetPath,
    required this.title,
    required this.shortTitle,
  });

  final String id;
  final String assetPath;
  final String title;
  final String shortTitle;

  HymnalInfo get info => HymnalInfo(
    id: id,
    title: title,
    shortTitle: shortTitle,
    sourceKind: HymnalSourceKind.bundled,
  );
}

/// Built by tool/hymnals/build_hymnal.dart. Add NBHB here once its source
/// file is supplied and `assets/hymnals/nbhb.json.gz` exists.
const kBundledHymnals = <BundledHymnal>[
  BundledHymnal(
    id: 'bhb',
    assetPath: 'assets/hymnals/bhb.json.gz',
    title: 'The Believers Hymn Book',
    shortTitle: 'BHB',
  ),
];

const kDefaultHymnalId = 'bhb';

/// Bundled, imported and repository hymnals behind one API.
class HymnalRepository {
  HymnalRepository({
    required HymnalStore store,
    AssetBundle? bundle,
    http.Client? client,
    List<BundledHymnal> bundled = kBundledHymnals,
  }) : _store = store,
       _bundle = bundle ?? rootBundle,
       _client = client ?? http.Client(),
       _bundled = bundled;

  final HymnalStore _store;
  final AssetBundle _bundle;
  final http.Client _client;
  final List<BundledHymnal> _bundled;

  final _inFlight = InFlightRequests<String, Hymnal>();

  /// Parsed books, most recently used last. Two is enough to flip between
  /// books instantly without holding every installed book in memory.
  final _cache = <String, Hymnal>{};
  static const _cacheSize = 2;

  bool isBundled(String id) => _bundled.any((b) => b.id == id);

  Future<List<HymnalInfo>> listHymnals() async => [
    for (final book in _bundled) _cache[book.id]?.info ?? book.info,
    ...await _store.listInfos(),
  ];

  Future<Hymnal> load(String id) {
    final cached = _cache.remove(id);
    if (cached != null) {
      _cache[id] = cached;
      return Future.value(cached);
    }
    return _inFlight.run(id, () async {
      final hymnal = await _loadUncached(id);
      _cache[id] = hymnal;
      while (_cache.length > _cacheSize) {
        _cache.remove(_cache.keys.first);
      }
      return hymnal;
    });
  }

  Future<Hymnal> _loadUncached(String id) async {
    final bundled = _bundled.where((b) => b.id == id).firstOrNull;
    if (bundled != null) {
      final data = await _bundle.load(bundled.assetPath);
      final hymnal = await parseHymnalInBackground(
        HymnalParseRequest(
          bytes: data.buffer.asUint8List(
            data.offsetInBytes,
            data.lengthInBytes,
          ),
          fallbackId: bundled.id,
          fallbackTitle: bundled.title,
          sourceKind: HymnalSourceKind.bundled,
        ),
      );
      return _withInfo(hymnal, hymnal.info.copyWith(id: bundled.id));
    }

    final stored = await _store.read(id);
    if (stored == null) {
      throw HymnalFormatException('Hymnal "$id" is not installed.');
    }
    final hymnal = await parseHymnalInBackground(
      HymnalParseRequest(
        bytes: stored.content,
        fallbackId: stored.info.id,
        fallbackTitle: stored.info.title,
        sourceKind: stored.info.sourceKind,
      ),
    );
    // Keep the install-time identity (namespaced id, repo, takedown
    // contact) over whatever the file itself says.
    return _withInfo(
      hymnal,
      hymnal.info.copyWith(
        id: stored.info.id,
        sourceKind: stored.info.sourceKind,
        repoId: stored.info.repoId,
        repoUrl: stored.info.repoUrl,
        takedownContact:
            hymnal.info.takedownContact ?? stored.info.takedownContact,
      ),
    );
  }

  /// Validates and stores a user-picked file. Re-importing the same book
  /// replaces it.
  Future<HymnalInfo> importBytes(
    Uint8List bytes, {
    required String fileName,
  }) async {
    final baseName = fileName
        .replaceAll(RegExp(r'\.gz$', caseSensitive: false), '')
        .replaceAll(RegExp(r'\.json$', caseSensitive: false), '');
    final title = baseName.replaceAll(RegExp(r'[_-]+'), ' ').trim();
    final parsed = await parseHymnalInBackground(
      HymnalParseRequest(
        bytes: bytes,
        fallbackId: _slug(baseName),
        fallbackTitle: title.isEmpty ? 'Imported hymnal' : title,
      ),
    );
    final info = parsed.info.copyWith(
      id: 'local/${_slug(parsed.info.id)}',
      sourceKind: HymnalSourceKind.imported,
    );
    await _save(info, bytes);
    return info;
  }

  /// Downloads [entry] from [repo] (https, size cap, SHA-256), validates it
  /// and stores it as `<repoId>/<entryId>`.
  Future<HymnalInfo> installFromRepository(
    ContentRepository repo,
    RepoHymnalEntry entry, {
    VerifiedDownloadProgress? onProgress,
  }) async {
    if (!entry.isDownloadable) {
      throw const HymnalFormatException(
        'This hymnal is listed but not offered for download.',
      );
    }
    final bytes = await fetchVerifiedHttps(
      Uri.parse(entry.downloadUrl),
      client: _client,
      maxBytes: kMaxHymnalBytes,
      actionLabel: 'download "${entry.title}"',
      expectedSize: entry.sizeBytes,
      expectedSha256: entry.sha256,
      onProgress: onProgress,
      allowLocalhostHttp: true,
    );
    final parsed = await parseHymnalInBackground(
      HymnalParseRequest(
        bytes: bytes,
        fallbackId: entry.id,
        fallbackTitle: entry.title,
        sourceKind: HymnalSourceKind.repository,
      ),
    );
    final info = parsed.info.copyWith(
      id: '${repo.id}/${entry.id}',
      sourceKind: HymnalSourceKind.repository,
      repoId: repo.id,
      repoUrl: repo.url,
      takedownContact: parsed.info.takedownContact ?? repo.takedownContact,
    );
    await _save(info, bytes);
    return info;
  }

  Future<void> delete(String id) async {
    if (isBundled(id)) return;
    _cache.remove(id);
    await _store.delete(id);
  }

  /// Deletes installed copies the repository has withdrawn (takedown).
  /// Returns the removed ids.
  Future<List<String>> removeWithdrawn(
    String repoId,
    Set<String> withdrawn,
  ) async {
    if (withdrawn.isEmpty) return const [];
    final removed = <String>[];
    for (final info in await _store.listInfos()) {
      if (info.repoId != repoId) continue;
      final entryId = info.id.substring(repoId.length + 1);
      if (withdrawn.contains(entryId)) {
        await delete(info.id);
        removed.add(info.id);
      }
    }
    return removed;
  }

  /// Deletes everything installed from [repoId] (repository removed).
  Future<void> removeAllFromRepository(String repoId) async {
    for (final info in await _store.listInfos()) {
      if (info.repoId == repoId) await delete(info.id);
    }
  }

  Future<void> _save(HymnalInfo info, Uint8List bytes) async {
    final isGzip = bytes.length > 2 && bytes[0] == 0x1f && bytes[1] == 0x8b;
    final content = isGzip
        ? bytes
        : Uint8List.fromList(GZipEncoder().encode(bytes));
    _cache.remove(info.id);
    await _store.save(
      StoredHymnal(
        info: info,
        content: content,
        sha256: sha256.convert(bytes).toString(),
      ),
    );
  }

  Hymnal _withInfo(Hymnal hymnal, HymnalInfo info) =>
      Hymnal(info: info, hymns: hymnal.hymns, index: hymnal.index);

  static String _slug(String text) {
    final slug = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return slug.isEmpty ? 'hymnal' : slug;
  }
}
