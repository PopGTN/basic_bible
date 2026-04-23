import 'dart:convert';

import 'package:basic_bible/src/models/bible_models.dart';
import 'package:http/http.dart' as http;

/// Signature for a function that extracts a raw translation list from a
/// successfully decoded JSON body. Throws if the body shape is unexpected.
typedef _CatalogParser =
    List<Map<String, dynamic>> Function(Map<String, dynamic> body);

List<Map<String, dynamic>> _parseTranslationsEnvelope(
  Map<String, dynamic> body,
) {
  final raw = body['translations'];
  if (raw is! List) {
    throw FormatException('Catalog JSON is missing a "translations" list.');
  }
  return raw.whereType<Map<String, dynamic>>().toList(growable: false);
}

/// Parses the legacy ebible_list.json format where translations are stored
/// directly as a top-level list under the "bibles" key.
List<Map<String, dynamic>> _parseEbibleList(Map<String, dynamic> body) {
  final raw = body['bibles'] ?? body['translations'];
  if (raw is! List) {
    throw FormatException('ebible_list JSON is missing a "bibles" list.');
  }
  return raw.whereType<Map<String, dynamic>>().toList(growable: false);
}

class RemoteTranslationCatalogService {
  RemoteTranslationCatalogService({
    http.Client? client,
    this.catalogUrlOverride,
  }) : _client = client ?? http.Client();

  static const String defaultCatalogUrl = String.fromEnvironment(
    'BIBLE_DATA_CATALOG_URL',
    defaultValue:
        'https://raw.githubusercontent.com/PopGTN/bible-data/main/catalog/production/bibles.json',
  );

  /// Ordered list of (url, parser) pairs tried in sequence on primary failure.
  /// Each entry uses the parser appropriate for that endpoint's schema so a
  /// format mismatch on one fallback does not silently discard data from another.
  static final List<({String url, _CatalogParser parser})>
  _fallbackCatalogEndpoints = [
    (url: defaultCatalogUrl, parser: _parseTranslationsEnvelope),
    (
      url:
          'https://raw.githubusercontent.com/PopGTN/bible-data/main/catalog/translations.json',
      parser: _parseTranslationsEnvelope,
    ),
    (
      url:
          'https://raw.githubusercontent.com/PopGTN/bible-data/main/ebible_list.json',
      parser: _parseEbibleList,
    ),
  ];

  static const Duration _cacheTtl = Duration(minutes: 30);
  static const Duration _requestTimeout = Duration(seconds: 20);

  final http.Client _client;
  final String? catalogUrlOverride;
  Future<List<BibleTranslation>>? _catalogFuture;
  DateTime? _cachedAt;

  List<({String url, _CatalogParser parser})> get _catalogEndpoints {
    final overrideUrl = catalogUrlOverride?.trim();
    if (overrideUrl == null || overrideUrl.isEmpty) {
      return _fallbackCatalogEndpoints;
    }
    return [
      (url: overrideUrl, parser: _parseTranslationsEnvelope),
      ..._fallbackCatalogEndpoints.where(
        (endpoint) => endpoint.url != overrideUrl,
      ),
    ];
  }

  Future<List<BibleTranslation>> fetchTranslations({
    bool forceRefresh = false,
  }) {
    final expired =
        _cachedAt == null || DateTime.now().difference(_cachedAt!) > _cacheTtl;
    if (forceRefresh || _catalogFuture == null || expired) {
      _catalogFuture = _fetchTranslations().then((translations) {
        _cachedAt = DateTime.now();
        return translations;
      });
    }
    return _catalogFuture!;
  }

  Future<List<BibleTranslation>> _fetchTranslations() async {
    final errors = <String>[];

    for (final endpoint in _catalogEndpoints) {
      try {
        final response = await _client
            .get(Uri.parse(endpoint.url))
            .timeout(_requestTimeout);

        if (response.statusCode != 200) {
          errors.add('HTTP ${response.statusCode} at ${endpoint.url}');
          continue;
        }

        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (decoded is! Map<String, dynamic>) {
          errors.add('Non-object JSON body at ${endpoint.url}');
          continue;
        }

        final rawList = endpoint.parser(decoded);
        return rawList
            .map(_translationFromJson)
            .where((t) => t != null)
            .cast<BibleTranslation>()
            .toList(growable: false);
      } catch (e) {
        errors.add('${endpoint.url}: $e');
      }
    }

    throw Exception(
      'Failed to fetch translation catalog after ${errors.length} attempt(s):\n'
      '${errors.join('\n')}',
    );
  }

  BibleTranslation? _translationFromJson(Map<String, dynamic> json) {
    if (json['enabled'] == false) return null;

    final id = _resolveStableTranslationId(json);
    final name = (json['name'] as String? ?? '').trim();
    if (id.isEmpty || name.isEmpty) return null;

    final artifacts = (json['artifacts'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(_artifactFromJson)
        .where((artifact) => artifact != null)
        .cast<BibleTranslationArtifact>()
        .toList(growable: false);

    final preferredArtifact = _firstRemoteArtifactForList(
      artifacts,
      supportedFormats: BibleFormat.values.toSet(),
    );

    return BibleTranslation(
      id: id,
      name: name,
      language: (json['language'] as String? ?? 'unknown').trim(),
      languageName: (json['languageName'] as String? ?? '').trim(),
      description: (json['description'] as String? ?? '').trim(),
      isLocal: false,
      githubUrl: preferredArtifact?.downloadUrl,
      format: preferredArtifact?.format ?? BibleFormat.auto,
      sourceType: BibleSourceType.download,
      bundledByDefault: json['bundledByDefault'] == true,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      artifacts: artifacts,
    );
  }

  BibleTranslationArtifact? _artifactFromJson(Map<String, dynamic> json) {
    final format = _parseFormat(json['format'] as String?);
    final downloadUrl = (json['downloadUrl'] as String? ?? '').trim();
    final fileName = (json['fileName'] as String? ?? '').trim();
    if (format == null || downloadUrl.isEmpty || fileName.isEmpty) {
      return null;
    }

    return BibleTranslationArtifact(
      format: format,
      downloadUrl: downloadUrl,
      fileName: fileName,
      parserVersion: (json['parserVersion'] as num?)?.toInt(),
      schemaVersion: (json['schemaVersion'] as num?)?.toInt(),
      sizeBytes: (json['sizeBytes'] as num?)?.toInt(),
      sha256: (json['sha256'] as String?)?.trim(),
      isPreferred: json['isPreferred'] == true,
    );
  }

  BibleFormat? _parseFormat(String? raw) {
    if (raw == null) return null;
    return BibleFormat.values.where((format) => format.name == raw).firstOrNull;
  }

  String _resolveStableTranslationId(Map<String, dynamic> json) {
    final rawSourceId = (json['sourceId'] as String? ?? '').trim();
    final rawId = (json['id'] as String? ?? '').trim();
    return _normalizeId(rawSourceId.isNotEmpty ? rawSourceId : rawId);
  }

  String _normalizeId(String raw) {
    final normalized = raw.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    return normalized.replaceAll(RegExp(r'^_+|_+$'), '');
  }
}

BibleTranslationArtifact? firstPreferredRemoteArtifact(
  BibleTranslation translation, {
  required Set<BibleFormat> supportedFormats,
}) {
  if (translation.artifacts.isNotEmpty) {
    return _firstRemoteArtifactForList(
      translation.artifacts,
      supportedFormats: supportedFormats,
    );
  }

  final githubUrl = translation.githubUrl;
  if (githubUrl == null || githubUrl.isEmpty) return null;
  if (!supportedFormats.contains(translation.format)) return null;
  return BibleTranslationArtifact(
    format: translation.format,
    downloadUrl: githubUrl,
    fileName: githubUrl.split('/').last,
    isPreferred: true,
  );
}

BibleTranslationArtifact? _firstRemoteArtifactForList(
  List<BibleTranslationArtifact> artifacts, {
  required Set<BibleFormat> supportedFormats,
}) {
  const preferenceOrder = <BibleFormat>[
    BibleFormat.sqlite,
    BibleFormat.zip,
    BibleFormat.usfx,
    BibleFormat.osis,
    BibleFormat.zefania,
    BibleFormat
        .usfm, // last: requires native Rust parser; prefer XML formats first
  ];

  final filtered = artifacts
      .where((artifact) => supportedFormats.contains(artifact.format))
      .toList(growable: false);
  if (filtered.isEmpty) return null;

  final preferred = filtered.where((artifact) => artifact.isPreferred).toList();
  if (preferred.isNotEmpty) {
    preferred.sort(
      (a, b) => preferenceOrder
          .indexOf(a.format)
          .compareTo(preferenceOrder.indexOf(b.format)),
    );
    return preferred.first;
  }

  filtered.sort(
    (a, b) => preferenceOrder
        .indexOf(a.format)
        .compareTo(preferenceOrder.indexOf(b.format)),
  );
  return filtered.first;
}
