import 'dart:convert';

import 'package:basic_bible/src/models/bible_models.dart';
import 'package:http/http.dart' as http;

class RemoteTranslationCatalogService {
  RemoteTranslationCatalogService({http.Client? client})
    : _client = client ?? http.Client();

  static const String defaultCatalogUrl = String.fromEnvironment(
    'BIBLE_DATA_CATALOG_URL',
    defaultValue:
        'https://raw.githubusercontent.com/PopGTN/bible-data/main/catalog/translations.json',
  );

  static const Duration _cacheTtl = Duration(minutes: 30);
  static const Duration _requestTimeout = Duration(seconds: 20);

  final http.Client _client;
  Future<List<BibleTranslation>>? _catalogFuture;
  DateTime? _cachedAt;

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
    final response = await _client
        .get(Uri.parse(defaultCatalogUrl))
        .timeout(_requestTimeout);
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch translation catalog: HTTP ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Translation catalog JSON must be an object.');
    }

    final rawTranslations = decoded['translations'];
    if (rawTranslations is! List) {
      throw Exception('Translation catalog JSON is missing "translations".');
    }

    return rawTranslations
        .whereType<Map<String, dynamic>>()
        .map(_translationFromJson)
        .where((translation) => translation != null)
        .cast<BibleTranslation>()
        .toList(growable: false);
  }

  BibleTranslation? _translationFromJson(Map<String, dynamic> json) {
    if (json['enabled'] == false) return null;

    final id = (json['id'] as String? ?? '').trim();
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
    BibleFormat.usfx,
    BibleFormat.osis,
    BibleFormat.zefania,
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
