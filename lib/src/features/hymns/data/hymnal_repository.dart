import 'dart:typed_data';

import 'package:archive/archive.dart' show GZipEncoder;
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/services.dart'
    show AssetBundle, AssetManifest, rootBundle;
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

/// A checked, not yet saved, user import (see [HymnalRepository.prepareImport]).
class PreparedHymnalImport {
  const PreparedHymnalImport({
    required this.bytes,
    required this.info,
    required this.replacesExisting,
  });

  final Uint8List bytes;
  final HymnalInfo info;

  /// A book with the same id is already installed and will be replaced.
  final bool replacesExisting;
}

/// Built by tool/hymnals/build_hymnal.dart.
const kBundledHymnals = <BundledHymnal>[
  BundledHymnal(
    id: 'bhb',
    assetPath: 'assets/hymnals/bhb.json.gz',
    title: 'The Believers Hymn Book',
    shortTitle: 'BHB',
  ),
  BundledHymnal(
    id: 'nbhb',
    assetPath: 'assets/hymnals/nbhb.json.gz',
    title: 'The New Believers Hymnbook',
    shortTitle: 'NBHB',
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

  Future<List<BundledHymnal>>? _present;

  /// Bundled books whose asset is actually in this build. The assets are
  /// generated from a private repository (`make hymnals`), so a build from a
  /// public clone has none — those books are then simply not listed.
  Future<List<BundledHymnal>> _presentBundled() => _present ??= () async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(_bundle);
      final assets = manifest.listAssets().toSet();
      return [
        for (final book in _bundled)
          if (assets.contains(book.assetPath)) book,
      ];
    } catch (_) {
      // No manifest (e.g. a test bundle): assume everything is present.
      return _bundled;
    }
  }();

  Future<List<HymnalInfo>> listHymnals() async => [
    for (final book in await _presentBundled())
      _cache[book.id]?.info ?? book.info,
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
        // The name the user chose (or renamed it to) wins over the file's.
        title: stored.info.title,
        shortTitle: stored.info.shortTitle ?? '',
      ),
    );
  }

  /// Checks a user-picked file without saving it, so the user can name the
  /// book first. The title is the book's own (v1 files) or comes from the
  /// file name (legacy files).
  Future<PreparedHymnalImport> prepareImport(
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
    return PreparedHymnalImport(
      bytes: bytes,
      info: info,
      replacesExisting: await _store.read(info.id) != null,
    );
  }

  /// Saves a prepared import under the name the user chose. Importing the
  /// same book again replaces it.
  Future<HymnalInfo> completeImport(
    PreparedHymnalImport prepared, {
    required String title,
    String? shortTitle,
  }) async {
    final info = prepared.info.copyWith(
      title: title.trim().isEmpty ? prepared.info.title : title.trim(),
      shortTitle: shortTitle?.trim() ?? prepared.info.shortTitle,
    );
    await _save(info, prepared.bytes);
    return info;
  }

  /// Validates and stores a user-picked file in one step, keeping the
  /// file's own (or file-name) title.
  Future<HymnalInfo> importBytes(
    Uint8List bytes, {
    required String fileName,
  }) async {
    final prepared = await prepareImport(bytes, fileName: fileName);
    return completeImport(prepared, title: prepared.info.title);
  }

  /// Renames an imported or downloaded book. Bundled books keep their names.
  Future<HymnalInfo> rename(
    String id, {
    required String title,
    String? shortTitle,
  }) async {
    final stored = await _store.read(id);
    if (stored == null || title.trim().isEmpty) {
      throw HymnalFormatException('Hymnal "$id" cannot be renamed.');
    }
    final info = stored.info.copyWith(
      title: title.trim(),
      shortTitle: shortTitle?.trim() ?? stored.info.shortTitle,
    );
    _cache.remove(id);
    await _store.save(
      StoredHymnal(info: info, content: stored.content, sha256: stored.sha256),
    );
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
    // Compressing and hashing a multi-MB import is pure CPU work; keep it
    // off the UI isolate so the screen doesn't freeze while saving.
    final (:content, :digest) = await compute(_compressAndHash, bytes);
    _cache.remove(info.id);
    await _store.save(
      StoredHymnal(info: info, content: content, sha256: digest),
    );
  }

  static ({Uint8List content, String digest}) _compressAndHash(
    Uint8List bytes,
  ) {
    final isGzip = bytes.length > 2 && bytes[0] == 0x1f && bytes[1] == 0x8b;
    return (
      content: isGzip ? bytes : Uint8List.fromList(GZipEncoder().encode(bytes)),
      digest: sha256.convert(bytes).toString(),
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
